#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

BEGIN {
    if ($] < 5.010) {
        print "1..1\n";
        print "ok 1  # \$RE {net} {IPv6} requires 5.010\n";
        exit;
    }
}

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


__END__
