#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common qw /RE_zip_US/;
use t::Common qw /run_new_tests cross gimme sample pdd/;

use warnings;


my $basic   = $RE {zip} {US};
my $ext_yes = $RE {zip} {US} {-extended => 'yes'};
my $ext_no  = $RE {zip} {US} {-extended => 'no'};
my $prf_yes = $RE {zip} {US} {-prefix   => 'yes'};
my $prf_no  = $RE {zip} {US} {-prefix   => 'no'};
my $sep_sp  = $basic -> {-sep => " "};
my $sep_dsh = $basic -> {-sep => "--"};
my $sep_rg  = $basic -> {-sep => "[- ]"};
my $iso     = $RE {zip} {US} {-country  => 'iso'};
my $cept    = $RE {zip} {US} {-country  => 'cept'};
my $usa     = $RE {zip} {US} {-country  => 'usa'};
my $iso_py  = $iso  -> {-prefix => 'yes'};
my $iso_pn  = $iso  -> {-prefix => 'no'};
my $cept_py = $cept -> {-prefix => 'yes'};
my $cept_pn = $cept -> {-prefix => 'no'};
my $all     = $RE {zip} {US} {-country  => 'iso'} {-prefix => 'yes'}
                             {-extended => 'yes'} {-sep    => '[- ]'};

my @zips    = ("00000", gimme 10, sub {pdd 5});
my @ext     = ("0000",  gimme  5, sub {pdd 4});
my @zip_ext = (["00000", "0000"],
               cross (["00000"], [gimme 2 => sub {pdd 4}]),
               cross ([gimme 2 => sub {pdd 5}], ["0000"]),
               sample 10 => cross [gimme 5 => sub {pdd 5}],
                                  [gimme 5 => sub {pdd 4}]);
my @bad_zip = ("0000", "000000",
                gimme (10 => sub {pdd 2, 4}),   # Too short.
                gimme (10 => sub {pdd 6, 8}));  # Too long.
my @bad_ext = ("000", "0000",
                gimme (10 => sub {pdd 1, 3}),   # Too short.
                gimme (10 => sub {pdd 5, 8}));  # Too long.

my @baddies   =  @bad_zip;    # Basic bad zips.
push @baddies => map {join "-" => @_} 
                 sample 10 => cross \@zips, \@bad_ext; # Bad extensions.
push @baddies => map {join ["\n", qw {_ ! & ---}] -> [rand 5] => @_}
                 sample 10 => cross \@zips, \@ext;     # Bad separator.
push @baddies => map {"USS-$_"} @zips;                 # Bad countries.

my (@tests, %targets);

$targets {simple} = {
    list      =>  \@zips,
    wanted    =>  sub {$_, undef, join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       undef, undef,
                       undef, undef,},
};

$targets {simple_USA} = {
    list      =>  [@zips [0 .. 4]],
    query     =>  sub {join "-" => "USA", $_ [0]},
    wanted    =>  sub {$_, "USA", join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       undef, undef,
                       undef, undef,},
};

$targets {simple_US} = {
    list      =>  [@zips [0 .. 4]],
    query     =>  sub {join "-" => "US", $_ [0]},
    wanted    =>  sub {$_, "US", join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       undef, undef,
                       undef, undef,},
};

$targets {simple_usa} = {
    list      =>  [@zips [0 .. 4]],
    query     =>  sub {join "-" => "usa", $_ [0]},
    wanted    =>  sub {$_, "usa", join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       undef, undef,
                       undef, undef,},
};

$targets {extended} = {
    list      =>  \@zip_ext,
    query     =>  sub {join "-" => @_},
    wanted    =>  sub {$_, undef, join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       "-", $_ [1],
                       substr ($_ [1], 0, 2), substr ($_ [1], 2, 2)},
};

$targets {extended_USA} = {
    list      =>  \@zip_ext,
    query     =>  sub {join "-" => "USA", @_},
    wanted    =>  sub {$_, "USA", join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       "-", $_ [1],
                       substr ($_ [1], 0, 2), substr ($_ [1], 2, 2)},
};

