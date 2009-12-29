#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;

$^W = 1;

($VERSION) = q $Revision: 2.102 $ =~ /[\d.]+/;

BEGIN {
    if ($] < 5.00503) {
        print "1..1\n";
        print "ok 1\n";
        exit;
    }
}

sub failures;

use constant  PASSES  =>   50;
use constant  FAIL    =>   10;

my $normal        = $RE {zip} {US};
my $maybe         = $RE {zip} {US} {-extended => 'maybe'};
my $yes           = $RE {zip} {US} {-extended => 'yes'};
my $no            = $RE {zip} {US} {-extended => 'no'};
my $sep           = $RE {zip} {US} {-sep => ' '};
my $iso           = $RE {zip} {US} {-country => "iso"};
my $cept          = $RE {zip} {US} {-country => "cept"};
my $country       = $RE {zip} {US} {-country => "USA"};
my $prefix        = $RE {zip} {US} {-prefix => 'yes'};
my $no_prefix     = $RE {zip} {US} {-prefix => 'no'};

my @tests = (
    [ normal      => $normal      =>  [qw /1 1 1 1 0 0 1 1/]],
    [ maybe       => $maybe       =>  [qw /1 1 1 1 0 0 1 1/]],
    [ yes         => $yes         =>  [qw /0 0 1 1 0 0 0 1/]],
    [ no          => $no          =>  [qw /1 1 0 0 0 0 1 0/]],
    [ prefix      => $prefix      =>  [qw /0 1 0 1 0 0 1 1/]],
    [ iso         => $iso         =>  [qw /1 1 1 1 0 0 0 0/]],
    [ cept        => $cept        =>  [qw /1 0 1 0 0 0 1 1/]],
    [ country     => $country     =>  [qw /1 0 1 0 0 0 1 1/]],
    ['no prefix'  => $no_prefix   =>  [qw /1 0 1 0 0 0 0 0/]],
    [ sep         => $sep         =>  [qw /1 1 0 0 1 1 1 0/]],
);

my @failures = failures;

my $count;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

my $max = 1 + 2 * @tests * @{$tests [0] -> [2]} * PASSES + @failures * @tests;
print "1..$max\n";

print "not " unless defined $Regexp::Common::zip::VERSION;
print "ok ", ++ $count, " - Regexp::Common::zip::VERSION\n";


sub run_test {
    my ($name, $re, $should_match) = @_;
    my $match = /^$re$/;
    my $line  = $match ? "match" : "no match";
       $line .= "; $name";
   ($match xor $should_match) ? fail $line : pass $line
}

