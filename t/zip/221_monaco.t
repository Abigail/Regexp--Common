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


test_zips country         =>  "Monaco",
          name            =>  "Monaco zip codes",
          prefix          => {
              iso         =>  "MC",
              cept        =>  "MC",
              invalid     =>  "FR",
          },
          prefix_test_set => [98010, 98088],
;


done_testing;


sub valid_zip_codes {
    98000 .. 98099,
}


__END__
