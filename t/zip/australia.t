#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;
use warnings;


sub passes;
sub failures;

use constant  FAIL    =>    5;

my $normal      = $RE {zip} {Australia};
my $prefix      = $RE {zip} {Australian} {-prefix  => 'yes'};
my $no_prefix   = $RE {zip} {Australia}  {-prefix  => 'no'};
my $iso         = $RE {zip} {Australian} {-country => "iso"};
my $cept        = $RE {zip} {Australia}  {-country => "cept"};
my $country     = $RE {zip} {Australian} {-country => "Aus"};
my $iso_prefix  = $iso  -> {-prefix => 'yes'};
my $cept_prefix = $cept -> {-prefix => 'yes'};

my @tests = (
    [ normal       => $normal      =>  [qw /1 1 1 0/]],
    [ prefix       => $prefix      =>  [qw /0 1 1 0/]],
    ['no prefix'   => $no_prefix   =>  [qw /1 0 0 0/]],
    [ iso          => $iso         =>  [qw /1 0 1 0/]],
    [ cept         => $cept        =>  [qw /1 1 0 0/]],
    [ country      => $country     =>  [qw /1 0 0 1/]],
    ['iso prefix'  => $iso_prefix  =>  [qw /0 0 1 0/]],
    ['cept prefix' => $cept_prefix =>  [qw /0 1 0 0/]],
);

my @states = (2, 8, 9, '02', '08', '09', 10 .. 97);

my @failures = failures;

my $count;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

my $m = 0;
my $k = 0;
foreach my $test (@tests) {
    $m ++ foreach           @{$test -> [2]};
    $k ++ foreach grep {$_} @{$test -> [2]};
}

my $max  = 1;
   $max += @states   * $m;
   $max += @states   * $k;
   $max += @failures * @tests;
print "1..$max\n";

print "ok ", ++ $count, "\n";

sub run_test {
    my ($name, $re, $should_match) = @_;
    my $match = "<<$_>>" =~ /$re/;
    my $good  = $match && $_ eq $&;
    my $line  = $good ? "match" : $match ? "wrong match (got: $&)" : "no match";
       $line .= "; $name";
    if ($should_match) {$good ? pass $line : fail $line}
    else               {$good ? fail $line : pass $line}
}

sub array_cmp {
    my ($a1, $a2) = @_;
    return 0 unless @$a1 eq @$a2;  
    foreach my $i (0 .. $#$a1) {
       !defined $$a1 [$i] && !defined $$a2 [$i] ||
        defined $$a1 [$i] &&  defined $$a2 [$i] && $$a1 [$i] eq $$a2 [$i]
        or return 0;
    }
    return 1;
}

sub __ {map {defined () ? $_ : "UNDEF"} @_}
sub run_keep {
    my ($name, $re, $parts) = @_;

    my @chunks = /^$re->{-keep}$/;
    unless (@chunks) {fail "no match; $name - keep"; return}

    array_cmp (\@chunks, [$_ => @$parts])
                           ? pass "match; $name - keep"
                           : fail "wrong match [@{[__ @chunks]}]; $name - keep"
}

sub _ {
    my $min = $_ [0];
    my $max = @_ > 1 ? $_ [1] : $_ [0];
    my $x  = "";
       $x .= int rand 10 for 1 .. $_ [0] + int rand (1 + $max - $min);
       $x;
}

my %cache;
foreach my $x (@states) {
    my $y = $x =~ /9$/ ? "09" : _ 2;

    my @t = ([undef, "$x$y", $x, $y],
             ["AUS", "$x$y", $x, $y],
             ["AU",  "$x$y", $x, $y],
             ["Aus", "$x$y", $x, $y]);

    my $c = 0;
    foreach my $t (@t) {
        local $_  = defined $t -> [0] ? $t -> [0] . "-" : "";
              $_ .= join "" => @$t [2 .. 3];
        foreach my $test (@tests) {
            my ($name, $re, $matches) = @$test;
            run_test $name, $re,                  $matches -> [$c];
            run_keep $name, $re -> {-keep}, $t if $matches -> [$c];
        }
        $c ++;
    }
}


foreach (@failures) {
    foreach my $test (@tests) {
        my ($name, $re) = @$test;
        /^$re$/ ? fail "match; $name" : pass "no match; $name";
    }
}



sub failures {
    my @failures = ("", " ");

    # Too short.
    push @failures => 0 .. 9;
    for (1 .. FAIL) {
        my $x = _ 1, 3;
        redo if $x =~ /^[28]..$/ || $x eq "909" || $cache {$x} ++;
        push @failures => $x;
    }

    # Too long.
    for (1 .. FAIL) {
        my $x = _ 5, 10; 
        redo if $cache {$x} ++;
        push @failures => $x;
    }

    for my $c ('.', ';', '-', ' ', '+') {
        for (1 .. FAIL) {
            my $x  = _ 3;
               $x .= $c;
            redo if $cache {$x} ++;
            push @failures => $x;
        }
        for (1 .. FAIL) {
            my $x  = _ 3;
               $x  = "$c$x";
            redo if $cache {$x} ++;
            push @failures => $x;
        }
    }

    # Wrong states
    for my $s ('00', '01', '03' .. '07') {
        my $x = _ 2;
        my $zip = "$s$x";
        redo if $cache {$zip} ++;
        push @failures => $zip;
    }

    # Test leading '9'/'09'.
 OUTER:
    for (1 .. FAIL) {
        my $x = _ 2;
        redo if $x eq "09";
        for my $s ("9", "09") {
            my $zip = "$s$x";
            redo OUTER if $cache {$zip} ++;
            push @failures => $zip;
        }
    }

    # Same failures, with country in front of it as well.
    push @failures => map {("AUS-$_", "AU-$_")} @failures;

    # Wrong countries.
    for (1 .. FAIL) {
        my $c = join "" => map {('A' .. 'Z') [rand 26]} 1 .. 1 + int rand 3;
        redo if $c eq "AUS" || $c eq "AU" || $cache {$c} ++;
        my $x = _ 4;
        push @failures => "$c-$x";
    }

    for (1 .. FAIL) {
        my $c = ('A' .. 'Z') [rand 26];
        redo if $cache {$c} ++;
        my $x = _ 4;
        push @failures => "${c}AUS-$x";
        push @failures => "AUS$c-$x";
        push @failures => "${c}AU-$x";
        $c =~ y!S!Z!;
        push @failures => "AU$c-$x";
    }

    for (1 .. FAIL) {
        my $x = _ 4;
        push @failures => "aus-$x", "au-$x";
    }

    @failures;
}

__END__
