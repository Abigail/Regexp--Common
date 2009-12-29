#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Config;
use Regexp::Common;
use t::Common '5.008';

local $^W = 1;

use constant MAX_INT32 =>         0x7FFFFFFF;
use constant MAX_INT64 => 0x7FFFFFFFFFFFFFFF;
use constant MAX_INT   => $Config {use64bitint} ? MAX_INT64 : MAX_INT32;


($VERSION) = q $Revision: 2.101 $ =~ /[\d.]+/;

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
    my $x = int rand sqrt MAX_INT32;
    redo if $c {$x} ++ || $x <= 100;
    sprintf "%d" => $x;
}}
sub _2 {{
    my $x = int rand sqrt MAX_INT;
    redo if $c {$x} ++ || $x <= 100;
    sprintf "%d" => $x;
}}
my %d;
sub _3 {{
    my $x = int rand MAX_INT;
    redo if $d {$x} ++ || $x != (int sqrt ($x) ** 2);
    sprintf "%d" => $x;
}}

sub create_parts {
    my (@good, @bad);

    $good [0] = [map {$_ * $_} 0 .. 100];
    push @{$good [0]} => map {sprintf "%d", _1 () ** 2} 1 .. 200;
    push @{$good [0]} => map {sprintf "%d", _2 () ** 2} 1 .. 200;
    $bad  [0] = [-1, 0.1, "fnord", "f16", map {sprintf "%d" => _3} 1 .. 200];

  (\@good, \@bad);
}


__END__
 
 $Log: test_squares.t,v $
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

