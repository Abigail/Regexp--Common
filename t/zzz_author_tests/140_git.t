#!/usr/bin/perl

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More;

unless (-f ".git/config") {
    plan skip_all => "This is not a git repository";
    exit;
}

undef $ENV {PATH};
my ($GIT)  = grep {-x} qw [/opt/git/bin/git /opt/local/bin/git];
my ($HEAD) = grep {-x} qw [/usr/bin/head];

my @output = `$GIT status --porcelain`;

diag @output;
ok @output == 0, "All files are checked in";

my @tags = sort grep {/^release/} `$GIT tag`;

chomp (my $final_tag = $tags [-1]);

my $changes_line = `$HEAD -1 Changes`;

ok $final_tag    && 
   $changes_line &&
   $final_tag eq "release-" . ($changes_line =~ /^Version ([0-9]{10})/) [0],
   "git tag matches version";


done_testing;
