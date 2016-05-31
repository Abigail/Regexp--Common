#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common;
use Test::More;

use Config;

my $r = eval "require Test::Regexp; 1";

unless ($r) {
    print "1..0 # SKIP Test::Regexp not found\n";
    exit;
}

my $bits64 = $Config {use64bitint};
#
# CPAN testers claim it fails on 5.8.8 and darwin 9.0.
#
$bits64 = 0 if $Config {osname} eq 'darwin' &&
               $Config {osvers} eq '10.0'   && $] == 5.010;
my $MAX_POWER = $bits64 ? 31 : 15;

#
# The {-keep} pattern and the one without {-keep} are identical.
#
my $Test = Test::Regexp:: -> new -> init (
    keep_pattern  =>  $RE {num} {square} {-keep},
    name          => "Square numbers",
);

my @squares = map {$_ * $_} 0 .. 100, map {2 ** $_} 7 .. $MAX_POWER;

foreach my $square (@squares) {
    $Test -> match ($square, [$square], test => "$square is a square");
}

my @not_squares = map {($_ * $_ - 1, $_ * $_ + 1)} 2 .. 100;

{
    my $max_root   =  $bits64 ? 3037000499 : 46340;
    my $max_square =  $max_root * $max_root;
    #
    # The first square bigger than 2^31 - 1/2^63 - 1. Note we use strings
    # and pre-calculated values here, avoiding Perl to use doubles.
    #
    my $big_square =  $bits64 ? "9223372037000250000" : "2147488281";
    $Test ->    match ($max_square, [$max_square], test => "Largest square");
    $Test -> no_match ($big_square, reason => "Square too big");
}

foreach my $not_square (@not_squares) {
    $Test -> no_match ($not_square, reason => "Not a square number");
}

done_testing ();


__END__
