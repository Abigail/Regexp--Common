#!/usr/bin/perl

use Test::More;

use strict;
use warnings;
no  warnings 'syntax';

my $garbage = "Debian_CPANTS.txt";

eval "use Test::Kwalitee; 1" or
      plan skip_all => "Test::Kwalitee required to test Kwalitee";

if (-f $garbage) {
    unlink $garbage or die "Failed to clean up $garbage";
}


__END__
