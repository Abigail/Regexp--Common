#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;
use Config;

$^W = 1;

($VERSION) = q $Revision: 2.100 $ =~ /[\d.]+/;

sub passes;
sub failures;

my $http  = $RE {URI} {HTTP};
my $https = $http -> {-scheme => 'https'};
my $keep  = $http -> {-keep};

my %tests = (
    http    => [$http    =>  [qw /1 0/]],
    https   => [$https   =>  [qw /0 1/]],
);


my @passes   = passes;
my @failures = failures;

my $count;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

my $c = 0;
my $s = 0;
while (my ($name, $test) = each %tests) {
    $c ++ foreach grep {$_} @{$test -> [1]};
    $s ++ foreach           @{$test -> [1]};
}

my $max  = 1;
   $max += @passes * $s;
   $max += @passes * $c;
   $max += @failures;
print "1..$max\n";

print "not " unless defined $Regexp::Common::URI::VERSION;
print "ok ", ++ $count, " - Regexp::Common::URI::VERSION\n";

sub uri {
    my ($scheme, $host, $port, $path, $query) = ($_ [0], @{$_ [1]});

    my $uri  = "$scheme://$host";
       $uri .= ":$port"  if defined $port;
       $uri .= "/$path"  if defined $path;
       $uri .= "?$query" if defined $query && defined $path;

    $uri;
}


sub run_test {
    my ($name, $re, $should_match) = @_;
    my $match = "<<$_>>" =~ /$re/;
    my $good  = $match && $_ eq $&;
    my $line  = $good ? "match" : $match ? "wrong match (got: $&)" : "no match";
       $line .= "; $name";
    if ($should_match) {$good  ? pass $line : fail $line}
    else               {$match ? fail $line : pass $line}
}

sub array_cmp {
    my ($a1, $a2) = @_;
    return 0 unless @$a1 eq @$a2;
    foreach my $i (0 .. $#$a1) {
       !defined $$a1 [$i] && !defined $$a2 [$i] ||
        defined $$a1 [$i] &&  defined $$a2 [$i] && $$a1 [$i] eq $$a2 [$i]
        or return 0;
    }
    return 1;
}

sub __ {map {defined () ? $_ : "UNDEF"} @_}
sub run_keep {
    my ($name, $re, $parts, $scheme) = @_;

    my @chunks = /^$re->{-keep}$/;
    unless (@chunks) {fail "no match; $name - keep"; return}

    my $abs  = $parts -> [2];
       $abs .= "?$parts->[3]" if defined $abs && defined $parts -> [3];

    my @wanted;
       $wanted [0] = $_;
       $wanted [1] = $scheme;
       $wanted [2] = $parts -> [0];
       $wanted [3] = $parts -> [1];
       $wanted [4] = "/$abs" if defined $abs;
       $wanted [5] =   $abs  if defined $abs;
       $wanted [6] = $parts -> [2];
       $wanted [7] = undef;
       $wanted [7] = $parts -> [3] if defined $parts -> [2];

    array_cmp (\@chunks, \@wanted) ? pass "match"
                                   : fail "wrong match [@{[__ @chunks]}]"
}

foreach my $pass (@passes) {
    my %uri;

    $uri {http}  = uri http  => $pass;
    $uri {https} = uri https => $pass;

    my $c = 0;
    foreach my $scheme (qw /http https/) {
        local $_ = $uri {$scheme};
        foreach my $name (qw /http https/) {
            my ($re, $matches) = @{$tests {$name}};
            run_test $name, $re, $matches -> [$c];
            run_keep $name, $re, $pass, $scheme if $matches -> [$c];
        }
        $c ++;
    }

}


foreach my $failure (@failures) {
    local $_ = uri http => $failure;
    /^$http$/ ? fail "match; http" : pass "no match; http";
}


exit;


sub cross {
    my @r = [];
       @r = map {my $s = $_; map {[@$_ => $s]} @r} @$_ for @_;
       @r
}


sub passes {
    my @hosts = split /\n/ => << '--';
www.abigail.nl
www.perl.com
www.PERL.com
a.b.c.d.e.f.g.h.i.j.k.x
w-w-w.abigail.nl
w--w--w.abigail.nl
w3.abigail.nl
--

    my @ports = qw /80 8080 12345/;

    my @paths = split /\n/ => << '--';
foo
foo/bar
foo/bar/baz/bingo
foo%00bar
foo%EFbar
%12%34%E6%7B
%12%34/%E6%7B
%12%34%E6%7B/foo
()()
fnurd&.!~@
&.!~@
--

    my @queries = split /\n/ => << '--';
hubba
fnurd=many&woozle=yes
%3E%FF
barra?femmy??dopey
--

    push @ports   => undef, "";
    push @paths   => undef, "";
    push @queries => undef, "";

    my @passes = cross \@hosts, \@ports, \@paths, \@queries;

    @passes = grep {defined $$_ [2] || !defined $$_ [3]} @passes;

    return @passes;
}


sub failures {
    my @badhosts = split /\n/ => << '--';
www.example..com
w+w.example.com
w--.example.com
-w.example.com
www.example.1com
--

    my @hosts = split /\n/ => << '--';
www.example.com
alexandra.abigail.nl
WWW.example.COM
--

    my @badports = qw /-19 : port/;
    my @ports    = qw /80/;

    my @badpaths = split /\n/ => << '--';
foo<>
foo<>bar
#hubba
%GGfoo
foo%F
%FOfoo
--
    my @paths = split /\n/ => << '--';
one
one/two/three
o%6Ee
--

    my @badqueries = split /\n/ => << '--';
query#
#query
qu#ry
--

    my @queries = split /\n/ => << '--';
query
--

    push @ports    => undef, "";
    push @paths    => undef, "";
    push @queries  => undef, "";

    my @failures;

    push @failures => cross \@badhosts, \@ports, \@paths, \@queries;
    push @failures => cross \@hosts, \@badports, \@paths, \@queries;
    push @failures => cross \@hosts, \@ports, \@badpaths, \@queries;
    push @failures => cross \@hosts, \@ports, \@paths, \@badqueries;

    @failures = grep {defined $$_ [2] || !defined $$_ [3]} @failures;

    return @failures;
}


__END__

$Log: test_uri_http.t,v $
Revision 2.100  2003/01/21 23:19:13  abigail
The whole world understands RCS/CVS version numbers, that 1.9 is an
older version than 1.10. Except CPAN. Curse the idiot(s) who think
that version numbers are floats (in which universe do floats have
more than one decimal dot?).
Everything is bumped to version 2.100 because CPAN couldn't deal
with the fact one file had version 1.10.

Revision 1.2  2003/01/21 22:56:48  abigail
Complete remake. 15k+ tests.

Revision 1.1  2002/08/05 12:23:55  abigail
Moved tests for FTP and HTTP URIs to separate files.
