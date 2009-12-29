#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common qw /RE_zip_Italy/;
use t::Common qw /run_new_tests cross d pd dd a/;

# use warnings;


sub create_parts;

my $italy       = $RE {zip} {Italy};
my $yes_prefix  = $RE {zip} {Italy} {-prefix  => 'yes'};
my $no_prefix   = $RE {zip} {Italy} {-prefix  => 'no'};
my $iso_prefix  = $RE {zip} {Italy} {-country => 'iso'};
my $cept_prefix = $RE {zip} {Italy} {-country => 'cept'};
my $own_prefix  = $RE {zip} {Italy} {-country => 'it'};

use constant       FAIL => 5;

my @base    = ([0, pd], [0, pd], [0, pd], [0, pd], [0, pd]);
my $zips    = [cross @base];
my @long    = map {dd 6 => 10} 1 .. FAIL;
my @short   = map {dd 1 =>  4} 1 .. FAIL;
my @letter  = map {my $z = dd 5; substr $z, rand (5), 1, a; $z} 1 .. FAIL;
my $wrong   = [@long, @short, @letter];

my %targets = (
    no_prefix    => {
        list     => $zips,
        query    => sub {join "" => @_},
        wanted   => sub {$_, undef, join ("" => @_), @_},
    },
    iso_prefix   => {
        list     => $zips,
        query    => sub {"IT-" . join "" => @_},
        wanted   => sub {$_, "IT", join ("" => @_), @_},
    },
    cept_prefix  => {
        list     => $zips,
        query    => sub {"I-" . join "" => @_},
        wanted   => sub {$_, "I", join ("" => @_), @_},
    },
    own_prefix   => {
        list     => $zips,
        query    => sub {"it-" . join "" => @_},
        wanted   => sub {$_, "it", join ("" => @_), @_},
    },
    wrong1       => {
        list     => $wrong,
        query    => sub {$_ [0]},
    },
    wrong2       => {
        list     => $wrong,
        query    => sub {"IT-" . $_ [0]},
    },
    wrong3       => {
        list     => $wrong,
        query    => sub {"I-" . $_ [0]},
    },
    wrong4       => {
        list     => $zips,
        query    => sub {"IT " . join "" => @_},
    },
);

my @wrongs = qw /wrong1 wrong2 wrong3 wrong4/;

my @tests = (
    {    name     =>  'basic',
         regex    =>  $italy,
         pass     =>  [qw /no_prefix iso_prefix cept_prefix/],
         fail     =>  [qw /own_prefix/, @wrongs],
         sub      =>  \&RE_zip_Italy,
    },
    {    name     =>  'yes_prefix',
         regex    =>  $yes_prefix,
         pass     =>  [qw /iso_prefix cept_prefix/],
         fail     =>  [qw /no_prefix own_prefix/, @wrongs],
         sub      =>  \&RE_zip_Italy,
         sub_args =>  [-prefix  => 'yes'],
    },
    {    name     =>  'no_prefix',
         regex    =>  $no_prefix,
         pass     =>  [qw /no_prefix/],
         fail     =>  [qw /iso_prefix cept_prefix own_prefix/, @wrongs],
         sub      =>  \&RE_zip_Italy,
         sub_args =>  [-prefix  => 'no'],
    },
    {    name     =>  'iso_prefix',
         regex    =>  $iso_prefix,
         pass     =>  [qw /no_prefix iso_prefix/],
         fail     =>  [qw /cept_prefix own_prefix/, @wrongs],
         sub      =>  \&RE_zip_Italy,
         sub_args =>  [-country  => 'iso'],
    },
    {    name     =>  'cept_prefix',
         regex    =>  $cept_prefix,
         pass     =>  [qw /no_prefix cept_prefix/],
         fail     =>  [qw /iso_prefix own_prefix/, @wrongs],
         sub      =>  \&RE_zip_Italy,
         sub_args =>  [-country  => 'cept'],
    },
    {    name     =>  'own_prefix',
         regex    =>  $own_prefix,
         pass     =>  [qw /no_prefix own_prefix/],
         fail     =>  [qw /iso_prefix cept_prefix/, @wrongs],
         sub      =>  \&RE_zip_Italy,
         sub_args =>  [-country  => 'it'],
    },
);

run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::zip',
;

__END__
