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

#
# Patterns with fixed places.
#
my @places = (1, 2, 3, 5, 8, 13, 21, 34);

my %patterns;

foreach my $places (@places) {
    my $places_pattern        = make_test "Integer pattern",
                                $RE {num} {int}, -places => $places;
    my $places_pattern_signed = make_test "Integer pattern",
                                $RE {num} {int}, -places => $places,
                                                 -sign   => '[-+]';

    $patterns {$places} = [$places_pattern, $places_pattern_signed];
}

my @numbers;

push @numbers => map {"0" x $_} 1 .. ($places [-1] + 1);
push @numbers => qw [
    921092 1230981409 1239801 12034009123 120381409 12 098213470
    289341728912098510298571873824712384 129834701 1098240 12349
    3475 897465121 992342199123499195 999999999 12481 598134 23418
    98214510814580 891274102981829570918 981243 1928411 912834
];


foreach my $number (@numbers) {
    my $length = length $number;
    foreach my $places (@places) {
        my ($pattern, $signed_pattern) = @{$patterns {$places}};
        if ($length < $places) {
            my $reason = "Number too short";
            foreach my $subj ($number, "-$number") {
                $pattern        -> no_match ($subj, reason => $reason);
                $signed_pattern -> no_match ($subj, reason => $reason);
            }
        }
        elsif ($length > $places) {
            my $reason = "Number too long";
            foreach my $subj ($number, "+$number") {
                $pattern        -> no_match ($subj, reason => $reason);
                $signed_pattern -> no_match ($subj, reason => $reason);
            }
        }
        else {
            $pattern -> match ($number, [$number, "", $number],
                                test => "Exact length");
            $signed_pattern
                     -> no_match ($number, reason => "Number not signed");

            $pattern        -> match ("-$number", ["-$number", "-", $number],
                                         test => "Exact length, signed (-)");
            $signed_pattern -> match ("-$number", ["-$number", "-", $number],
                                         test => "Exact length, signed (-)");

            $pattern        -> match ("+$number", ["+$number", "+", $number],
                                         test => "Exact length, signed (+)");
            $signed_pattern -> match ("+$number", ["+$number", "+", $number],
                                         test => "Exact length, signed (+)");
        }
    }
}

done_testing ();


__END__
