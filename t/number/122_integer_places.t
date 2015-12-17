#!/usr/bin/perl

use strict;

use Regexp::Common;
use Test::More;

my $r = eval "require Test::Regexp; 1";

unless ($r) {
    print "1..0 # SKIP Test::Regexp not found\n";
    exit;
}

#
# Patterns with variable places.
#
my @places = (1, 3, 8, 21, 34);

my %patterns;

for (my $i = 0; $i < @places; $i ++) {
    my $places1 = $places [$i];
    for (my $j = $i + 1; $j < @places; $j ++) {
        my $places2 = $places [$j];
        my $places  = "$places1,$places2";
        my $places_pattern        = Test::Regexp:: -> new -> init (
            pattern        => $RE {num} {int} {-places  => $places},
            keep_pattern   => $RE {num} {int} {-places  => $places} {-keep},
            name           => "Integer pattern, -places => $places",
        );
        my $places_pattern_signed = Test::Regexp:: -> new -> init (
            pattern        => $RE {num} {int} {-places  => $places}
                                              {-sign    => '[-+]'},
            keep_pattern   => $RE {num} {int} {-places  => $places}
                                              {-sign    => '[-+]'} {-keep},
            name           => "Signed integer pattern, -places => $places",
        );
        $patterns {$places1}
                  {$places2} = [$places_pattern, $places_pattern_signed];
    }
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
    for (my $i = 0; $i < @places; $i ++) {
        my $places1 = $places [$i];
        for (my $j = $i + 1; $j < @places; $j ++) {
            my $places2 = $places [$j];
            my ($pattern, $signed_pattern) = @{$patterns {$places1} {$places2}};
            if ($length < $places1) {
                my $reason = "Number too short";
                foreach my $subj ($number, "-$number") {
                    $pattern        -> no_match ($subj, reason => $reason);
                    $signed_pattern -> no_match ($subj, reason => $reason);
                }
            }
            elsif ($length > $places2) {
                my $reason = "Number too long";
                foreach my $subj ($number, "+$number") {
                    $pattern        -> no_match ($subj, reason => $reason);
                    $signed_pattern -> no_match ($subj, reason => $reason);
                }
            }
            else {
                my $reason = "Length within bounds";
                $pattern -> match ($number, [$number, "", $number],
                                    test => $reason);
                $signed_pattern
                         -> no_match ($number, reason => "Number not signed");

                $pattern        -> match ("+$number",
                                         ["+$number", "+", $number],
                                             test => "$reason, signed (+)");
                $signed_pattern -> match ("+$number",
                                         ["+$number", "+", $number],
                                             test => "$reason, signed (+)");
            }
        }
    }
}

done_testing;


__END__
