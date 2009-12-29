#!/usr/bin/perl

use strict;
local $^W = 1;

use Regexp::Common;
use Config;

BEGIN {
    if ($] < 5.008) {
        print "1..1\n";
        print "ok 1\n";
        exit;
    }
}

use constant MAX => 5000;
use constant MAX_INT32 =>         0x7FFFFFFF;
use constant MAX_INT64 => 0x7FFFFFFFFFFFFFFF;
use constant MAX_INT   => $Config {use64bitint} ? MAX_INT64 : MAX_INT32;


my $max = int sqrt (MAX_INT32) + 1 + 2 * (MAX + 1) - int sqrt (MAX + 1);
print "1..$max\n";
print "ok 1\n";

my ($regex, $count);

sub try {
    $regex = qr /^$_[0]$/;
}

# TEST BASE 10

try $RE{num}{square};

my %squares;


$count = 1;
foreach my $n (0 .. sqrt MAX_INT32) {
    my $s = $n * $n;
    $count ++;
    print $s =~ /$regex/ ? "ok" : "not ok";
    print " $count # '$s' should be a square\n";
    $squares {$s} = 1;
}

my %done;
foreach my $n (0 .. MAX) {
    $done {$n} ++;
    next if $squares {$n};
    $count ++;
    print $n =~ /$regex/ ? "not ok" : "ok"; 
    print " $count # '$n' shouldn't be a square\n";
}
foreach my $n (0 .. MAX) {
    my $d = 1 + int rand MAX_INT;
    redo if $squares {$d} or $done {$d} ++;
    $count ++;
    print $d =~ /$regex/ ? "not ok" : "ok";
    print " $count # '$d' shouldn't be a square\n";
}

__END__
