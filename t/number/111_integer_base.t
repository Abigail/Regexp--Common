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
# Play with -base.
#
my @bases  = (2, 5, 8, 16, 23, 36);
my %patterns;
my $PLAIN  = 0;
my $SIGNED = 1;
foreach my $base (@bases) {
    my $plain  = make_test "Base $base integer pattern",
                           $RE {num} {int}, -base => $base;
    my $signed = make_test "Base $base integer pattern",
                           $RE {num} {int}, -base => $base, -sign => '[-+]';
    $patterns {$base} = [$plain, $signed];
}

my @chars = (0 .. 9, 'A' .. 'Z');
for (my $i = 0; $i < @chars; $i ++) {
    my $char = $chars [$i];
    foreach my $base (@bases) {
        if ($i < $base) {
            my $subj = $char;
            $patterns {$base} [$PLAIN] -> match (
                $subj, [$subj, "", $char],
                test => "Single character in base"
            );
            $patterns {$base} [$SIGNED] -> no_match (
                $subj, reason => "Not signed"
            );
            $subj = "-$char";
            $patterns {$base} [$PLAIN] -> match (
                $subj, [$subj, "-", $char],
                test => "Signed (-) single character in base",
            );
            $patterns {$base} [$SIGNED] -> match (
                $subj, [$subj, "-", $char],
                test => "Signed (-) single character in base",
            );
            $subj = "+$char";
            $patterns {$base} [$PLAIN] -> match (
                $subj, [$subj, "+", $char],
                test => "Signed (+) single character in base",
            );
            $patterns {$base} [$SIGNED] -> match (
                $subj, [$subj, "+", $char],
                test => "Signed (+) single character in base",
            );
        }
        else {
            for my $subj ($char, "-$char", "+$char") {
                $patterns {$base} [$PLAIN] -> no_match (
                    $subj, reason => "Character '$char' out of base $base"
                )
            }
        }
    }
}

my $numbers = [
    '00', '00000000000000000000',  '0' x 100_000,
    '11', '10101010101010101010', '11010100110100100111',
    '12234', '4321', '1234' x 10_000,
    '00000000000000000000000000000000000000000030000000000000',
    '444444444444444444444444444444444444',
    '1234567', '7654321', '12435147126123471234651263154211451235',
    '412377132477712347716234512374712341541',
    '2378AB21394CFF9932841EFFA9234', 'DEADBEEF', 'BABEFACE',
    '87134F13241', 'FEDCBA9876543210' x 1_000,
    'ASTORYWELLTOLD', 'BETTERL8THENNEVER', '4SALE', 
    'AS08142H5A87SDFYOUY4YR09TWRE7YGUASDFA99Q0ASHNR1KF98QERTOQ2C871C123R',
    'AL0NGSTR1NGR3P34T3DM4NYT1M3S' x 3_000
];
my %numbers_by_base;
NUMBER: foreach my $number (@$numbers) {
    my %buckets;
    $buckets {$_} ++ for split // => $number;
    for (my $i = @chars - 1; $i >= 0; $i --) {
        if ($buckets {$chars [$i]}) {
            push @{$numbers_by_base {$i + 1}} => $number;
            next NUMBER;
        }
    }
}
my @base_numbers = sort {$a <=> $b} keys %numbers_by_base;

foreach my $base (@bases) {
    my ($pattern, $signed_pattern) = @{$patterns {$base}};
    foreach my $base_number (@base_numbers) {
        foreach my $number (@{$numbers_by_base {$base_number}}) {
            my $is_big = length ($number) > 100;
            my $desc_number = $is_big ? "big number" : "number";
            if ($base >= $base_number) {
                my $subj = $number;
                $pattern -> match ($subj, [$subj, "", $number],
                                    test => "Unsigned $desc_number");
                $signed_pattern -> no_match ($subj,
                                   reason => "No sign for $desc_number");
                $subj = "-$number";
                $pattern -> match ($subj, [$subj, "-", $number],
                                    test => "Signed (-) $desc_number");
                $signed_pattern -> match ($subj, [$subj, "-", $number],
                                    test => "Signed (-) $desc_number");
                $subj = "+$number";
                $pattern -> match ($subj, [$subj, "+", $number],
                                    test => "Signed (+) $desc_number");
                $signed_pattern -> match ($subj, [$subj, "+", $number],
                                    test => "Signed (+) $desc_number");
            }
            else {
                foreach my $subj ($number, "-$number", "+$number") {
                    $pattern        -> no_match
                          ($subj, reason => "Out of base characters");
                    $signed_pattern -> no_match
                          ($subj, reason => "Out of base characters");
                }
            }
        }
    }
}



done_testing ();

__END__
