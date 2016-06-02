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
    pattern       =>  $RE {zip} {Australia},
    keep_pattern  =>  $RE {zip} {Australia} {-keep},
    name          => "Australian zip codes",
);

my $Test_none = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {zip} {Australia} {-prefix => 'no'},
    keep_pattern  =>  $RE {zip} {Australia} {-prefix => 'no'} {-keep},
    name          => "Australian zip codes (no prefix allowed)",
);

my $Test_iso = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {zip} {Australia} {-prefix  => 'yes'}
                                            {-country => 'iso'},
    keep_pattern  =>  $RE {zip} {Australia} {-prefix  => 'yes'}
                                            {-country => 'iso'} {-keep},
    name          => "Australian zip codes (ISO prefix required)",
);

my $Test_cept = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {zip} {Australia} {-prefix  => 'yes'}
                                            {-country => 'cept'},
    keep_pattern  =>  $RE {zip} {Australia} {-prefix  => 'yes'}
                                            {-country => 'cept'} {-keep},
    name          => "Australian zip codes (CEPT prefix required)",
);

my @valid = ("0909", 1445, 3500, 9726);   # Some selection.

my $ISO  = "AU";
my $CEPT = "AUS";

foreach my $zip (@valid) {
    #
    # No prefix
    #
    $Test      ->    match ($zip,
                           [$zip, undef, $zip],
                           test => "No prefix");
    $Test_none ->    match ($zip,
                           [$zip, undef, $zip],
                           test => "No prefix");
    $Test_iso  -> no_match ($zip, reason => "No prefix present");
    $Test_cept -> no_match ($zip, reason => "No prefix present");

    #
    # Can we prefix the zip code?
    #
    my $zip_iso  = "$ISO-$zip";
    my $zip_cept = "$CEPT-$zip";

    # 
    # ISO prefix
    #
    $Test      ->    match ($zip_iso,
                           [$zip_iso, $ISO, $zip],
                           test => "Use ISO prefix");
    $Test_none -> no_match ($zip_iso, reason => "Prefix used");
    $Test_iso  ->    match ($zip_iso,
                           [$zip_iso, $ISO, $zip],
                           test => "Use ISO prefix");
    $Test_cept -> no_match ($zip_iso, reason => "ISO prefix used");

    # 
    # CEPT prefix
    #
    $Test      ->    match ($zip_cept,
                           [$zip_cept, $CEPT, $zip],
                           test => "Use CEPT prefix");
    $Test_none -> no_match ($zip_cept, reason => "Prefix used");
    $Test_iso  -> no_match ($zip_cept, reason => "CEPT prefix used");
    $Test_cept ->    match ($zip_cept,
                           [$zip_cept, $CEPT, $zip],
                           test => "Use CEPT prefix");

    #
    # An illegal prefix should never match
    #
    my $zip_illegal = "DE-$zip";
    $Test      -> no_match ($zip_illegal, reason => "Illegal prefix used");
    $Test_none -> no_match ($zip_illegal, reason => "Illegal prefix used");
    $Test_iso  -> no_match ($zip_illegal, reason => "Illegal prefix used");
    $Test_cept -> no_match ($zip_illegal, reason => "Illegal prefix used");
}


done_testing;
