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
# Combine places and bases
#
my $min         = 3;
my $max         = 6;
my $pattern     = make_test "Integer pattern" =>
                             $RE {num} {int}, -base   => 4,
                                              -places => "$min,$max";
my $pattern_neg = make_test "Integer pattern" =>
                             $RE {num} {int}, -base   => 4,
                                              -places => "$min,$max",
                                              -sign   => '[-]';


my @numbers;

push @numbers => map {"0" x $_} 1 .. 7;
push @numbers => qw [
    1201201 21013 120 123100 3210310 1231231013 2130130 2130 31230 
    13012302 13130
];


foreach my $number (@numbers) {
    my $length = length $number;
    if ($length < $min) {
        foreach my $subj ($number, "-$number", "+$number") {
            $pattern     -> no_match ($number, reason => "Number too short");
            $pattern_neg -> no_match ($number, reason => "Number too short");
        }
    }
    elsif ($length > $max) {
        foreach my $subj ($number, "-$number", "+$number") {
            $pattern     -> no_match ($number, reason => "Number too long");
            $pattern_neg -> no_match ($number, reason => "Number too long");
        }
    }
    else {
        $pattern     ->    match ($number, [$number, "", $number],
                                   test => "Number of correct length");
        $pattern_neg -> no_match ($number, reason => "Number not signed");
        $pattern     ->    match ("-$number", ["-$number", "-", $number],
                                     test => "Signed number of correct length");
        $pattern_neg ->    match ("-$number", ["-$number", "-", $number],
                                     test => "Signed number of correct length");
        $pattern     ->    match ("+$number", ["+$number", "+", $number],
                                     test => "Signed number of correct length");
        $pattern_neg -> no_match ($number,
                                   reason => "Number incorrectly signed");
    }
}

my @bad_characters = (
    ["Number contains space", "12 12", "111 1"],
    ["Digit exceeds base",    "1234", "4", "121212124", "9123123123"],
    ["Letter in number",      "123A", "Q", "202O20", "123Z21"],
);
    
foreach my $entry (@bad_characters) {
    my ($reason, @subjs) = @$entry;
    foreach my $subj (@subjs) {
        $pattern     -> no_match ($subj, reason => $reason);
        $pattern_neg -> no_match ($subj, reason => $reason);
    }
}

done_testing ();


__END__
