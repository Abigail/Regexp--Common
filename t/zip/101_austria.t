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


test_zips country         =>  "Austria",
          name            =>  "Austrian zip codes",
          prefix          => {
              iso         =>  "AT",
              cept        =>  "AUT",
              invalid     =>  "FR",
          },
          prefix_test_set => [2491, 5114],
;


done_testing;


sub valid_zip_codes {
    1000 .. 1901,
    
    2000 .. 2413,   2421 .. 2425,   2431 .. 2472,   2473 .. 2475,
    2481 .. 2490,   2491,           2492 .. 2881, 
    
    3001 .. 3333,   3334 .. 3335,   3340 .. 3973,
    
    4000 .. 4294,   4300 .. 4303,   4310 .. 4391,   4392,
    4400 .. 4421,   4431 .. 4441,   4442 .. 4481,   4482,
    4483 .. 4985,

    5000 .. 5114,   5120 .. 5145,   5151 .. 5205,   5211 .. 5283,
    5300 .. 5303,   5310 .. 5311,   5321 .. 5351,   5360,
    5400 .. 5771,
    
    6000 .. 6691,   6700 .. 6993,
    
    7000 .. 7413,   7421,           7422 .. 7573,

    8000 .. 8363,   8380 .. 8385,   8401 .. 8993,

    9000 .. 9322,   9323,           9324 .. 9781,   9782,
    9800 .. 9873,   9900 .. 9992,
}


__END__
