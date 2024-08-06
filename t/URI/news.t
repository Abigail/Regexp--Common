#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W = 1;


sub create_parts;

my $news  = $RE {URI} {news};

my @tests = (
   [news  => $news  => {news  => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version   =>   "Regexp::Common::URI::news",
          tests     =>  \@tests,
          good      =>   $good,
          bad       =>   $bad,
          query     =>  \&news,
          wanted    =>  \&wanted;

sub news {
    my ($tag, $grouppart) = ($_ [0], @{$_ [1]});

    my $news  = "news:";
       $news .= $grouppart if defined $grouppart;

    $news;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "news";
       $wanted [2]  = $$parts [0];

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    my @good_arts  = qw {fnord banzai123 4567 000 (!!make-$$$-fast**)
                         %00%FF%12''' really? ?/?/?/&=:;};
    my @good_hosts = qw /www.abigail.freedom.nl www.PERL.com a.b.c.d.e.f.g.h.i.j.k.x
                         127.0.0.1 w--w--w.abigail.freedom.nl w3.abigail.freedom.nl/;

    my @bad_arts   = ("", qw /%GG %F %7- %% {} <> ~abigail []/);
    my @bad_hosts  = ("", qw /www.example..com w+w.example.com
                              w--.example.com 127.0.1 127.0.0.0.1
                              -w.example.com www.example.1com/);

    # Groupparts.
    $good [0] = ["*", qw /a comp.lang.perl.misc comp.lang.c++ hello_kitty_
                          foo-1234567890/,
                      map {join '@' => @$_}
                                 t::Common::cross (\@good_arts, \@good_hosts)];
    $bad  [0] = ["", qw /1234567890 ** really? (!!make-$$$-fast**)
                         _hello_kitty_/,
                     (map {join '@' => @$_}
                                 t::Common::cross (\@good_arts, \@bad_hosts)),
                     (map {join '@' => @$_}
                                 t::Common::cross (\@bad_arts, \@good_hosts))];

    return (\@good, \@bad);
}


__END__
