#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common;
use Test::More;

my $r = eval "require Test::Regexp; 1";

unless ($r) {
    print "1..0 # SKIP Test::Regexp not found\n";
    exit;
}

my $Test = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {net} {IPv4} {strict},
    keep_pattern  =>  $RE {net} {IPv4} {strict} {-keep},
    name          => "Strict IPv4 addresses",
);
 

foreach my $number (0 .. 999) {
    my $address = "$number.$number.$number.$number";
    if ($number < 256) {
        $Test -> match ($address,
                       [$address, $number, $number, $number, $number],
                       test => "Accept number $number");
        if ($number < 10) {
            my $address = sprintf "%d.%d.%02d.%d" => ($number) x 4;
            $Test -> no_match ($address, reason => "Leading 0 not allowed");
        }
        if ($number < 100) {
            my $address = sprintf "%d.%03d.%d.%d" => ($number) x 4;
            $Test -> no_match ($address, reason => "Leading 0 not allowed");
        }
    }
    else {
        $Test -> no_match ($address, reason => "Number exceeds 256");
    }
}


$Test -> no_match ("1.2.3.4.5",    reason => "To many octets");
$Test -> no_match ("1.2.3",        reason => "No enough octets");
$Test -> no_match ("12.34.ab.56",  reason => "Non numbers in octets");
$Test -> no_match ("1.1234.2.3",   reason => "Too many digits in octet");
$Test -> no_match ("12:34:45:67",  reason => "Incorrect separator");
$Test -> no_match ("+12.34.56.78", reason => "Garbage before address");
$Test -> no_match ("12.34.56.78 ", reason => "Garbage after address");


done_testing;
