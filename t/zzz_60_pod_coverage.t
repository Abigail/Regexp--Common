#!/usr/bin/perl

use strict;

eval "use Test::More; 1" or do {
    print "1..0 # SKIP Test::More required\n";
    exit;
};

eval "use Test::Pod::Coverage 1.00; 1" or
    plan (skip_all => "Test::Pod::Coverage required for testing POD coverage");

all_pod_coverage_ok ({private => [qr /^/]});


__END__
