#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;

use warnings;


sub passes;
sub failures;

use constant  PASSES  =>   20;
use constant  FAIL    =>    5;

my $normal      = $RE {zip} {Spain};
my $prefix      = $RE {zip} {Spain} {-prefix  => 'yes'};
my $no_prefix   = $RE {zip} {Spain} {-prefix  => 'no'};
my $iso         = $RE {zip} {Spain} {-country => "iso"};
my $cept        = $RE {zip} {Spain} {-country => "cept"};
my $country     = $RE {zip} {Spain} {-country => "ES"};
my $iso_prefix  = $iso  -> {-prefix => 'yes'};
my $cept_prefix = $cept -> {-prefix => 'yes'};

my @tests = (
    [ normal       => $normal      =>  [qw /1 1 1/]],
    [ prefix       => $prefix      =>  [qw /0 1 1/]],
    ['no prefix'   => $no_prefix   =>  [qw /1 0 0/]],
    [ iso          => $iso         =>  [qw /1 0 1/]],
    [ cept         => $cept        =>  [qw /1 1 0/]],
    [ country      => $country     =>  [qw /1 0 1/]],
    ['iso prefix'  => $iso_prefix  =>  [qw /0 0 1/]],
    ['cept prefix' => $cept_prefix =>  [qw /0 1 0/]],
);

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
   $max += PASSES    * $m;
   $max += PASSES    * $k;
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
foreach my $d (1 .. PASSES) {
    my ($x, $y, $z) = qw /01 0 00/;

    while ($cache {"$x$y$z"} ++) {
        $x = _ 2; redo unless 00 < $x && $x <= 52;
        $y = _ 1;
        $z = _ 2;
    }

    my @t = ([undef, "$x$y$z", $x, $y, $z],
             ["E",   "$x$y$z", $x, $y, $z],
             ["ES",  "$x$y$z", $x, $y, $z]);

    my $c = 0;
    foreach my $t (@t) {
        local $_  = defined $t -> [0] ? $t -> [0] . "-" : "";
              $_ .= join "" => @$t [2 .. 4];
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
        my $x = _ 2, 4;
        redo if $cache {$x} ++;
        push @failures => $x;
    }

    # Too long.
    for (1 .. FAIL) {
        my $x = _ 6, 10; 
        redo if $cache {$x} ++;
        push @failures => $x;
    }

    for my $c ('.', ';', '-', ' ', '+') {
        for (1 .. FAIL) {
            my $x  = _ 4;
               $x .= $c;
            redo if $cache {$x} ++;
            push @failures => $x;
        }
        for (1 .. FAIL) {
            my $x  = _ 4;
               $x  = "$c$x";
            redo if $cache {$x} ++;
            push @failures => $x;
        }
    }

    # Wrong provinces.
    for (1 .. FAIL) {
        my $x = _ 2; redo if $x <= 52;
        my $y = _ 3;
        redo if $cache {"$x$y"};
        push @failures => "$x$y";
    }

    push @failures => "00" . _ 3;

    # Same failures, with country in front of it as well.
    push @failures => map {("ES-$_", "E-$_")} @failures;

    # Wrong countries.
    for (1 .. FAIL) {
        my $c = join "" => map {('A' .. 'Z') [rand 26]} 1 .. 2;
        redo if $c eq "ES" || $c eq "E" || $cache {$c} ++;
        my $x = _ 5;
        push @failures => "$c-$x";
    }

    for (1 .. FAIL) {
        my $c = ('A' .. 'Z') [rand 26];
        redo if $cache {$c} ++;
        my $x = _ 5;
        push @failures => "${c}ES-$x";
        push @failures => "ES$c-$x";
    }

    for (1 .. FAIL) {
        my $x = _ 5;
        redo if $cache {"es-$x"} ++;
        push @failures => "es-$x", "e-$x";
    }

    @failures;
}

__END__
