#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use lib ".";

use Regexp::Common;
use Test::More;
use t::zip::Zip;

my $r = eval "require Test::Regexp; 1";

unless ($r) {
    print "1..0 # SKIP Test::Regexp not found\n";
    exit;
}


test_zips country         =>  "Greenland",
          name            =>  "Greenlandic zip codes",
          prefix          => {
              iso         =>  "GL",
              cept        =>  "GL",
              invalid     =>  "DE",
          },
          prefix_test_set => [3940, 3955],
;


done_testing;


sub valid_zip_codes {
    2412,

    3900,   3905,   3910 .. 3913,   3915,           3919 .. 3924,
    3930,   3932,   3940,           3950 .. 3953,   3955,
    3961 .. 3962,   3964,           3970 .. 3972,   3980,   3982,
    3984 .. 3985,   3992,
}


__END__
