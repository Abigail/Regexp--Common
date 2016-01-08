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

my %patterns = (
    2    => make_test ("Integer pattern" => $RE {num} {int},
                                            -sep => ",", -group =>  2),
    4    => make_test ("Integer pattern" => $RE {num} {int},
                                            -sep => ",", -group =>  4),
    5_7  => make_test ("Integer pattern" => $RE {num} {int},
                                            -sep => ",", -group => "5,7"),
);


my %pass_numbers = (
    2    =>   [qw [0 00 0,00 00,00 1,23,45,67,89 12,34,56,78,90]],
    4    =>   [qw [0 00 000 0000 0,0000 00,0000 
                   1,2345,6789 12,3456,7890 123,0987,6782,1235]],
    5_7  =>   [qw [0 00 000 0000 00000 000000 0000000
                   1,23456 12,3456789 8239317,54321
                   37819,4927658,897423,52904,3906817,34532]],
);
     

foreach my $key (sort {$a cmp $b} keys %patterns) {
    my $pattern = $patterns     {$key};
    my $numbers = $pass_numbers {$key};

    foreach my $number (@$numbers) {
        my $c = $number =~ y/,/,/;
        my $test = $c == 0 ? "No separator"
                 : $c == 1 ? "Single separator"
                 :           "Multiple separators";

        $pattern -> match (  $number  => [  $number,  "",  $number],
                              test => $test);
        $pattern -> match ("-$number" => ["-$number", "-", $number],
                              test => "$test, signed (-)");
        $pattern -> match ("+$number" => ["+$number", "+", $number],
                              test => "$test, signed (+)");
    }
}


my @failures = (
    ["Wrong separator"    => {
        2   =>  [qw [0.00    1,23_46,79],      "10 13"],
        4   =>  [qw [0.0000  1,2345_6789],     "1000 1313"],
        5_7 =>  [qw [0.00000 1,23456_9876543], "10000 131313"],
    }],
    ["Leading separator"  => {
        2   =>  [qw [,123    ,456,789]],
        4   =>  [qw [,1234   ,4567,7890]],
        5_7 =>  [qw [,123456 ,98765,123456]],
    }],
    ["Trailing separator" => {
        2   =>  [qw [123,    456,789,]],
        4   =>  [qw [1234,   4567,1234,]],
        5_7 =>  [qw [123456, 12345,0987654,]],
    }],
    ["Double separator"   => {
        2   =>  [qw [0,,00     23,45,,89]],
        4   =>  [qw [0,,0000   123,4568,,1789]],
        5_7 =>  [qw [0,,000000 123,456654,,789987]],
    }],
    ["No digits"          => {
        2   =>  [qw [, ,,]],
    }],
    ["Wrong number of digits in group" => {
        2   =>  [qw [1,3,45 1,234,78     489,12     1,234,56,78]],
        4   =>  [qw [13,45  1,23478,0000 11489,1212 1,23456,5678]],
        5_7 =>  [qw [13,4589 1,12345678,98765 87654321,12345 123,4567,12345
                     123,456,123456]],
    }],
    ["Wrong number of digits in last group" => {
        2   =>  [qw [12,4 45,678 1,23,456]],
        4   =>  [qw [847,345 983,59025 123,4567,98387]],
        5_7 =>  [qw [12,4567 89353,94768904 1490,49278,98765432]],
    }],
    ["Too many leading digits" => {
        2   =>  [qw [000      123,45 948,89,90,23,24]],
        4   =>  [qw [00000    12345,9489 899421,3890,2940]],
        5_7 =>  [qw [00000000 89478211,904789 95872938,58903,1589387]],
    }],
    ["Trailing garbage"   => {
        2   =>  [qw [00foo 1,23,45,ba], "12,24 ", "12,24\n"],
        4   =>  [qw [0000foo 1,2345,6789,barr], "12,2424 ", "12,2424\n"],
        5_7 =>  [qw [00000foo 1,234567,67890,barrr], "12,242424 ",
                                                     "12,242424\n"],
    }],
    ["Leading garbage"    => {
        2   =>  [qw [f1     foo12,34],       " 12,34"],
        4   =>  [qw [f123   foo1234,4567],   " 1234,5678"],
        5_7 =>  [qw [f12345 foo12340,04567], " 12340,05678"],
    }],
    ["Inner garbage"      => {
        2   =>  [qw [12,fo,56 1a,56], "13, 46"],
        4   =>  [qw [1234,foob,5678 1a23,5678], "1234, 4567"],
        5_7 =>  [qw [12345,foobar,5678901 1a23,45678], "1234, 456789"],
    }],
    ["Empty string"       => {
        2   =>  [""],
        4   =>  [""],
        5_7 =>  [""],
    }],
    ["Garbage"            => {
        2   =>  ["wibble", "\n", "fo,12,ar"],
        4   =>  ["wibble", "\n", "foob,12,barb"],
        5_7 =>  ["wibble", "\n", "foob,12345,barbaz"],
    }],
);

foreach my $failure (@failures) {
    my ($reason, $data) = @$failure;
    foreach my $key (sort {$a cmp $b} keys %$data) {
        my $pattern  = $patterns {$key};
        my $subjects = $$data {$key};
        foreach my $subject (@$subjects) {
            $pattern -> no_match ($subject, reason => $reason);
        }
    }
}



done_testing ();


__END__
