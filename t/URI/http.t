#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W = 1;


sub create_parts;

my $http  = $RE {URI} {HTTP};
my $https = $http -> {-scheme => 'https'};
my $any   = $http -> {-scheme => 'https?'};

my @tests = (
   [http  => $http  => {http  => NORMAL_PASS | FAIL, https => NORMAL_FAIL}],
   [https => $https => {http  => NORMAL_FAIL, https => NORMAL_PASS | FAIL}],
   [any   => $any   => {http  => NORMAL_PASS, https => NORMAL_PASS}],
);

my ($good, $bad) = create_parts;

run_tests version   =>   "Regexp::Common::URI",
          tests     =>  \@tests,
          good      =>   $good,
          bad       =>   $bad,
          query     =>  \&uri,
          wanted    =>  \&wanted,
          filter    =>  \&filter;

sub uri {
    my ($scheme, $host, $port, $path, $query) = ($_ [0], @{$_ [1]});

    my $uri  = "$scheme://$host";
       $uri .= ":$port"  if defined $port;
       $uri .= "/$path"  if defined $path;
       $uri .= "?$query" if defined $query && defined $path;

    $uri;
}

sub wanted {
    my ($scheme, $parts) = @_;

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

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Hosts.
    $good [0] = [qw /www.abigail.freedom.nl www.PERL.com a.b.c.d.e.f.g.h.i.j.k.x
                     127.0.0.1 w--w--w.abigail.freedom.nl w3.abigail.freedom.nl/];
    $bad  [0] = ["", qw /www.example..com w+w.example.com w--.example.com
                         127.0.1 127.0.0.0.1 -w.example.com www.example.1com/];

    # Ports.
    $good [1] = [undef, "", 80];
    $bad  [1] = [qw /-19 : port/];

    # Paths.
    $good [2] = [undef, "",
                 qw {foo foo/bar/baz/bingo foo%00bar foo%EFbar
                     %12%34%E6%7B %12%34/%E6%7B %12%34%E6%7B/foo
                     ()() fnurd&.!~@}];
    $bad  [2] = [qw {foo<> foo<>bar %GGfoo foo%F %FOfoo}, '#hubba'];
    
    # Queries.
    $good [3] = [undef, "", qw {hubba fnurd=many&woozle=yes
                                %3E%FF barra?femmy??dopey}];
    $bad  [3] = ['query#', '#query', 'qu#ry'];

    return (\@good, \@bad);
}


sub filter {
    return !defined $_ [0] -> [2] && defined $_ [0] -> [3] ? 0 : 1
}


__END__
