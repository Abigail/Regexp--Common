#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;
use t::Common;

use warnings;


sub create_parts;

my $normal      = $RE {zip} {Belgium};
my $prefix      = $RE {zip} {Belgium} {-prefix  => 'yes'};
my $no_prefix   = $RE {zip} {Belgium} {-prefix  => 'no'};
my $iso         = $RE {zip} {Belgium} {-country => "iso"};
my $cept        = $RE {zip} {Belgium} {-country => "cept"};
my $country     = $RE {zip} {Belgium} {-country => "BEL"};
my $iso_prefix  = $iso  -> {-prefix => 'yes'};
my $cept_prefix = $cept -> {-prefix => 'yes'};

my @tests = (
    [ normal       => $normal      =>  {no_prefix   => NORMAL_PASS | FAIL,
                                        iso_prefix  => NORMAL_PASS | FAIL,
                                        cept_prefix => NORMAL_PASS | FAIL,
                                        prefix_b    => NORMAL_FAIL,
                                        prefix_be   => NORMAL_FAIL,
                                        prefix_BEL  => NORMAL_FAIL}],
    [ prefix       => $prefix      =>  {no_prefix   => NORMAL_FAIL,
                                        iso_prefix  => NORMAL_PASS,
                                        cept_prefix => NORMAL_PASS}],
    ['no prefix'   => $no_prefix   =>  {no_prefix   => NORMAL_PASS,
                                        iso_prefix  => NORMAL_FAIL,
                                        cept_prefix => NORMAL_FAIL}],
    [ iso          => $iso         =>  {no_prefix   => NORMAL_PASS,
                                        iso_prefix  => NORMAL_PASS,
                                        cept_prefix => NORMAL_FAIL}],
    [ cept         => $cept        =>  {no_prefix   => NORMAL_PASS,
                                        iso_prefix  => NORMAL_FAIL,
                                        cept_prefix => NORMAL_PASS}],
    [ country      => $country     =>  {no_prefix   => NORMAL_PASS,
                                        iso_prefix  => NORMAL_FAIL,
                                        cept_prefix => NORMAL_FAIL,
                                        prefix_BEL  => NORMAL_PASS}],
    ['iso prefix'  => $iso_prefix  =>  {no_prefix   => NORMAL_FAIL,
                                        iso_prefix  => NORMAL_PASS,
                                        cept_prefix => NORMAL_FAIL}],
    ['cept prefix' => $cept_prefix =>  {no_prefix   => NORMAL_FAIL,
                                        iso_prefix  => NORMAL_FAIL,
                                        cept_prefix => NORMAL_PASS}],
);

my ($good, $bad) = create_parts;

run_tests  version   =>  "Regexp::Common::zip",
           tests     => \@tests,
           good      =>  $good,
           bad       =>  $bad,
           query     => \&zip,
           wanted    => \&wanted;

sub zip {
    my ($tag, $parts) = @_;

    my $zip = $$parts [0] . $$parts [1];

    return     $zip  if $tag eq "no_prefix";
    return "BE-$zip" if $tag eq "iso_prefix";
    return  "B-$zip" if $tag eq "cept_prefix";
    return "$1-$zip" if $tag =~ /^prefix_(.*)/;

    die "Unknown tag '$tag' in &zip\n";
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;

       $wanted [0] = $_;
       $wanted [1] =  undef;
       $wanted [1] = "BE" if $tag eq "iso_prefix";
       $wanted [1] = "B"  if $tag eq "cept_prefix";
       $wanted [1] =  $1  if $tag =~ /^prefix_(.*)/;
       $wanted [2] =  $$parts [0] . $$parts [1];
    push @wanted => @$parts [0, 1];

    return \@wanted;
}


sub _ {
    my ($min, $max, $cache) = @_;
    my $x;
    {
        $x  = "";
        $x .= int rand 10 for 1 .. $_ [0] + int rand (1 + $max - $min);
        redo if $cache -> {$x} ++;
    }
    $x;
}


sub create_parts {
    my (@good, @bad);

    # Provinces.
    $good [0] = [1 .. 9];
    $bad  [0] = [0];

    # Distributions.
    my $c = {'000' => 1};
    $good [1] = ['000', map {_ 3, 3, $c} 2 .. 20];
    $bad  [1] = ["", "fnord", (map {_ 1, 2, $c} 1 .. 4),
                              (map {_ 4, 6, $c} 1 .. 4)];

    # 'Fake' entries for "wrong" country codes.
   (\@good, \@bad)
}

__END__
