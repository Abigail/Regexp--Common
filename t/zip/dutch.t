#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;

$^W = 1;

($VERSION) = q $Revision: 2.103 $ =~ /[\d.]+/;

sub failures;

use constant  PASSES     =>  50;
use constant  FAIL       =>  10;

my $count;

my $normal          = $RE {zip} {Dutch};
my $no_space        = $RE {zip} {Dutch} {-sep => ""};
my $dash            = $RE {zip} {Dutch} {-sep => "-"};
my $prefix          = $RE {zip} {Dutch} {-prefix => "yes"};
my $no_prefix       = $RE {zip} {Dutch} {-prefix => "no"};
my $iso             = $RE {zip} {Dutch} {-country => "iso"};
my $cept            = $RE {zip} {Dutch} {-country => "cept"};
my $country         = $RE {zip} {Dutch} {-country => "NLD"};
my $dash_prefix     = $RE {zip} {Dutch} {-sep => "-"} {-prefix => "yes"};
my $dash_no_prefix  = $RE {zip} {Dutch} {-sep => "-"} {-prefix => "no"};

my @tests = (
    [ normal             =>  $normal          => [qw /1 1 0 0 0 0 0/]],
    [ no_space           =>  $no_space        => [qw /0 0 1 1 0 0 0/]],
    [ dash               =>  $dash            => [qw /0 0 0 0 1 1 0/]],
    [ prefix             =>  $prefix          => [qw /0 1 0 0 0 0 0/]],
    ['no prefix'         =>  $no_prefix       => [qw /1 0 0 0 0 0 0/]],
    [ iso                =>  $iso             => [qw /1 1 0 0 0 0 0/]],
    [ cept               =>  $cept            => [qw /1 1 0 0 0 0 0/]],
    [ country            =>  $country         => [qw /1 0 0 0 0 0 1/]],
    ['dash & prefix'     =>  $dash_prefix     => [qw /0 0 0 0 0 1 0/]],
    ['dash & no prefix'  =>  $dash_no_prefix  => [qw /0 0 0 0 1 0 0/]],
);

my @failures = failures;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

my $max = 1 + 2 * @tests * @{$tests [0] -> [2]} * PASSES + @failures * @tests;
print "1..$max\n";

print "not " unless defined $Regexp::Common::zip::VERSION;
print "ok ", ++ $count, " - Regexp::Common::zip::VERSION\n";

sub run_test {
    my ($name, $re, $should_match) = @_;
    my $match = /^$re$/;
    my $line  = $match ? "match" : "no match";
       $line .= "; $name";
   ($match xor $should_match) ? fail $line : pass $line
}

sub __ {map {defined () ? $_ : "UNDEF"} @_}
sub run_keep {
    my ($name, $re, $should_match) = splice @_ => 0, 3;
    unless ($should_match) {
        if (/^$re$/) {fail "match; keep - $name"}
        else         {pass "no match; keep - $name"}
        return;
    }
    my @exp = ($_, $_ [0], join ("" => grep {defined} @_ [1 .. 3]),
               @_ [1 .. 3]);
    if (my @args = /^$re$/) {
        unshift @_ => $_;
        unless (@exp == @args) {
            fail "match; keep - $name [@{[__ @args]}]";
        }
        foreach my $n (0 .. $#_) {
            unless (!defined $exp [$n] && !defined $args [$n] ||
                     defined $exp [$n] &&  defined $args [$n] &&
                             $exp [$n] eq          $args [$n]) {
                fail "match; keep - $name [@{[__ @args]}]";
                return;
            }
        }
        pass "match; keep - $name";
        return;
    }
    fail "no match; keep - $name";
}

sub _n {
    my $min = $_ [0];
    my $max = @_ > 1 ? $_ [1] : $_ [0];
    my $x   = 1 + int rand 9;
       $x  .= int rand 10 for 2 .. $_ [0] + int rand (1 + $max - $min);
       $x;
}
sub _l {
    my $min = $_ [0];
    my $max = @_ > 1 ? $_ [1] : $_ [0];
    my @l   = ('A' .. 'Z');
    my $x   = "";
       $x  .= $l [int rand @l] for 1 .. $_ [0] + int rand (1 + $max - $min);
       $x;
}