$targets {extended_US} = {
    list      =>  \@zip_ext,
    query     =>  sub {join "-" => "US", @_},
    wanted    =>  sub {$_, "US", join ("-" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       "-", $_ [1],
                       substr ($_ [1], 0, 2), substr ($_ [1], 2, 2)},
};

$targets {extended_US_sp} = {
    list      =>  \@zip_ext,
    query     =>  sub {"US-" . $_ [0] . " " . $_ [1]},
    wanted    =>  sub {$_, "US", join (" " => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       " ", $_ [1],
                       substr ($_ [1], 0, 2), substr ($_ [1], 2, 2)},
};

$targets {sep_sp} = {
    list      =>  \@zip_ext,
    query     =>  sub {join " " => @_},
    wanted    =>  sub {$_, undef, join (" " => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       " ", $_ [1],
                       substr ($_ [1], 0, 2), substr ($_ [1], 2, 2)},
};

$targets {sep_dashes} = {
    list      =>  \@zip_ext,
    query     =>  sub {join "--" => @_},
    wanted    =>  sub {$_, undef, join ("--" => @_), $_ [0],
                       substr ($_ [0], 0, 3), substr ($_ [0], 3, 2),
                       "--", $_ [1],
                       substr ($_ [1], 0, 2), substr ($_ [1], 2, 2)},
};

$targets {bad_zip} = {
    list      =>  \@baddies,
};


push @tests   => {
    name      =>  'basic',
    regex     =>  $basic,
    sub       =>  \&RE_zip_US,
    pass      =>  [qw /simple simple_USA simple_US extended extended_USA
                       extended_US/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_usa extended_US_sp/],
};

push @tests   => {
    name      =>  'usa',
    regex     =>  $usa,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'usa'],
    pass      =>  [qw /simple simple_usa extended/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_USA extended_USA
                       simple_US extended_US extended_US_sp/],
};

push @tests   => {
    name      =>  'iso',
    regex     =>  $iso,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'iso'],
    pass      =>  [qw /simple simple_US extended extended_US/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_USA extended_USA
                       simple_usa extended_US_sp/],
};

push @tests   => {
    name      =>  'iso_py',
    regex     =>  $iso_py,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'iso', -prefix => 'yes'],
    pass      =>  [qw /simple_US extended_US/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_USA extended_USA
                       extended_US_sp simple extended simple_usa/],
};

push @tests   => {
    name      =>  'iso_pn',
    regex     =>  $iso_pn,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'iso', -prefix => 'no'],
    pass      =>  [qw /simple extended/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_USA extended_USA
                       extended_US extended_US_sp simple_US simple_usa/],
};

push @tests   => {
    name      =>  'cept_py',
    regex     =>  $cept_py,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'cept', -prefix => 'yes'],
    pass      =>  [qw /simple_USA extended_USA/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_US simple extended
                       extended_US extended_US_sp simple_usa/],
};

push @tests   => {
    name      =>  'cept_pn',
    regex     =>  $cept_pn,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'cept', -prefix => 'no'],
    pass      =>  [qw /simple extended/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_USA extended_USA
                       extended_US extended_US_sp simple_US simple_usa/],
};

push @tests   => {
    name      =>  'cept',
    regex     =>  $cept,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country => 'cept'],
    pass      =>  [qw /simple simple_USA extended extended_USA/],
    fail      =>  [qw /bad_zip sep_sp sep_dashes simple_US simple_usa
                       extended_US extended_US_sp/],
};

push @tests   => {
    name      =>  'ext_yes',
    regex     =>  $ext_yes,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-extended => 'yes'],
    pass      =>  [qw /extended extended_USA extended_US/],
    fail      =>  [qw /simple simple_USA simple_US bad_zip sep_sp sep_dashes
                       simple_usa extended_USA_sp/],
};

push @tests   => {
    name      =>  'ext_no',
    regex     =>  $ext_no,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-extended => 'no'],
    pass      =>  [qw /simple simple_USA simple_US/],
    fail      =>  [qw /extended extended_USA bad_zip sep_sp sep_dashes
                       simple_usa extended_US_sp extended_US/],
};

push @tests   => {
    name      =>  'prf_yes',
    regex     =>  $prf_yes,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-prefix => 'yes'],
    pass      =>  [qw /simple_USA simple_US extended_USA extended_US/],
    fail      =>  [qw /simple extended bad_zip sep_sp sep_dashes simple_usa
                       extended_US_sp/],
};

push @tests   => {
    name      =>  'prf_no',
    regex     =>  $prf_no,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-prefix => 'no'],
    pass      =>  [qw /simple extended/],
    fail      =>  [qw /simple_USA simple_US extended_USA bad_zip sep_sp
                       extended_US extended_US_sp sep_dashes simple_usa/],
};

push @tests   => {
    name      =>  'sep space',
    regex     =>  $sep_sp,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-sep => ' '],
    pass      =>  [qw /simple simple_USA simple_US sep_sp extended_US_sp/],
    fail      =>  [qw /bad_zip sep_dashes extended extended_USA extended_US
                       simple_usa/],
};

push @tests   => {
    name      =>  'sep dashes',
    regex     =>  $sep_dsh,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-sep => '--'],
    pass      =>  [qw /simple simple_USA simple_US sep_dashes/],
    fail      =>  [qw /bad_zip sep_sp extended extended_USA simple_usa 
                       extended_US extended_US_sp/],
};

push @tests   => {
    name      =>  'sep regex',
    regex     =>  $sep_rg,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-sep => '[- ]'],
    pass      =>  [qw /simple simple_USA simple_US sep_sp
                       extended extended_USA extended_US extended_US_sp/],
    fail      =>  [qw /bad_zip sep_dashes simple_usa/],
};

push @tests   => {
    name      =>  'all',
    regex     =>  $all,
    sub       =>  \&RE_zip_US,
    sub_args  =>  [-country  => 'iso', -prefix => 'yes', 
                   -extended => 'yes', -sep    => '[- ]'],
    pass      =>  [qw /extended_US extended_US_sp/],
    fail      =>  [qw /simple simple_USA simple_US bad_zip sep_sp sep_dashes
                       simple_usa extended extended_USA/],
};


run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::zip',
              version      => 5.00503,
;


__END__
