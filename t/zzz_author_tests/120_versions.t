#!/usr/bin/perl

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More;


sub version;

#
# For a minute or two, I considered using File::Find. 
#
# Henry Spencer was right:
#
#   "Those who don't understand Unix are condemned to reinvent it, poorly."
#

undef $ENV {PATH};
my $FIND = "/usr/bin/find";

my $top   = -d "blib" ? "blib/lib" : "lib";
my @files = `$FIND $top -name [a-zA-Z_]*.pm`;
chomp @files;

say "$top/Regexp/Common.pm";

my $main_version = version "$top/Regexp/Common.pm";
unless ($main_version) {
    fail "Cannot find a version in main file";
    done_testing;
    exit;
}

pass "Got a VERSION declaration in main file";

foreach my $file (@files, "README") {
    my $base = $file;
       $base =~ s!^.*/!!;
    #
    # Grab version
    #
    my $version = version $file;

    unless ($version) {
        fail "Did not find a version in $base; skipping tests";
        next;
    }

    pass "Found version $version in $base";

    if ($version eq $main_version) {
        is $version, $main_version, "Version in $base matches package version"
    }
}

my %monthmap = qw [Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06
                   Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12];

if (open my $fh, "<", "Changes") {
    my $first = <$fh>;
    if ($first =~
       /^Version ([0-9]{10}) \S+ (\S+) +([0-9]{0,2}) \S+ \S+ ([0-9]{4})/) {
        my ($version, $month, $date, $year) = ($1, $2, $3, $4);
        pass "Version line in Changes file formatted ok";
        my $target = sprintf "%04d%02d%02d" => $year, $monthmap {$month}, $date;
        is substr ($version, 0, 8), $target => "      Version and date match";
        is $version, $main_version => "      Version matches package version";
    }
    else {
      SKIP: {
        fail "First line of Changes files correctly formatted: $first";
        skip "Cannot extract a correctly formatted version", 2;
    }}
}
else {
  SKIP: {
    fail "Failed to open Changes file: $!";
    skip "Cannot open Changes file", 2;
}}

done_testing;

sub version {
    my $file = shift;
    open my $fh, "<", $file or return;
    while (<$fh>) {
        return $1 if /^(?:our )?\$VERSION = '([0-9]{10})';$/;
        return $1 if /Release of version ([0-9]{10}) /;      # README
    }
    return;
}


__END__
