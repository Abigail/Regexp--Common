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

sub make_test {
    my ($name, $base, @options) = @_;
    my $pat = $base;
    while (@options) {
        my $opt = shift @options;
        if (@options && $options [0] !~ /^-/) {
            my $val = shift @options;
            $pat = $$pat {$opt => $val};
            $name .= ", $opt => $val";
        }
        else {
            $pat = $$pat {$opt};
            $name .= ", $opt";
        }
    }
    my $keep = $$pat {-keep};
    Test::Regexp:: -> new -> init (
        pattern      => $pat,
        keep_pattern => $keep,
        name         => $name,
    );
}

my $pattern_c = make_test "Integer pattern" => $RE {num} {int},
                                               -sep => ",";
my $pattern_u = make_test "Integer pattern" => $RE {num} {int},
                                               -sep => "_";

my @pass_numbers = qw [
    0 00 000 123 45 6
    123,456 78,901 2,345
    0,000,000,000,000,000,000,000,000,000,000,000,000
    00,000,000,000,000,000,000,000,000,000,000,000,000
    000,000,000,000,000,000,000,000,000,000,000,000,000
    5,098,145,984,398,345 2,831,471,982 38,247,113,284,912 7,312,834
    8,732,123,847,132 45,884,573 99,234,759,141 27,348,134,581 214,357,191 
];


foreach my $number (@pass_numbers) {
    my $sep_c = $number =~ y/,/,/;
    my $test  = $sep_c == 0 ? "No separator"
              : $sep_c == 1 ? "Single separator"
              :               "Multiple separators";
    $pattern_c -> match (  $number  => [  $number,  "",  $number],
                            test => $test);
    $pattern_c -> match ("-$number" => ["-$number", "-", $number],
                            test => "$test, signed (-)");
    $pattern_c -> match ("+$number" => ["+$number", "+", $number],
                            test => "$test, signed (+)");

    $number =~ s/,/_/g;
    $pattern_u -> match (  $number  => [  $number,  "",  $number],
                            test => $test);
    $pattern_u -> match ("-$number" => ["-$number", "-", $number],
                            test => "$test, signed (-)");
    $pattern_u -> match ("+$number" => ["+$number", "+", $number],
                            test => "$test, signed (+)");
}


my @failures = (
    ["Wrong separator"    => qw [0.000 1,234_456,789], "100 123"],
    ["Leading separator"  => qw [,123 ,456,789]],
    ["Trailing separator" => qw [123, 456,789,]],
    ["Double separator"   => qw [0,,000 123,456,,789]],
    ["No digits"          => qw [, ,,]],
    ["Wrong number of digits in group" 
                          => qw [1,23,456 1,2345,678 489,1234,345,169,000]],
    ["Wrong number of digits in last group" 
                          => qw [123,4567 456,78]],
    ["Too many leading digits"
                          => qw [1234,567 0000,000,000 8129132412341,000]],
    ["Trailing garbage"   => qw [123,456,789foo 000,bar], "123,456 ",
                                "987,543,611\n"],
    ["Leading garbage"    => qw [baz,123,456 qux,000], " 123,456"],
    ["Inner garbage"      => qw [123,foo,456 1a3,456], "123, 456"],
    ["Empty string"       => ""],
    ["Garbage"            => "wibble", "\n", "foo,123,bar"],
);

foreach my $failure (@failures) {
    my ($reason, @subjects) = @$failure;
    foreach my $subject (@subjects) {
        $pattern_c -> no_match ($subject, reason => $reason);
    }
}



done_testing ();


__END__
