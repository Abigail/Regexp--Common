#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;
use warnings;


my @tests__ = ("", "\n", "hello, world");

my %tests_t = (
    "{1,1}" => [qw [y yes Y YES YeLLow]],
    "{0,0}" => [qw [n no  N NO  Nano]],
    "{0,1}" => [qw [R blue maroon], "\n", "", " ", undef, "\nn"],
);

#
# Cut and paste from Regexp::Common::zip
#
my %code = (
    Austria           =>  [qw /AU?T AT AUT/],
    Australia         =>  [qw /AUS? AU AUS/],
    Belgium           =>  [qw /BE?  BE B/],
    Denmark           =>  [qw /DK   DK DK/],
    France            =>  [qw /FR?  FR F/],
    Germany           =>  [qw /DE?  DE D/],
    Greenland         =>  [qw /GL   GL GL/],
    Italy             =>  [qw /IT?  IT I/],
    Netherlands       =>  [qw /NL   NL NL/],
    Norway            =>  [qw /NO?  NO N/],
    Spain             =>  [qw /ES?  ES E/],
    USA               =>  [qw /USA? US USA/],
);

my $tests  = @tests__ + 2;
   $tests += @$_ for values %tests_t;
   $tests +=  1;
   $tests +=  keys %code;

print "1..$tests\n";

my $count = 0;

#
# Test the __ subroutine.
#

foreach my $test (@tests__) {
    my $ret = Regexp::Common::zip::__ $test;
    printf "%s %d\n" => defined $ret && $ret eq $test ? "ok" : "not ok",
                        ++ $count;
}

my $ret1 = Regexp::Common::zip::__ undef;
my $ret2 = Regexp::Common::zip::__;
printf "%s %d\n" => defined $ret1 && $ret1 eq "" ? "ok" : "not ok", ++ $count;
printf "%s %d\n" => defined $ret2 && $ret2 eq "" ? "ok" : "not ok", ++ $count;

#
# Test the _t subroutine
#
while (my ($ret, $tests) = each %tests_t) {
    foreach my $test (@$tests) {
        my $r = Regexp::Common::zip::_t $test;
        printf "%s %d\n" => defined $r && $r eq $ret ? "ok" : "not ok",
                ++ $count;
    }
}
my $r = Regexp::Common::zip::_t;
printf "%s %d\n" => defined $r && $r eq "{0,1}" ? "ok" : "not ok",
                ++ $count;


#
# Test the _c subroutine - we don't have to test all the possible
# returned values - that's already done from the various country
# specific tests. In fact, all we need to test is giving an
# undefined second parameter.
#

while (my ($name, $codes) = each %code) {
    my $r = Regexp::Common::zip::_c $name;

    printf "%s %d\n" => defined $r && $r eq $$codes [0] ? "ok" : "not ok",
            ++ $count;
}


__END__
