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


test_zips country         =>  "San Marino",
          name            =>  "San Marino zip codes",
          prefix          => {
              iso         =>  "SM",
              cept        =>  "SM",
              invalid     =>  "IT",
          },
          prefix_test_set => [47892, 47897],
;


done_testing;


sub valid_zip_codes {
    47890 .. 47899
}


__END__
