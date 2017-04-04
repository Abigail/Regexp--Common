#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common qw /run_new_tests cross criss_cross dd pdd/;

$^W = 1;


my $ssn   = $RE {SEN} {USA} {SSN};
my $space = $ssn -> {-sep => ' '};
my $empty = $ssn -> {-sep => ''};

use constant PASS => 4;
use constant FAIL => 3;

my $areas   = [ "001", map {pdd 3} 1 .. PASS];
my $groups  = [  "01", map {pdd 2} 1 .. PASS];
my $serials = ["0001", map {pdd 4} 1 .. PASS];

my $bad_a   = [ "000", "", dd (1), dd (2), dd (4), dd (5, 10)];
my $bad_g   = [  "00", "", dd (1), dd (3), dd (4), dd (5, 10)];
my $bad_s   = ["0000", "", dd (1), dd (2), dd (3), dd (5, 10)];

my $ssns    = [cross $areas, $groups, $serials];
my $wrong   = [criss_cross [[@$areas   [0 .. FAIL - 1]],
                            [@$groups  [0 .. FAIL - 1]],
                            [@$serials [0 .. FAIL - 1]]],
                           [$bad_a, $bad_g, $bad_s]];

my %targets = (
    ssn        =>  {
        list   =>  $ssns,
        query  =>  sub {join "-" => @_},
        wanted =>  sub {$_ => @_},
    },
    space      =>  {
        list   =>  $ssns,
        query  =>  sub {join " " => @_},
        wanted =>  sub {$_ => @_},
    },
    empty      =>  {
        list   =>  $ssns,
        query  =>  sub {join "" => @_},
        wanted =>  sub {$_ => @_},
    },
    wrong1     =>  {
        list   =>  $wrong,
        query  =>  sub {join "-" => @_},
    },
    wrong2     =>  {
        list   =>  $wrong,
        query  =>  sub {join " " => @_},
    },
);

my @wrongs = qw /wrong1 wrong2/;

my @tests = (
    {   name   =>  'basic',
        regex  =>  $ssn,
        pass   =>  [qw /ssn/],
        fail   =>  [qw /empty space/, @wrongs],
    },
    {   name   =>  'space',
        regex  =>  $space,
        pass   =>  [qw /space/],
        fail   =>  [qw /empty ssn/, @wrongs],
    },
    {   name   =>  'empty',
        regex  =>  $empty,
        pass   =>  [qw /empty/],
        fail   =>  [qw /ssn space/, @wrongs],
    },
);


run_new_tests  tests        => \@tests,
               targets      => \%targets,
               version_from => 'Regexp::Common::SEN',
;

__END__
