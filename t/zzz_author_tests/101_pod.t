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

eval "use Test::Pod 1.00; 1" or
      plan (skip_all => "Test::Pod required for testing POD");

all_pod_files_ok ();


__END__