my %cache;
foreach my $d (1 .. PASSES) {
    my $n = _n 4;
    my $l = _l 2;
       $l = _l 2 while $l =~ /[FIOQUY]/ || $l =~ /S[ADS]/;

    redo if $cache {"$n $l"};

    my @t = ([undef,  $n, " ", $l],
             ["NL",   $n, " ", $l],
             [undef,  $n, "",  $l],
             ["NL",   $n, "",  $l],
             [undef,  $n, "-", $l],
             ["NL",   $n, "-", $l],
             ["NLD",  $n, " ", $l]);

    my $c = 0;
    foreach my $t (@t) {
        local $_  = defined $t -> [0] ? $t -> [0] . "-" : "";
              $_ .= join "" => grep {defined} @{$t} [1 .. 3];
        foreach my $test (@tests) {
            my ($name, $re, $matches) = @$test;
            run_test $name, $re,            $matches -> [$c];
            run_keep $name, $re -> {-keep}, $matches -> [$c], @$t;
        }
        $c ++;
    }
}

foreach (@failures) {
    foreach my $test (@tests) {
        my ($name, $re) = @$test;
        /^$re$/ ? fail "match; $name" : pass "no match; $name";
    }
}


sub failures {
    my @failures = ("", " ");

    # Zip starting with '0'.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
           $x  =~ s/^./0/;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Too few numbers.
    foreach (1 .. FAIL) {
        my $x  = _n 1, 3;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Too many numbers.
    foreach (1 .. FAIL) {
        my $x  = _n 5, 10;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }


    # Too few letters.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 1;
           $y  = _l 1 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Too many letters.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 3, 6;
           $y  = _l 3, 6 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Wrong letters.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 until $y =~ /[FIOQUY]/;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Wrong letter combos.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= ('SA', 'SD', 'SS') [rand 3];
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Wrong separator.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        my $s  =  int rand 256;
        redo if +($s & 0x7F) < 0x20;
           $s  =  chr $s;
        redo if $s eq ' ' || $s eq '-';
        redo if $cache {"$x$s$y"} ++;
        push @failures => "$x$s$y";
    }

    # Lowercase letters.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 1;
           $y  = _l 1 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
           $y  =  lc $y;
        redo if $cache {"$x $y"} ++;
        push @failures => "$x $y";
    }

    # Letters, then numbers.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"$y $x"} ++;
        push @failures => "$y $x";
    }

    # Leading/trailing garbage.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {" $x $y"} ++ or $cache {"$x $y "} ++;
        push @failures => " $x $y", "$x $y ";
    }

    push @failures => map {"NL-$_"} @failures;

    # Wrong countries.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        my $c  = _l 2;
           $c  = _l 2 while $c eq "NL";
        redo if $cache {"$c-$x $y"} ++;
        push @failures => "$c-$x $y";
    }

    # Lowercase countries.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        redo if $cache {"nl-$x $y"} ++;
        push @failures => "nl-$x $y";
    }

    # Too many letters in country.
    foreach (1 .. FAIL) {
        my $x  = _n 4;
        my $y .= _l 2;
           $y  = _l 2 while $y =~ /[FIOQUY]/ || $y =~ /S[ADS]/;
        my $c  = _l 1;
           $c  = _l 1 while $c eq "D";
        redo if $cache {"${c}NL-$x $y"} ++ || $cache {"NL$c-$x $y"} ++;
        push @failures => "${c}NL-$x $y";
        push @failures => "NL$c-$x $y";
    }

    @failures;
};

=pod

 $Log: dutch.t,v $
 Revision 2.103  2003/02/05 09:54:15  abigail
 Removed 'use Config'

 Revision 2.102  2003/02/02 03:11:20  abigail
 File moved to t/URI

 Revision 2.101  2003/02/02 02:56:53  abigail
 Debugged the test suite

 Revision 2.100  2003/01/21 23:19:13  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.4  2003/01/13 19:45:04  abigail
 Added tests for -country

 Revision 1.3  2003/01/05 02:13:40  abigail
 Another rehaul of doing tests.

 Revision 1.2  2003/01/03 00:22:28  abigail
 Complete rehaul of doing the tests.

 Revision 1.1  2002/12/31 01:18:13  abigail
 Initial version

__END__
