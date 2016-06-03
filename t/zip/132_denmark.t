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
    pattern       =>  $RE {zip} {Denmark},
    keep_pattern  =>  $RE {zip} {Denmark} {-keep},
    name          => "Danish zip codes",
);

my $Test_none = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {zip} {Denmark} {-prefix => 'no'},
    keep_pattern  =>  $RE {zip} {Denmark} {-prefix => 'no'} {-keep},
    name          => "Danish zip codes (no prefix allowed)",
);

my $Test_iso = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {zip} {Denmark} {-prefix  => 'yes'}
                                          {-country => 'iso'},
    keep_pattern  =>  $RE {zip} {Denmark} {-prefix  => 'yes'}
                                          {-country => 'iso'} {-keep},
    name          => "Danish zip codes (ISO prefix required)",
);

my $Test_cept = Test::Regexp:: -> new -> init (
    pattern       =>  $RE {zip} {Denmark} {-prefix  => 'yes'}
                                          {-country => 'cept'},
    keep_pattern  =>  $RE {zip} {Denmark} {-prefix  => 'yes'}
                                          {-country => 'cept'} {-keep},
    name          => "Danish zip codes (CEPT prefix required)",
);

my @valid = ("0800", 5550, 7100, 9990);   # Some selection.

my $ISO  = "DK";
my $CEPT = "DK";

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
    my $zip_iso  = "$ISO-$zip";  # Same as Cept prefix

    # 
    # ISO/Cept prefix
    #
    $Test      ->    match ($zip_iso,
                           [$zip_iso, $ISO, $zip],
                           test => "Use ISO/Cept prefix");
    $Test_none -> no_match ($zip_iso, reason => "Prefix used");
    $Test_iso  ->    match ($zip_iso,
                           [$zip_iso, $ISO, $zip],
                           test => "Use ISO prefix");
    $Test_cept ->    match ($zip_iso,
                           [$zip_iso, $ISO, $zip],
                           test => "Use ISO prefix");

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
