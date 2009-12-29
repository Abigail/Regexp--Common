#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;

$^W = 1;

($VERSION) = q $Revision: 2.102 $ =~ /[\d.]+/;

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

 $Log: tv.t,v $
 Revision 2.102  2003/02/05 16:21:42  abigail
 Removed 'use Config' statement

 Revision 2.101  2003/02/02 03:09:30  abigail
 File moved to t/URI

 Revision 2.100  2003/01/21 23:19:13  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

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
