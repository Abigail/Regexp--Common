#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;
use Config;

$^W = 1;

($VERSION) = q $Revision: 1.1 $ =~ /[\d.]+/;

my $count;

my $tv         = qr /^$RE{URI}{tv}$/;
my $keep       = qr /^$RE{URI}{tv}{-keep}$/;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

my (@hosts, @failures);
while (<DATA>) {
    chomp;
    last unless /\S/;
    push @hosts => $_;
}
push @hosts => "";

while (<DATA>) {
    chomp;
    last unless /\S/;
    push @failures => $_;
}

my $max = 1 + 2 * @hosts + @failures;

print "1..$max\n";

print "not " unless defined $Regexp::Common::URI::VERSION;
print "ok ", ++ $count, ' - $Regexp::Common::URI::VERSION', "\n";

# print "$fail\n"; exit;

foreach my $host (@hosts) {
    local $_ = "tv:$host";
    /$tv/   ? pass "match" : fail "no match";
    /$keep/ ? $1 eq $_ && $2 eq "tv"
                       && (length $host ? $3 eq $host : !defined $3)
            ? pass "match; keep" : fail "match ($1, $2, $3); keep"
                                 : fail "no match; keep"
}

foreach (@failures) {
    /$tv/   ? fail "match" : pass "no match";
}


=pod

 $Log: test_uri_tv.t,v $
 Revision 1.1  2003/01/01 23:00:33  abigail
 Tests for TV URIs


=cut

__DATA__
wqed.com
nbc.com
abc.com
abc.co.au
east.hbo.com
west.hbo.com
bbc.co.uk

TV:abc.com
abc.com
http:abc.com
tv://abc.com
tv:abc..com
tv:.abc.com
tv:abc-.com
tv:-abc.com
