package t::zip::Zip;

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Exporter ();

our @EXPORT = qw [test_zips];
our @ISA    = qw [Exporter];

use Regexp::Common;

#
# A method to test a common situation for zip codes
#
sub test_zips {
    my (%args) = @_;
    my ($call_pkg) = caller;

    #
    # Fetch the valid zip codes
    #
    my @valid   = $call_pkg -> valid_zip_codes;
    my %valid   = map {$_ => 1} @valid;

    my $length  = length $valid [0];
    my $from    = "0" x $length;
    my $to      = "9" x $length;

    my $country = $args {country};
    my $name    = $args {name};

    my $Test = Test::Regexp:: -> new -> init (
        pattern       =>  $RE {zip} {$country},
        keep_pattern  =>  $RE {zip} {$country} {-keep},
        name          =>  $name,
    );

    #
    # Test whether zip codes are valid or not
    #
    foreach my $zip ($from .. $to) {
        if ($valid {$zip}) {
            $Test -> match ($zip,
                           [$zip, undef, $zip],
                           test => "Postal code $zip");
        }
        else {
            $Test -> no_match ($zip, reason => "Invalid zip code $zip");
        }
    }


    my @test_set = ($valid [0],
                    @{$args {prefix_test_set} || []},
                    $valid [-1]);


    #
    # Test illegal things
    #
    $Test -> no_match ("", reason => "Empty string should not match");
    foreach my $zip (@test_set) {
        $Test -> no_match (" $zip", reason => "Leading garbage not allowed");
        $Test -> no_match ("$zip ", reason => "Trailing garbage not allowed");
    }

    #
    # Test prefixes
    #

    my $prefix_iso     = $args {prefix} {iso};
    my $prefix_cept    = $args {prefix} {cept};
    my $prefix_invalid = $args {prefix} {invalid};

    my $Test_none = Test::Regexp:: -> new -> init (
        pattern       =>  $RE {zip} {$country} {-prefix  => 'no'},
        keep_pattern  =>  $RE {zip} {$country} {-prefix  => 'no'} {-keep},
        name          => "$name (no prefix allowed)",
    );

    my $Test_iso   = Test::Regexp:: -> new -> init (
        pattern       =>  $RE {zip} {$country} {-prefix  => 'yes'}
                                               {-country => 'iso'},
        keep_pattern  =>  $RE {zip} {$country} {-prefix  => 'yes'}
                                               {-country => 'iso'} {-keep},
        name          => "$name (ISO prefix required)",
    );

    my $Test_cept  = Test::Regexp:: -> new -> init (
        pattern       =>  $RE {zip} {$country} {-prefix  => 'yes'}
                                               {-country => 'cept'},
        keep_pattern  =>  $RE {zip} {$country} {-prefix  => 'yes'}
                                               {-country => 'cept'} {-keep},
        name          => "$name (CEPT prefix required)",
    );

    foreach my $zip (@test_set) {
        #
        # No prefix
        #
        $Test_none -> match ($zip, 
                            [$zip, undef, $zip],
                            test => "No prefix used");
        $Test_iso  -> no_match ($zip, reason => "No prefix used");
        $Test_cept -> no_match ($zip, reason => "No prefix used");


        #
        # ISO prefix
        #
        my $iso_zip = "$prefix_iso-$zip";
        $Test      ->    match ($iso_zip,
                               [$iso_zip, $prefix_iso, $zip],
                                 test => "Use ISO prefix");
        $Test_none -> no_match ($iso_zip, reason => "Prefix not allowed");
        $Test_iso  ->    match ($iso_zip,
                               [$iso_zip, $prefix_iso, $zip],
                                 test => "Use ISO prefix");

        if ($prefix_iso ne $prefix_cept) {
            $Test_none -> no_match ($iso_zip,
                                     reason => "ISO prefix not allowed");
        }

        #
        # CEPT prefix
        #
        my $cept_zip = "$prefix_cept-$zip";
        $Test      ->    match ($cept_zip,
                               [$cept_zip, $prefix_cept, $zip],
                                 test => "Use CEPT prefix");
        $Test_none -> no_match ($cept_zip, reason => "Prefix not allowed");

        if ($prefix_iso ne $prefix_cept) {
            $Test_iso  -> no_match ($cept_zip,
                                     reason => "CEPT prefix not allowed");
        }

        $Test_cept ->    match ($cept_zip,
                               [$cept_zip, $prefix_cept, $zip],
                                 test => "Use CEPT prefix");

        my $invalid_zip = "$prefix_invalid-$zip";
        foreach my $test ($Test, $Test_none, $Test_iso, $Test_cept) {
            $test -> no_match ("$prefix_invalid-$zip",
                                reason => "Invalid prefix");
        }
    }
}


1;


__END__
