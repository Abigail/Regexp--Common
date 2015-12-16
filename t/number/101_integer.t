#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common qw /RE_num_int/;
use Test::More;

my $r = eval "require Test::Regexp; 1";

unless ($r) {
    print "1..0 # SKIP Test::Regexp not found\n";
    exit;
}

#
# Some basic patterns: plain integers, signed integers, unsigned integers.
#
my $integer = Test::Regexp -> new -> init (
    pattern      =>  $RE {num} {int},
    keep_pattern =>  $RE {num} {int} {-keep},
    name         =>  "Simple integer pattern",
);

my $signed_integer = Test::Regexp -> new -> init (
    pattern      =>  $RE {num} {int} {-sign => '[-+]'},
    keep_pattern =>  $RE {num} {int} {-sign => '[-+]'} {-keep},
    name         =>  "Signed integer pattern",
);
my $unsigned_integer = Test::Regexp -> new -> init (
    pattern      =>  $RE {num} {int} {-sign => ''},
    keep_pattern =>  $RE {num} {int} {-sign => ''} {-keep},
    name         =>  "Unsigned integer pattern",
);


foreach my $digit (0 .. 9) {
    $integer -> match (  $digit,  [  $digit,  "",  $digit],
                          test => "Single digit");
    $integer -> match ("-$digit", ["-$digit", "-", $digit],
                          test => "Single digit, with minus sign");
    $integer -> match ("+$digit", ["+$digit", "+", $digit],
                          test => "Single digit, with plus sign");

    $signed_integer -> no_match ($digit, reason => "No sign");
    $signed_integer -> match ("-$digit", ["-$digit", "-", $digit],
                                 test => "Single digit, with minus sign");
    $signed_integer -> match ("+$digit", ["+$digit", "+", $digit],
                                 test => "Single digit, with plus sign");

    $unsigned_integer -> match (  $digit,  [  $digit,  "",  $digit],
                                   test => "Single digit");
    $unsigned_integer -> no_match ("-$digit", reason => "Number has - sign");
    $unsigned_integer -> no_match ("+$digit", reason => "Number has + sign");
}

foreach my $letter ('A' .. 'Z') {
    my $reason = "Cannot match letters";
    $integer          -> no_match (  $letter,  reason => $reason);
    $integer          -> no_match ("-$letter", reason => $reason);
    $integer          -> no_match ("+$letter", reason => $reason);
    $signed_integer   -> no_match (  $letter,  reason => $reason);
    $signed_integer   -> no_match ("-$letter", reason => $reason);
    $signed_integer   -> no_match ("+$letter", reason => $reason);
    $unsigned_integer -> no_match (  $letter,  reason => $reason);
    $unsigned_integer -> no_match ("-$letter", reason => $reason);
    $unsigned_integer -> no_match ("+$letter", reason => $reason);
}

my @numbers = qw [
    123456789 987654321 00 00000 
    918710985710984523480938457287510917634178356017501984571273461782346
    2109381270129857102931405984051817410923193913810985
    123981098509850493582357010910371947524594785923602871749187249504395
    000000000000000000000000000000000000000000000000000000000000000000000001
    12890991823457 09857109247120 0000000090000000000000009000000000000000
];
my @big_numbers = (
    '123456789' x 100,
    '0' x 10_000,
);
my @failures = (
    [" 12345"       =>  "Leading space"],
    ["123 "         =>  "Trailing space"],
    ["-+1234"       =>  "Double sign"],
    ["--54311"      =>  "Double sign"],
    ["- 897"        =>  "Space after sign"],
    [""             =>  "Empty string"],
    ["-"            =>  "Sign only"],
    ["1234 678"     =>  "Space in number"],
    ["1234+678"     =>  "Sign in number"],
    ["678A90"       =>  "Letter in number"],
    ["0x1234"       =>  "Hex number"],
    ["0b1234"       =>  "Octal number"],
    ["Bla bla"      =>  "Garbage"],
);

foreach my $number (@numbers) {
    $integer -> match (  $number , [  $number , "",  $number],
                          test => "Unsigned number");
    $integer -> match ("-$number", ["-$number", "-", $number],
                          test => "Number with minus sign");
    $integer -> match ("+$number", ["+$number", "+", $number],
                          test => "Number with plus sign");
    $signed_integer -> no_match ($number, reason => "Number is unsigned");
    $signed_integer -> match ("-$number", ["-$number", "-", $number],
                                 test => "Number with minus sign");
    $signed_integer -> match ("+$number", ["+$number", "+", $number],
                                 test => "Number with plus sign");
    $unsigned_integer -> match (  $number , [  $number , "",  $number],
                                   test => "Unsigned number");
    $unsigned_integer -> no_match ("-$number", reason => "Number has - sign");
    $unsigned_integer -> no_match ("+$number", reason => "Number has + sign");
}


foreach my $number (@big_numbers) {
    $integer -> match (  $number , [  $number , "",  $number],
                          test => "Unsigned big number");
    $integer -> match ("-$number", ["-$number", "-", $number],
                          test => "Big number with minus sign");
    $integer -> match ("+$number", ["+$number", "+", $number],
                          test => "Big number with plus sign");
    $signed_integer -> no_match ($number, reason => "Number is unsigned");
    $signed_integer -> match ("-$number", ["-$number", "-", $number],
                                 test => "Big number with minus sign");
    $signed_integer -> match ("+$number", ["+$number", "+", $number],
                                 test => "Big number with plus sign");
    $unsigned_integer -> match (  $number , [  $number , "",  $number],
                                   test => "Unsigned big number");
    $unsigned_integer -> no_match ("-$number", reason => "Number has - sign");
    $unsigned_integer -> no_match ("+$number", reason => "Number has + sign");
}

foreach my $failure (@failures) {
    my ($subject, $reason) = @$failure;
    $integer        -> no_match ($subject, reason => $reason);
    $signed_integer -> no_match ($subject, reason => $reason);
}

done_testing;



__END__
