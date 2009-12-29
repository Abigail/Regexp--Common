#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common qw /RE_zip_Norway/;
use t::Common qw /run_new_tests cross pdd dd a/;

use warnings;


my $norway      = $RE {zip} {Norway};
my $yes_prefix  = $RE {zip} {Norway} {-prefix  => 'yes'};
my $no_prefix   = $RE {zip} {Norway} {-prefix  => 'no'};
my $iso_prefix  = $RE {zip} {Norway} {-country => 'iso'};
my $cept_prefix = $RE {zip} {Norway} {-country => 'cept'};
my $own_prefix  = $RE {zip} {Norway} {-country => 'no'};

use constant       PASS => 10;
use constant       FAIL => 10;

my $valid   = [ '0000',  '9999', map {pdd 4}      1 .. -2 + PASS];
my $short   = [    '0',   '999', map {dd 1 =>  3} 1 .. -2 + FAIL];
my $long    = ['00000', '99999', map {dd 5 => 10} 1 .. -2 + FAIL];
my $letter  = [map {my $z = dd 4; substr $z, rand (4), 1, a; $z} 1 .. FAIL];
my $wrong   = [@$long, @$short, @$letter];

my %targets = (
    no_prefix    => {
        list     => $valid,
        wanted   => sub {$_, undef, $_ [0]},
    },
    iso_prefix   => {
        list     => $valid,
        query    => sub {"NO-" . $_ [0]},
        wanted   => sub {$_, "NO", $_ [0]},
    },
    cept_prefix  => {
        list     => $valid,
        query    => sub {"N-" . $_ [0]},
        wanted   => sub {$_, "N", $_ [0]},
    },
    own_prefix   => {
        list     => $valid,
        query    => sub {"no-" . $_ [0]},
        wanted   => sub {$_, "no", $_ [0]},
    },
    wrong1       => {
        list     => $wrong,
    },
    wrong2       => {
        list     => $wrong,
        query    => sub {"NO-" . $_ [0]},
    },
    wrong3       => {
        list     => $wrong,
        query    => sub {"N-" . $_ [0]},
    },
    wrong4       => {
        list     => $valid,
        query    => sub {"NO " . $_ [0]},
    },
);

my @wrongs = qw /wrong1 wrong2 wrong3 wrong4/;

my @tests = (
    {    name     =>  'basic',
         regex    =>  $norway,
         sub      =>  \&RE_zip_Norway,
         pass     =>  [qw /no_prefix iso_prefix cept_prefix/],
         fail     =>  [qw /own_prefix/, @wrongs],
    },
    {    name     =>  'yes_prefix',
         regex    =>  $yes_prefix,
         sub      =>  \&RE_zip_Norway,
         sub_args =>  [-prefix  => 'yes'],
         pass     =>  [qw /iso_prefix cept_prefix/],
         fail     =>  [qw /no_prefix own_prefix/, @wrongs],
    },
    {    name     =>  'no_prefix',
         regex    =>  $no_prefix,
         sub      =>  \&RE_zip_Norway,
         sub_args =>  [-prefix  => 'no'],
         pass     =>  [qw /no_prefix/],
         fail     =>  [qw /iso_prefix cept_prefix own_prefix/, @wrongs],
    },
    {    name     =>  'iso_prefix',
         regex    =>  $iso_prefix,
         sub      =>  \&RE_zip_Norway,
         sub_args =>  [-country  => 'iso'],
         pass     =>  [qw /no_prefix iso_prefix/],
         fail     =>  [qw /cept_prefix own_prefix/, @wrongs],
    },
    {    name     =>  'cept_prefix',
         regex    =>  $cept_prefix,
         sub      =>  \&RE_zip_Norway,
         sub_args =>  [-country  => 'cept'],
         pass     =>  [qw /no_prefix cept_prefix/],
         fail     =>  [qw /iso_prefix own_prefix/, @wrongs],
    },
    {    name     =>  'own_prefix',
         regex    =>  $own_prefix,
         sub      =>  \&RE_zip_Norway,
         sub_args =>  [-country  => 'no'],
         pass     =>  [qw /no_prefix own_prefix/],
         fail     =>  [qw /iso_prefix cept_prefix/, @wrongs],
    },
);

run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::zip',
;

__END__
