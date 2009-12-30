#!/usr/bin/perl

use strict;

eval "use Test::More; 1" or do {
    print "1..0 # SKIP Test::More required\n";
    exit;
};

eval "use Test::Pod 1.00; 1" or
      plan (skip_all => "Test::Pod required for testing POD");

all_pod_files_ok ();


__END__
