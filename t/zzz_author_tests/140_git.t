#!/usr/bin/perl

BEGIN {
    unless ( $ENV{AUTHOR_TESTING} ) {
        print "1..0 # SKIP AUTHOR test\n";
        exit;
    }
}

use 5.10.0;
use strict;
use warnings;
use Test::More;
use File::Which;

unless ( -f '.git/config' ) {
    plan skip_all => 'This is not a git repository';
    exit;
}

my ($GIT)  = which 'git';
my ($HEAD) = which 'head';

my @output = `$GIT status --porcelain`;

diag @output;
is scalar @output, 0, 'All files are checked in';

my @tags      = sort grep { /^release/ } `$GIT tag`;
my $final_tag = $tags[-1];

defined $final_tag or BAIL_OUT('no final tag available');
chomp $final_tag;

my $changes_line = `$HEAD -1 Changes`;

ok $final_tag
  && $changes_line
  && $final_tag eq 'release-' . ( $changes_line =~ /^Version ([0-9]{10})/ )[0],
  'git tag matches version';

done_testing;
