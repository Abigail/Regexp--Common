#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;
use t::Common;

use warnings;


sub create_parts;

my $normal      = $RE {zip} {Greenland};
my $prefix      = $RE {zip} {Greenland} {-prefix  => 'yes'};
my $no_prefix   = $RE {zip} {Greenland} {-prefix  => 'no'};
my $iso         = $RE {zip} {Greenland} {-country => "iso"};
my $cept        = $RE {zip} {Greenland} {-country => "cept"};
my $country     = $RE {zip} {Greenland} {-country => "DEN"};
my $iso_prefix  = $iso  -> {-prefix => 'yes'};
my $cept_prefix = $cept -> {-prefix => 'yes'};

my @tests = (
    [ normal       => $normal      =>  {no_prefix      => NORMAL_PASS | FAIL,
                                        iso_prefix     => NORMAL_PASS | FAIL,
                                        cept_prefix    => NORMAL_PASS | FAIL,
                                        prefix_dk      => NORMAL_FAIL,
                                        prefix_DEN     => NORMAL_FAIL}],
    [ prefix       => $prefix      =>  {no_prefix      => NORMAL_FAIL,
                                        iso_prefix     => NORMAL_PASS,
                                        cept_prefix    => NORMAL_PASS}],
    ['no prefix'   => $no_prefix   =>  {no_prefix      => NORMAL_PASS,
                                        iso_prefix     => NORMAL_FAIL,
                                        cept_prefix    => NORMAL_FAIL}],
    [ iso          => $iso         =>  {no_prefix      => NORMAL_PASS,
                                        iso_prefix     => NORMAL_PASS,
                                        cept_prefix    => NORMAL_PASS}],
    [ cept         => $cept        =>  {no_prefix      => NORMAL_PASS,
                                        iso_prefix     => NORMAL_PASS,
                                        cept_prefix    => NORMAL_PASS}],
    [ country      => $country     =>  {no_prefix      => NORMAL_PASS,
                                        iso_prefix     => NORMAL_FAIL,
                                        cept_prefix    => NORMAL_FAIL,
                                        prefix_DEN     => NORMAL_PASS}],
    ['iso prefix'  => $iso_prefix  =>  {no_prefix      => NORMAL_FAIL,
                                        iso_prefix     => NORMAL_PASS,
                                        cept_prefix    => NORMAL_PASS}],
    ['cept prefix' => $cept_prefix =>  {no_prefix      => NORMAL_FAIL,
                                        iso_prefix     => NORMAL_PASS,
                                        cept_prefix    => NORMAL_PASS}],
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
    return "DK-$zip" if $tag eq "iso_prefix";
    return "DK-$zip" if $tag eq "cept_prefix";
    return "$1-$zip" if $tag =~ /^prefix_(.*)/;

    die "Unknown tag '$tag' in &zip\n";
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;

       $wanted [0] = $_;
       $wanted [1] =  undef;
       $wanted [1] = "DK" if $tag eq "iso_prefix";
       $wanted [1] = "DK" if $tag eq "cept_prefix";
       $wanted [1] =  $1  if $tag =~ /^prefix_(.*)/;
       $wanted [2] =  $$parts [0] . $$parts [1];
    push @wanted => @$parts [0, 1];

    return \@wanted;
}


sub _ {
    my ($min, $max, $cache, $exclude) = @_;
    $exclude ||= {};
    my $x;
    {
        $x  = "";
        $x .= int rand 10 for 1 .. $_ [0] + int rand (1 + $max - $min);
        redo if $exclude -> {$x} || $cache -> {$x} ++;
    }
    $x;
}


sub create_parts {
    my (@good, @bad);

    # Distribution district.
    my $a = {};
    $good [0] = [39];
 again:
    $bad  [0] = ['00', "quux", map {_ 2, 2, $a} 1 .. 3];
    goto again if grep {$_ eq "39"} @{$bad [0]};

    # Other numbers.
    my $c = {'00' => 1};
    $good [1] = ['00', map {_ 2, 2, $c} 2 .. 10];
    $bad  [1] = ["", "fnord", (map {_ 1, 1, $c} 1 .. 2),
                              (map {_ 3, 6, $c} 1 .. 2)];

   (\@good, \@bad)
}


__END__
