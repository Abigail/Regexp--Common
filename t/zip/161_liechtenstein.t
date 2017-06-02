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


test_zips country         =>  "Liechtenstein",
          name            =>  "Liechtenstein zip codes",
          prefix          => {
              iso         =>  "LI",
              cept        =>  "LIE",
              invalid     =>  "CH",
          },
          prefix_test_set => [9489, 9490],
;


done_testing;


sub valid_zip_codes {
    9485 .. 9498
}


__END__
