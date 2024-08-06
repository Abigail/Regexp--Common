#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W = 1;


sub create_parts;

my $nntp  = $RE {URI} {NNTP};

my @tests = (
   [nntp  => $nntp  => {nntp  => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version   =>   "Regexp::Common::URI::news",
          tests     =>  \@tests,
          good      =>   $good,
          bad       =>   $bad,
          query     =>  \&nntp,
          wanted    =>  \&wanted;

sub nntp {
    my ($tag, $host, $port, $group, $digits) = ($_ [0], @{$_ [1]});

    my $nntp  =  "nntp://";
       $nntp .=   $host    if defined $host;
       $nntp .= ":$port"   if defined $port;
       $nntp .= "/$group"  if defined $group;
       $nntp .= "/$digits" if defined $digits;

    $nntp;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "nntp";
       $wanted [2]  = join "/" => grep {defined}
                            join (":" => grep {defined} @$parts [0, 1]),
                                                        @$parts [2, 3];
       $wanted [3]  = join ":" => grep {defined} @$parts [0, 1];
       $wanted [4]  = $$parts [0];
       $wanted [5]  = $$parts [1];
       $wanted [6]  = $$parts [2];
       $wanted [7]  = $$parts [3];

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Hosts.
    $good [0] = [qw /www.abigail.freedom.nl www.PERL.com a.b.c.d.e.f.g.h.i.j.k.x
                     127.0.0.1 w--w--w.abigail.freedom.nl w3.abigail.freedom.nl/];
    $bad  [0] = [qw /www.example..com w+w.example.com w--.example.com
                     127.0.0.0.1 -w.example.com www.example.1com/];

    # Ports.
    $good [1] = [undef, 119];
    $bad  [2] = ["", qw /-19 : port/];

    # Group.
    $good [2] = [qw /a comp.lang.perl.misc comp.lang.c++ hello_kitty_
                     foo-1234567890/];
    $bad  [2] = [undef, "", qw /1234567890 ** really? (!!make-$$$-fast**)
                                _hello_kitty_/];

    # Digits.
    $good [3] = [undef, qw /0 0000 12345/];
    $bad  [3] = ["", qw /fnurd -19 */, "1234/", "/12", "/"];

    return (\@good, \@bad);
}


__END__
