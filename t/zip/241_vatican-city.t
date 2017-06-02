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


test_zips country         =>  "Vatican City",
          name            =>  "Vatican City zip codes",
          prefix          => {
              iso         =>  "VA",
              cept        =>  "VA",
              invalid     =>  "CH",
          },
          prefix_test_set => [],
;


done_testing;


sub valid_zip_codes {
    "00120",
}


__END__
