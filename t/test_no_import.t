# LOAD
BEGIN {print "1..2\n";}

use Regexp::Common qw /no_defaults/;

print "ok 1\n";

# $, = "\n";
# print keys %INC;
# print $,;

print defined &Regexp::Common::URL::pattern ? "not ok 2\n" : "ok 2\n";
