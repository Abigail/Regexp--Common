#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common;

my $count = 0;
my $PAT;

END {print "1..$count\n"}

sub try {
    $PAT     = shift;
    my $name = shift;
    print "# $name\n";
}

sub pass {
    my $address = shift;
    my $r = $address =~ /^$PAT/ && $address eq $&;
    printf "%s %d  # Matching %s\n", $r ? "ok" : "not ok", ++ $count, $address;
}

sub fail {
    my $address = shift;
    my $r = $address !~ /^$PAT/ || $address ne $&;
    printf "%s %d  # Failing %s\n", $r ? "ok" : "not ok", ++ $count, $address;
}

sub match {
    my $address = $_ [0];
    my @matches = @_;

    my $r = $address =~ /^$PAT/ && $address eq $&;
    printf "%s %d  # Matching %s\n", $r ? "ok" : "not ok", ++ $count, $address;

    if (!$r) {
        for my $i (0 .. @matches) {
            printf "not ok %d  # SKIP\n" => ++ $count;
        }
        return;
    }

    #
    # Correct number of matches?
    #
    printf "%s %d     # Number of matches\n" =>
           @matches == @- - 1 ? "ok" : "not ok", ++ $count;

    for (my $i = 0; $i < @matches; $i ++) {
        no strict 'refs';
        my $matched = ${$i + 1};
        printf "%s %d     # \$%d eq '%s'\n" =>
               $matched eq $matches [$i] ? "ok" : "not ok",
               ++ $count, $i + 1, $matches [$i];
    }
}



try $RE {net} {IPv6} => '$RE {net} {IPv6}';

pass "2001:0db8:85a3:0000:0000:8a2e:0370:7334";
pass "2001:db8:85a3:0:0:8a2e:370:7334";               # Leading 0's removed
pass "2001:DB8:85A3:0:0:8A2E:370:7334";               # Upper case allowed
pass "2001:Db8:85A3:0:0:8a2E:370:7334";               # Mixed case allowed
pass "2001:db8:85a3::8a2e:370:7334";                  # Contractions
pass "2001:db8::8a2e:370:7334";
pass "2001::8a2e:370:7334";
pass "::8a2e:370:7334";
pass "::370:7334";
pass "::7334";
pass "::";

fail "2001:0db8:85a3:0000:0000:8a2e:0370:7334:1234";  # Too many parts
fail "2001:0db8:85a3:0000:0000:8a2e:0370";            # Not enough parts
fail "20013:db8:85a3:0:0:8a2e:370:7334";              # Part too long
fail "2001:0db8:85a3:0000:0000:8a2e:0370:7334:";      # Trailing separator
fail ":2001:0db8:85a3:0000:0000:8a2e:0370:7334";      # Leading separator
fail "2001:db8:85a3:0::8a2e:370:7334";                # Only one unit removed
fail "2001::8a2e:370::7334";                          # Two contractions
fail "2001:::8a2e:370:7334";                          # Three separators
fail "2001.db8.85a3.0.0.8a2e.370.7334";               # Wrong separator

try $RE {net} {IPv6} {-style => "hex"} => '$RE {net} {IPv6} {-style => "hex"}';

pass "2001:db8:85a3:0:0:8a2e:370:7334";               # Lower case allowed
fail "2001:DB8:85A3:0:0:8A2E:370:7334";               # Upper case not allowed
fail "2001:Db8:85A3:0:0:8a2E:370:7334";               # Mixed case not allowed

try $RE {net} {IPv6} {-style => "HEX"} => '$RE {net} {IPv6} {-style => "HEX"}';

fail "2001:db8:85a3:0:0:8a2e:370:7334";               # Lower case allowed
pass "2001:DB8:85A3:0:0:8A2E:370:7334";               # Upper case not allowed
fail "2001:Db8:85A3:0:0:8a2E:370:7334";               # Mixed case not allowed

try $RE {net} {IPv6} {-sep => "[.]"} => '$RE {net} {IPv6} {-sep => "[.]"}';

pass "2001.db8.85a3.0.0.8a2e.370.7334";               # Lower case allowed
pass "2001.DB8.85A3.0.0.8A2E.370.7334";               # Upper case allowed
fail "2001:db8:85a3:0:0:8a2e:370:7334";               # Fail on default sep


try $RE {net} {IPv6} {-keep} => '$RE {net} {IPv6} {-keep}';

match  "2001:0db8:85a3:0000:0000:8a2e:0370:7334" =>
       "2001", "0db8", "85a3", "0000", "0000", "8a2e", "0370", "7334";
match  "2001:0db8:85a3:0:0:8a2e:0370:7334"       =>
       "2001", "0db8", "85a3",    "0",    "0", "8a2e", "0370", "7334";
match  "2001:db8:85a3:0:0:8a2e:370:7334"         =>
       "2001",  "db8", "85a3",    "0",    "0", "8a2e",  "370", "7334";
match  "2001:db8:85a3::8a2e:370:7334"            =>
       "2001",  "db8", "85a3",     "",     "", "8a2e",  "370", "7334";
match  "2001:db8::8a2e:370:7334"                 =>
       "2001",  "db8",     "",     "",     "", "8a2e",  "370", "7334";
match  "2001::8a2e:370:7334"                     =>
       "2001",     "",     "",     "",     "", "8a2e",  "370", "7334";
match  "::8a2e:370:7334"                         =>
           "",     "",     "",     "",     "", "8a2e",  "370", "7334";
match  "::370:7334"                              =>
           "",     "",     "",     "",     "",     "",  "370", "7334";
match  "::7334"                                  =>
           "",     "",     "",     "",     "",     "",     "", "7334";
match  "::"                                      =>
           "",     "",     "",     "",     "",     "",     "",     "";

fail "2001:0db8:85a3:0000:0000:8a2e:0370:7334:1234";  # Too many parts
fail "2001:0db8:85a3:0000:0000:8a2e:0370";            # Not enough parts
fail "20013:db8:85a3:0:0:8a2e:370:7334";              # Part too long
fail "2001:0db8:85a3:0000:0000:8a2e:0370:7334:";      # Trailing separator
fail ":2001:0db8:85a3:0000:0000:8a2e:0370:7334";      # Leading separator
fail "2001:db8:85a3:0::8a2e:370:7334";                # Only one unit removed
fail "2001::8a2e:370::7334";                          # Two contractions
fail "2001:::8a2e:370:7334";                          # Three separators
fail "2001.db8.85a3.0.0.8a2e.370.7334";               # Wrong separator


try $RE {net} {IPv6} {-style => 'HEX'} {-sep => '[.]'} {-keep} =>
 q [$RE {net} {IPv6} {-style => 'HEX'} {-sep => '[.]'} {-keep}];

match  "2001.DB8.85A3..8A2E.370.7334"         =>
       "2001",  "DB8", "85A3",     "",     "", "8A2E",  "370", "7334";

__END__
