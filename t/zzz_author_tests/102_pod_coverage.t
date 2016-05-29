#!/usr/bin/perl

BEGIN {
    unless ($ENV {AUTHOR_TESTING}) {
        print "1..0 # SKIP AUTHOR test\n";
        exit;
    }
}

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More;


eval "use Test::Pod::Coverage 1.00; 1" or
    plan (skip_all => "Test::Pod::Coverage required for testing POD coverage");

all_pod_coverage_ok ({private => [qr /^/]});


__END__
