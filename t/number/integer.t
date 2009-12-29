#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common qw /RE_num_int/;
use t::Common qw /run_new_tests aa sample/;

my $int = $RE {num} {int};

my (%targets, @tests);

my @digits = (0 .. 9, 'A' .. 'Z');

my %cache;
sub gimme {
    # Create a number in certain base, between certain lengths.
    my %arg = @_;

    my $base       = $arg {base};
    my $min_base   = $arg {min_base}   ||  1;
    my $min_length = $arg {min_length} ||  5;
    my $max_length = $arg {max_length} || 10;

    die "Wrong base" unless 1 <= $base && $base <= 36;

    # First, find a length.
    my $length = $min_length + int rand ($max_length - $min_length + 1);

  TRY:
    my $ok;
    my $num = "";
    for (1 .. $length) {
        my $i = int rand $base;
        $ok ++ if $i >= $min_base;
        $num .= $digits [$i];
    }
    if (!$ok) {
        my $digit = $digits [$min_base + int rand ($base - $min_base) - 1];
        substr ($num, rand length $num, 1, $digit);
    }
    goto TRY if $cache {$num} ++;

    $num;
}

my $size       = 10;
my $short_size =  7;  # Should be less than $size.
my $mini_size  =  3;  # Should be less than $size.
my $bad_size   =  5;  # Should be less than $size.

my (@numbers, @groups, @long, @exact);
my  @bases       = (0, 2, 8, 10, 12, 16, 25, 36);
my  @group_sizes = (3, 4, 5);
my  $too_long    =  6;
my  $max_length  = 12;
for (my $i = 1; $i < @bases; $i ++) {
    my $base = $bases [$i];
    @{$numbers [$base]} = map {gimme base       => $base,
                                     min_base   => $bases [$i - 1] + 1,
                                     min_length => $_,
                                     max_length => $_ * 5} 1 .. $size;
    @{$long    [$base]} = map {gimme base       => $base,
                                     min_base   => $bases [$i - 1] + 1,
                                     min_length =>  7,
                                     max_length => 18} 1 .. $size;

    for my $length (2 .. $max_length) {
        next if $length >= $base;
        @{$exact [$base] [$length]} = map {gimme base       => $base,
                                                 min_length => $length,
                                                 max_length => $length,
                                          } 1 .. $mini_size;
    }
    @{$exact [$base] [1]} = sample $mini_size,
                                  (0 .. 9, 'A' .. 'Z') [0 .. $base - 1];
    #
    # Chop into groups
    #
    foreach my $group (@group_sizes) {
        foreach my $num (@{$numbers [$base]}) {
            my ($p, $s) = $num =~ /^(.+?)((?:.{$group})*)$/;
            push @{$groups [$base] [$group]} => [$p, $s =~ /.{$group}/g];
        }
    }
    foreach my $num (@{$long [$base]}) {
        my ($p, $s) = $num =~ /^(.*?)((?:.{$too_long})*)$/;
        push @{$groups [$base] [$too_long]} => [$p, $s =~ /.{$too_long}/g];
    }

    # Unsigned numbers.
    $targets {"u$base"} = {
        list   => $numbers [$base],
        query  => sub {$_ [0]},
        wanted => sub {$_ [0], "", $_ [0]},
    };

    # Positive numbers.
    $targets {"+$base"} = {
        list   => [sample $short_size, @{$numbers [$base]}],
        query  => sub {"+" . $_ [0]},
        wanted => sub {"+" . $_ [0], "+", $_ [0]},
    };

    # Negative numbers.
    $targets {"-$base"} = {
        list   => [sample $short_size, @{$numbers [$base]}],
        query  => sub {"-" . $_ [0]},
        wanted => sub {"-" . $_ [0], "-", $_ [0]},
    };

    #
    # Separators
    #
    foreach my $group (@group_sizes, $too_long) {
        $targets {"sep-$base-$group"} = {
            list   =>  $groups [$base] [$group],
            query  =>  sub {join "," => @_},
            wanted =>  sub {my $n = join "," => @_; $n, "", $n},
        };
        $targets {"sep-$base-$group-colon"} = {
            list   =>  $groups [$base] [$group],
            query  =>  sub {join ":" => @_},
            wanted =>  sub {my $n = join ":" => @_; $n, "", $n},
        };
        $targets {"+-sep-$base-$group"} = {
            list   =>  [sample $short_size, @{$groups [$base] [$group]}],
            query  =>  sub {"+" . join "," => @_},
            wanted =>  sub {my $n = join "," => @_; "+$n", "+", $n},
        };
        $targets {"+-sep-$base-$group-dot"} = {
            list   =>  [sample $short_size, @{$groups [$base] [$group]}],
            query  =>  sub {"+" . join "." => @_},
            wanted =>  sub {my $n = join "." => @_; "+$n", "+", $n},
        };
        $targets {"--sep-$base-$group"} = {
            list   =>  [sample $short_size, @{$groups [$base] [$group]}],
            query  =>  sub {"-" . join "," => @_},
            wanted =>  sub {my $n = join "," => @_; "-$n", "-", $n},
        };
    }

    #
    # Exact length.
    #
    foreach my $length (1 .. $max_length) {
        $targets {"exact-$base-$length"} = {
            list   =>  $exact [$base] [$length],
            query  =>  sub {$_ [0]},
            wanted =>  sub {$_ [0], "", $_ [0]}
        };
        $targets {"+-exact-$base-$length"} = {
            list   =>  $exact [$base] [$length],
            query  =>  sub {"+" . $_ [0]},
            wanted =>  sub {my $n = $_ [0]; "+$n", "+", $n}
        };
        $targets {"--exact-$base-$length"} = {
            list   =>  $exact [$base] [$length],
            query  =>  sub {"-" . $_ [0]},
            wanted =>  sub {my $n = $_ [0]; "-$n", "-", $n}
        };
    }

    #
    # Bad strings.
    #
    # Trailing dot.
    $targets {"dot$base"} = {
        list   => [sample $bad_size, @{$numbers [$i]}],
        query  => sub {$_ [0] . "."},
    },

    #
    # Double signs
    #
    $targets {"sign$base"} = {
        list   => [sample $bad_size, @{$numbers [$i]}],
        query  => sub {("++", "-+", "+-", "--") [rand 4] . $_ [0]},
    },

}
unshift @{$numbers [2]} => 0;

