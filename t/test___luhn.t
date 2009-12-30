#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;
use Regexp::Common::_support qw /luhn/;

use warnings;


my $TESTS = 100;

my @good = qw /49927398716 00000000000/;

my @bad  = qw /49927398717 49927398715/;


# Generate a bunch of valid, and invalid, numbers.
my %cache;
foreach (1 .. $TESTS) {
    my $length = 1 + int rand (1 > rand 10 ? 100 : 20);
    my $s      = join "" => map {int rand 10} 1 .. $length;
    redo if $cache {$s} ++;
    my $even   = 1;
    my $sum    = 0;
    foreach my $n (split // => $s) {
        $n   *= 2 if $even;
        $sum += ($n % 10) + int ($n / 10);
        $even = !$even;
    }
    my $c = $sum % 10 ? 10 - ($sum % 10) : 0;
    my $d = $c;
       $d = int rand 10 while $d == $c;
    my $g = reverse ($s) . $c;
    my $b = reverse ($s) . $d;
    push @good => $g;
    push @bad  => $b;
}



my $total = @good + @bad;

print "1..$total\n";

my $c = 0;

foreach my $g (@good) {
    print "not " unless luhn $g;
    print "ok ", ++ $c, " # luhn ($g)\n";
}

foreach my $b (@bad) {
    print "not " if luhn $b;
    print "ok ", ++ $c, " # !luhn ($b)\n";
}


__END__
