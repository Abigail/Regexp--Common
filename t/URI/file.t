#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W = 1;


sub create_parts;

my $file  = $RE {URI} {file};

my @tests = (
   [file  => $file  => {file  => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version   =>   "Regexp::Common::URI::file",
          tests     =>  \@tests,
          good      =>   $good,
          bad       =>   $bad,
          query     =>  \&file,
          wanted    =>  \&wanted;

sub file {
    my ($tag, $host, $path) = ($_ [0], @{$_ [1]});

    my $file  = "file://";
       $file .=  $host    if defined $host;
       $file .= "/$path"  if defined $path;

    $file;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "file";
       $wanted [2]  = $$parts [0];
       $wanted [2] .= "/" . $$parts [1] if defined $$parts [1];
       $wanted [3]  = $$parts [0];
       $wanted [4]  = "/" . $$parts [1] if defined $$parts [1];
       $wanted [5]  = $$parts [1];

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Hosts.
    $good [0] = ["", qw /www.abigail.freedom.nl www.PERL.com a.b.c.d.e.f.g.h.i.j.k.x
                         127.0.0.1 w--w--w.abigail.freedom.nl w3.abigail.freedom.nl/];
    $bad  [0] = [qw /www.example..com w+w.example.com w--.example.com
                     127.0.1 127.0.0.0.1 -w.example.com www.example.1com/];

    # Paths.
    $good [1] = ["", qw {foo foo/bar/baz/bingo foo%00bar foo%EFbar
                         %12%34%E6%7B %12%34/%E6%7B %12%34%E6%7B/foo
                         ()() fnurd&.!@}];
    $bad  [1] = [undef, qw {foo<> foo<>bar ~abigail %GGfoo foo%F %FOfoo},
                '#hubba'];
    
    return (\@good, \@bad);
}


__END__