#
# Some bad examples.
# 
my @words   = map {aa (5, 10)} 1 .. $size;

my @g = (' ', '.', ';', '--', '++');
my @garbage = map {my $s = 1 + int rand 5;
                   my $str = $_;
                   substr $str, int rand length $_, 1, $g [rand @g] for 1 .. $s;
                   $str}
              map {$_ ? sample $bad_size, @$_ : ()} @numbers;

$targets {words} = {
    list   =>  \@words,
};
$targets {garbage} = {
    list   =>  \@garbage,
    query  =>  sub {("", "+", "-") [rand 3] . $_ [0]},
};
$targets {small_garbage} = {
    list   =>  [sample $bad_size, @garbage],
    query  =>  sub {("", "+", "-") [rand 3] . $_ [0]},
};


push @tests => {
    name    => "integer",
    re      => $RE {num} {int},
    sub     => \&RE_num_int,
    pass    => [ map {;"u$_", "+$_", "-$_"} grep {$_ && $_ <= 10} @bases],
    fail    => [(map {;"u$_", "+$_", "-$_"} grep {$_ && $_  > 10} @bases),
                "words", "garbage", "dot10", "sign10"],
};


my @pairs = map {my $n = $_; map {[$n, $_]} $n + 1 .. $max_length
                } 1 .. $max_length;

foreach my $i (1 .. $#bases) {
    my $base = $bases [$i];
    push @tests  => {
        name     => "-base=$base",
        re       => $RE {num} {int} {-base => $base},
        sub      => \&RE_num_int,
        sub_args => [-base => $base],
        pass     => [ map {;"u$_", "+$_", "-$_"}
                      grep {$_ && $_ <= $base} @bases],
        fail     => [(map {;"u$_", "+$_", "-$_"}
                      grep {$_ && $_  > $base} @bases),
                    "words", "garbage", "dot$base", "sign$base"],
    };

    foreach my $group (@group_sizes) {
        push @tests  => {
            name     => "-base=$base; -group=$group",
            re       => $RE {num} {int} {-base => $base} {-group => $group}
                                        {-sep},
            sub      => \&RE_num_int,
            sub_args => [-base => $base, -group => $group, -sep =>],
            pass     => [  "sep-$base-$group",
                         "+-sep-$base-$group",
                         "--sep-$base-$group",],
            fail     => [  "sep-$base-$too_long",
                         "+-sep-$base-$too_long",
                         "--sep-$base-$too_long",
                         "small_garbage"],
        };
        # Fail if the base is upped.
        next if $i == $#bases;
        my $next_base = $bases [$i + 1];
        push @{$tests [-1] {fail}} => "sep-$next_base-$group" 
               unless $[ < 5.00503;
    }

    push @tests  => {
        name     => "-base=$base; -sep; " .
                    "-group=$group_sizes[0],$group_sizes[-1]",
        re       => $RE {num} {int}
                              {-base  =>  $base}
                              {-group => "$group_sizes[0],$group_sizes[-1]"}
                              {-sep},
        sub      => \&RE_num_int,
        sub_args => [-base  => $base,
                     -group => "$group_sizes[0],$group_sizes[-1]",
                     -sep   =>],
        pass     => [ map {;"sep-$base-$_",
                          "+-sep-$base-$_",
                          "--sep-$base-$_"} @group_sizes],
        fail     => [  "sep-$base-$too_long",
                     "+-sep-$base-$too_long",
                     "--sep-$base-$too_long",
                     "garbage"],
    };

    foreach my $length (1 .. $max_length) {
        push @tests  => {
            name     => "-base=$base; -places=$length",
            re       => $RE {num} {int} {-base => $base} {-places => $length},
            sub      => \&RE_num_int,
            sub_args => [-base => $base, -places => $length],
            pass     => ["exact-$base-$length",
                       "+-exact-$base-$length",
                       "--exact-$base-$length"],
            fail     => ["small_garbage",
                         map  {;"exact-$base-$_"}
                         grep {$_ ne $length} 1 .. $max_length],
        }
    }

    #
    # Eh, I don't like this. Too much randomness makes that the number
    # of tests isn't constant.
    #
    foreach my $pair (sample $mini_size, @pairs) {
        my ($low, $high) = @$pair;
        push @tests  => {
            name     => "-base=$base; -places=$low,$high",
            re       => $RE {num} {int} {-base => $base}
                                        {-places => "$low,$high"},
            sub      => \&RE_num_int,
            sub_args => [-base => $base, -places => "$low,$high"],
            pass     => [map {;"exact-$base-$_",
                             "+-exact-$base-$_",
                             "--exact-$base-$_",}
                         sample $mini_size,
                                 grep {$low <= $_ && $_ <= $high}
                                 1 .. $max_length],
            fail     => ["small_garbage",
                         sample $mini_size, map  {;"exact-$base-$_"}
                                            grep {$_ < $low || $high < $_}
                                            1 .. $max_length],
        }
    }
}


run_new_tests  targets      => \%targets,
               tests        => \@tests,
               version_from => 'Regexp::Common::number',
;


__END__
