#!/usr/bin/perl

#
# Test for the support functions of Regexp::Common::number
#

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

my @wrong_bases   = (0, 40);
my @correct_bases = (1, 29, 36);
my @types         = qw /decimal real/;

my $tests = (@wrong_bases + @correct_bases) * @types;
my $count = 0;

print "1..$tests\n";

foreach my $base (@wrong_bases) {
    foreach my $type (@types) {
        eval {"" =~ $RE {num} {$type} {-base => $base}};
        printf "%s %d - \$RE {num} {$type} {-base => $base}\n" =>
                $@ && $@ =~ /Base must be between 1 and 36/ ? "ok" : "not ok",
                ++ $count;
    }
}

foreach my $base (@correct_bases) {
    foreach my $type (@types) {
        eval {"" =~ $RE {num} {$type} {-base => $base}};
        printf "%s %d - \$RE {num} {$type} {-base => $base}\n" =>
                $@ ? "not ok" : "ok", ++ $count;
    }
}


__END__
