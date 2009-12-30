#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Config;
use Regexp::Common;
use t::Common '5.008';

use warnings;

my $bits64 = $Config {use64bitint};
#
# CPAN testers claim it fails on 5.8.8 and darwin 9.0.
#
$bits64 = 0 if $Config {osname} eq 'darwin' &&
               $Config {osvers} eq '9.0'    &&
               $] == 5.008008;

my $MAX = $bits64 ? do {no warnings; "9000000000000000"}
                  : 0x7FFFFFFF;


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
