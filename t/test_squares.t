#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Config;
use Regexp::Common;
use t::Common '5.008';

use warnings;

my $MAX = $Config {use64bitint} ? do {no warnings; "9000000000000000"}
                                : 0x7FFFFFFF;

($VERSION) = q $Revision: 2.105 $ =~ /[\d.]+/;

sub create_parts;

my $square = $RE {num} {square};

my @tests  = (
   [square => $square => {square => NORMAL_PASS | FAIL}]
);

my ($good, $bad) = create_parts;

run_tests version   =>  "Regexp::Common::number",
          tests     =>  \@tests,
          good      =>  $good,
          bad       =>  $bad,
          query     =>  sub {$_ [1] -> [0]},
          wanted    =>  sub {$_ [1]};

my %c;
sub _1 {{
    my $x = int rand sqrt $MAX;
    redo if $c {$x} ++ || $x <= 100;
    $x = sprintf "%d" => $x;
    $x = ("0" x (1 + int rand 10)) . $x if rand (10) < 1;
    $x;
}}
my %d;
sub _2 {{
    my $x = int rand $MAX;
    redo if $d {$x} ++ || $x == (int sqrt ($x)) ** 2;
    sprintf "%d" => $x;
}}

sub create_parts {
    my (@good, @bad);

    $good [0] = [map {$_ * $_} 0 .. 100];
    push @{$good [0]} => 2147395600;
    push @{$good [0]} => map {sprintf "%d", _1 () ** 2} 1 .. 400;
    $bad  [0] = [-1, 0.1, "fnord", "f16", map {sprintf "%d" => _2} 1 .. 200];
    push @{$bad [0]} => 2147483647;

  (\@good, \@bad);
}


__END__
 
 $Log: test_squares.t,v $
 Revision 2.105  2008/05/26 17:07:27  abigail
 use warnings

 Revision 2.104  2004/07/01 10:11:27  abigail
 Fixed problems with 32bit integer Perls

 Revision 2.103  2004/06/30 09:14:59  abigail
 Restricted recognition of square numbers to numbers less than
 9000000000000000 to avoid round-off errors.

 Revision 2.102  2003/02/11 09:35:09  abigail
 Wrapped '0x7FFFFFFFFFFFFFFF' inside an eval

 Revision 2.101  2003/02/10 21:22:17  abigail
 Cut down on the number of tests

 Revision 2.100  2003/01/21 23:19:13  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.2  2002/12/31 02:08:29  abigail
 Coded around mandatory warning about large hex numbers

 Revision 1.1  2002/12/23 23:32:24  abigail
 Initial checkin

