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


done_testing;


__END__
