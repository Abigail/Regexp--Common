#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;
use t::Common;

$^W = 1;

($VERSION) = q $Revision: 2.100 $ =~ /[\d.]+/;

sub create_parts;

my $dec    = $RE {num} {decimal};
my $radix  = $dec -> {-radix => ','};
my $base16 = $dec -> {-base  => 16};

my @tests = (
   [decimal => $dec    =>  { decimal   => NORMAL_PASS | FAIL,
                            'radix=,'  => FAIL}],
   [radix   => $radix  =>  {'radix=,'  => NORMAL_PASS | FAIL}],
   [base    => $base16 =>  {decimal    => NORMAL_PASS | FAIL,
                            'base=16'  => NORMAL_PASS}],
);

my ($good, $bad) = create_parts;

run_tests version      =>   "Regexp::Common::number",
          tests        =>  \@tests,
          good         =>   $good,
          bad          =>   $bad,
          query        =>  \&decimal,
          wanted       =>  \&wanted,
          filter       =>  \&filter,
          filter_test  =>  \&filter_test,
          ;

sub decimal {
    my ($tag, $sign, $integer, $fraction) = ($_ [0], @{$_ [1]});

    my $radix    = $tag =~ /radix=(.)/  ? $1 : ".";
    my $base     = $tag =~ /base=(\d+)/ ? $1 : 10;

    if ($base == 16) {
        for ($integer, $fraction) {
            $_ = sprintf "%x" => $_ if defined $_ && /^\d+$/;
        }
    }

    my $number   = "";
       $number  .= $sign               if defined $sign;
       $number  .= $integer            if defined $integer;
       $number  .= $radix . $fraction  if defined $fraction;

    $number;
}

sub wanted {
    my ($tag, $parts) = @_;

    my $radix    = $tag =~ /radix=(.)/  ? $1 : ".";
    my $base     = $tag =~ /base=(\d+)/ ? $1 : 10;

    if ($base == 16) {
        for (@$parts [1, 2]) {
            $_ = sprintf "%x" => $_ if defined $_ && /^\d+$/;
        }
    }

    my $mantissa = join $radix => grep {defined} @$parts [1, 2];

    my @wanted;
       $wanted [0] = $_;
       $wanted [1] = $$parts [0];   # sign
       $wanted [2] = $mantissa;
       $wanted [3] = $$parts [1];   # integer part.
       $wanted [4] = defined $$parts [2] ? $radix : undef;
       $wanted [5] = $$parts [2];

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Sign. Both 'undef' and '' will map the same.
    $good [0] = ["", qw /- +/];
    $bad  [0] = ['!', '-+'];

    # Integer. No need for both 'undef' and ''.
    $good [1] = ["", 0, 1, 17, 195, 8489];
    $bad  [1] = ["1 2", "fnord", "AQ"];

    # Fraction. 'undef' and '' differ (both are ok).
    $good [2] = [undef, "", 0, 1, 17, 195, 8489];
    $bad  [2] = ["1 2", "fnord", "AQ"];


    return (\@good, \@bad);
}


sub filter {
    # Need at least an integer, or a fractional part.
    return defined $_ [0] -> [1] && length $_ [0] -> [1]  ||
           defined $_ [0] -> [2] && length $_ [0] -> [2];
}

sub filter_test {
    my ($match, $name, $chunks) = @_;

    return 0 if $name =~ /^radix/ && !defined $chunks -> [2];

    1;
}


__END__

$Log: decimal.t,v $
Revision 2.100  2003/03/12 22:23:54  abigail
Tests for decimal numbers