sub __ {map {defined () ? $_ : "UNDEF"} @_}
sub run_keep {
    my ($name, $re, $should_match) = splice @_ => 0, 3;
    unless ($should_match) {
        if (/^$re$/) {fail "match; keep - $name"}
        else         {pass "no match; keep - $name"}
        return;
    }
    my @exp = ($_, $_ [0], join ("" => grep {defined} @_ [1 .. 3]),
               @_ [1 .. 3]);
    if (my @args = /^$re$/) {
        unshift @_ => $_;
        unless (@exp == @args) {
            fail "match; keep - $name [@{[__ @args]}]";
        }
        foreach my $n (0 .. $#_) {
            unless (!defined $exp [$n] && !defined $args [$n] ||
                     defined $exp [$n] &&  defined $args [$n] &&
                             $exp [$n] eq          $args [$n]) {
                fail "match; keep - $name [@{[__ @args]}]";
                return;
            }
        }
        pass "match; keep - $name";
        return;
    }
    fail "no match; keep - $name";
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
    my $z = "00000";
    my $e = "0000";

    $z = _ 5 while $cache {$z} ++;
    $e = _ 4 while $cache {$e} ++;

    my @t = ([undef, $z, undef, undef],
             ["US",  $z, undef, undef],
             [undef, $z, "-",   $e],
             ["US",  $z, "-",   $e],
             [undef, $z, " ",   $e],
             ["US",  $z, " ",   $e],
             ["USA", $z, undef, undef],
             ["USA", $z, "-",   $e]);

    my $c = 0;
    foreach my $t (@t) {
        local $_  = defined $t -> [0] ? $t -> [0] . "-" : "";
              $_ .= join "" => grep {defined} @{$t} [1 .. 3];
        foreach my $test (@tests) {
            my ($name, $re, $matches) = @$test;
            run_test $name, $re,            $matches -> [$c];
            run_keep $name, $re -> {-keep}, $matches -> [$c], @$t;
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

    # Too short, basic zips.
    push @failures => 0 .. 9;
    for (1 .. FAIL) {
        my $x = _ 2, 4;
        redo if $cache {$x} ++;
        push @failures => $x;
    }

    # Too long, basic zips.
    for (1 .. FAIL) {
        my $x = _ 6, 10; 
        redo if $cache {$x} ++;
        push @failures => $x;
    }

    # Too short extensions.
    for (1 .. FAIL) {
        my $x = _ 5;
        my $y = _ 1, 3;
        redo if $cache {"$x-$y"} ++;
        push @failures => "$x-$y";
    }

    # Too long extensions.
    for (1 .. FAIL) {
        my $x = _ 5;
        my $y = _ 5, 10;
        redo if $cache {"$x-$y"} ++;
        push @failures => "$x-$y";
    }

    # Too many extensions.
    for (1 .. FAIL) {
        my $x = _ 5;
        my $y = _ 4;
        my $z = _ 4;
        redo if $cache {"$x-$y-$z"} ++;
        push @failures => "$x-$y-$z";
    }

    # Wrong separator.
    for (1 .. FAIL) {
        my $x = _ 5;
        my $y = _ 4;
        my $s = int rand 256;
        redo if ($s & 0x7F) < 0x20;
        my $sep = chr $s;
        redo if $sep eq '-' || $sep eq ' ';
        redo if $cache {"$x$sep$y"} ++;
        push @failures => "$x$sep$y";
    }

    # No separator;
    for (1 .. FAIL) {
        my $x = _ 5;
        my $y = _ 4;
        redo if $cache {"$x$y"} ++;
        push @failures => "$x$y";
    }

    # Same failures, with country in front of it as well.
    push @failures => map {"US-$_"} @failures;

    # Wrong countries.
    for (1 .. FAIL) {
        my $c = join "" => map {('A' .. 'Z') [rand 26]} 1 .. 2;
        redo if $c eq "US" || $cache {$c} ++;
        my $x = _ 5;
        push @failures => "$c-$x";
    }

    for (1 .. FAIL) {
        my $c = join "" => map {('A' .. 'Z') [rand 26]} 1 .. 2;
        redo if $c eq "US" || $cache {$c} ++;
        my $x = _ 5;
        my $y = _ 4;
        push @failures => "$c-$x-$y";
    }

    for (1 .. FAIL) {
        my $c = ('A' .. 'Z') [rand 26];
        redo if $cache {$c} ++;
        my $x = _ 5;
        push @failures => "${c}US-$x";
        push @failures => "US$c-$x" unless $c eq 'A';
    }

    for (1 .. 1) {
        my $x = _ 5;
        push @failures => "us-$x";
    }

    for (1 .. 1) {
        my $x = _ 5;
        my $y = _ 4;
        push @failures => "us-$x-$y";
    }

    @failures;
}

__END__


=pod

 $Log: us.t,v $
 Revision 2.102  2003/02/05 09:54:15  abigail
 Removed 'use Config'

 Revision 2.101  2003/02/02 03:11:20  abigail
 File moved to t/URI

 Revision 2.100  2003/01/21 23:19:13  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.5  2003/01/16 11:03:10  abigail
 Added version checks.

 Revision 1.4  2003/01/13 19:45:04  abigail
 Added tests for -country

 Revision 1.3  2003/01/05 02:14:15  abigail
 Small changes.

 Revision 1.2  2003/01/04 23:33:45  abigail
 Almost completely rewritten.

 Revision 1.1  2003/01/01 14:55:11  abigail
 Tests for US zip codes


=cut

__DATA__
