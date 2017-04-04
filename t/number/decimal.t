#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common qw /RE_num_decimal/;
use t::Common;

my $decimal = $RE {num} {decimal};

# The following arrays contain valid numbers in the respective bases -
# and the numbers aren't valid in the next array.
my @data = (
    [36  => [qw /regexp common perl5/]],
    [16  => [qw /deadbeaf c0c0a c1a0 55b/]],
    [10  => [qw /81320981536123490812346123 129 9/]],
    [ 8  => [qw /777 153/]],
    [ 2  => [qw /0 1 1010101110/]],
);

my (%targets, @tests);

foreach my $entry (@data) {
    my ($base, $list) = @$entry;

    $targets {"${base}_int"} = {
        list   => $list,
        query  => sub {$_ [0]},
        wanted => sub {$_ [0], "", $_ [0], $_ [0], undef, undef}
    };

    for my $exp ([dot => "."], [comma => ","]) {
        my ($name, $punct) = @$exp;
        $targets {"${base}_int_${name}"} = {
            list   => $list,
            query  => sub {$_ [0] . $punct},
            wanted => sub {$_ [0] . $punct, "",
                           $_ [0] . $punct, $_ [0], $punct, ""}
        };

        $targets {"${base}_${name}_frac"} = {
            list   => $list,
            query  => sub {$_ [0] . $punct},
            wanted => sub {$_ [0] . $punct, "",
                           $_ [0] . $punct, $_ [0], $punct, ""}
        };

        $targets {"${base}_minus_${name}_frac"} = {
            list   => $list,
            query  => sub {"-" . $_ [0] . $punct},
            wanted => sub {"-" . $_ [0] . $punct, "-",
                                 $_ [0] . $punct, $_ [0], $punct, ""}
        };

        $targets {"${base}_plus_${name}_frac"} = {
            list   => $list,
            query  => sub {"+" . $_ [0] . $punct},
            wanted => sub {"+" . $_ [0] . $punct, "+",
                                 $_ [0] . $punct, $_ [0], $punct, ""}
        };
    }

    $targets {"${base}_minus_int"} = {
        list   => $list,
        query  => sub {"-" . $_ [0]},
        wanted => sub {"-" . $_ [0], "-", $_ [0], $_ [0], "", ""}
    };

    $targets {"${base}_plus_int"} = {
        list   => $list,
        query  => sub {"+" . $_ [0]},
        wanted => sub {"+" . $_ [0], "+", $_ [0], $_ [0], "", ""}
    };
}

$targets {dot} = {
    list   => ['.'],
    query  => sub {$_ [0]},
};

sub __ {
    map {;"${_}_int",            "${_}_int_dot",
          "${_}_minus_int",      "${_}_plus_int",
          "${_}_dot_frac",       "${_}_minus_dot_frac", "${_}_plus_dot_frac",
    } @_
}

sub _2 {
    map {;"${_}_minus_int",      "${_}_plus_int",
          "${_}_minus_dot_frac", "${_}_plus_dot_frac",
    } @_
}

sub _3 {
    map {;"${_}_int",            "${_}_int_dot",
          "${_}_dot_frac",
    } @_
}

push @tests  => {
    name     =>  'basic',
    re       =>  $decimal,
    sub      =>  \&RE_num_decimal,
    pass     =>  [__ (grep {$_ <= 10} map {$$_ [0]} @data)],
    fail     =>  [__ (grep {$_ >  10} map {$$_ [0]} @data), "dot"],
};


push @tests  => {
    name     =>  'basic -- signed',
    re       =>  $decimal -> {-sign => '[-+]'},
    sub      =>  \&RE_num_decimal,
    sub_args =>  [-sign => '[-+]'],
    pass     =>  [ _2 (grep {$_ <= 10} map {$$_ [0]} @data)],
    fail     =>  [(_3 (grep {$_ <= 10} map {$$_ [0]} @data)),
                   __ (grep {$_ >  10} map {$$_ [0]} @data), "dot"],
};

foreach my $data (@data) {
    my $base     = $$data [0];
    my @passes   = __ grep {$_ <= $base} map {$$_ [0]} @data;
    my @failures = __ grep {$_ >  $base} map {$$_ [0]} @data;

    my @commas   = grep {/^${base}_.*comma/} keys %targets;

    push @tests  => {
        name     => "base_${base}",
        re       => $RE {num} {decimal} {-base => $base},
        sub      => \&RE_num_decimal,
        sub_args => [-base => $base],
        pass     => [@passes],
        fail     => [@failures, @commas, "dot"],
    };
    push @tests  => {
        name     => "base_${base}_comma",
        re       => $RE {num} {decimal} {-base => $base} {-radix => ","},
        sub      => \&RE_num_decimal,
        sub_args => [-base => $base, -radix => ","],
        pass     => [(grep {!/dot/} @passes), @commas],
        fail     => [(grep {/^${base}/} @failures)],
    };
}



run_new_tests  targets      => \%targets,
               tests        => \@tests,
               version_from => 'Regexp::Common::number',
;

__END__
