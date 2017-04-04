#!/usr/bin/perl

use strict;
use lib "blib/lib", ".";

use Regexp::Common qw /RE_comment_ALL/;
use t::Common qw /run_new_tests ww/;

use warnings;




# 1. tokens for single line comments.
# 2. start/end tokens for multi-line comments.
# 3. list of languages this applies to.
my @data = do {
    no warnings;
    (
        [[qw {//}]                  =>
         [[qw {/* */}]]             =>
         [qw {C++ C# Cg ECMAScript FPL Java JavaScript}],
        ],
        [[qw {#}]                   =>
         [[qw {/* */}]]             =>
         [qw {Nickle}],
        ],
        [[qw {//}]                  =>
         [[qw !{ }!], [qw !(* *)!]] =>
         [[qw /Pascal Delphi/], [qw /Pascal Free/], [qw /Pascal GPC/]],
        ],
        [[qw {!}]                   =>
         [[qw {/* */}]]             =>
         [qw {PEARL}]
        ],
        [[qw {# //}]                =>
         [[qw {/* */}]]             =>
         [qw {PHP}]
        ],
        [[qw {--}]                  =>
         [[qw {/* */}]]             =>
         [qw {PL/SQL}]
        ]
    );
};

# Grab the single line tokens.
my @s_tokens = do {my %h; grep {!$h {$_} ++} map {@{$$_ [0]}} @data};

# Grab the multiline line tokens.
my @mo_tokens = do {my %h; grep {!$h {$_} ++}
                           map {map {$$_ [0]} @{$$_ [1]}} @data};
my @mc_tokens = do {my %h; grep {!$h {$_} ++}
                           map {map {$$_ [1]} @{$$_ [1]}} @data};

my @comments = ("", "This is a comment", "This is a\nmultiline comment",
                "\n", (map {" $_ "} @s_tokens, @mo_tokens, @mc_tokens));
my @no_eol   = grep {!/\n/} @comments;

# Targets, and test suites.
my %targets;
my @tests;
my @bad;

# Tests for the single line comments (including failures).
foreach my $token (@s_tokens) {
    my $key  = "single_$token";
    my $fkey = "single_fail_$token";

    $targets {$key} = {
        list   => \@no_eol,
        query  => sub {$token . $_ [0] . "\n"},
    };

    my @s_bad;
    # No trailing newline.
    push @s_bad => map {"$token$_"} @no_eol;
    # Double newline.
    push @s_bad => map {"$token$_\n\n"} @no_eol;
    # Double comment.
    push @s_bad => map {"$token$_\n" x 2} @no_eol;
    # Leading garbage.
    push @s_bad => map {ww (1, 10) . "$token$_\n"} @no_eol;
    # Trailing garbage.
    push @s_bad => map {"$token$_\n" . ww (1, 10)} @no_eol;

    $targets {$fkey} = {
        list   => \@s_bad,
    };
}

# No leading token.
$targets {single_fail} = {
    list => [map {"$_\n"} @no_eol],
};

# Tests for the multi line comments (including failures).
for (my $i = 0; $i < @mc_tokens; $i ++) {
    my $start = $mo_tokens [$i];
    my $end   = $mc_tokens [$i];

    my $key   = "multi_${start}_$end";
    my $key2  = "multi2_${start}_$end";
    my $fkey  = "multi_fail_${start}_$end";

    my @list  = grep {!/\Q$end/} @comments;

    $targets {$key} = {
        list    => \@list,
        query   => sub {$start . $_ [0] . $end},
    };
    # Doubling the start token should be ok.
    $targets {$key2} = {
        list    => \@list,
        query   => sub {$start . $start . $_ [0] . $end},
    };

    my @m_bad;
    # No starting token.
    push @m_bad => map {"$_$end"} @comments;
    # No ending token.
    push @m_bad => map {"$start$_"} @comments;
    # Double the comment.
    push @m_bad => map {"$start$_$end" x 2} @comments;
    # Leading garbage.
    push @m_bad => map {ww (1, 5) . "$start$_$end"} @comments;
    # Trailing garbage.
    push @m_bad => map {"$start$_$end" . ww (1, 5)} @comments;

    $targets {$fkey} = {
        list    => \@m_bad,
    };
}

# No tokens at all.
$targets {fail} = {
    list => \@comments,
};

foreach my $data (@data) {
    my ($singles, $doubles, $langs) = @$data;
    my %s_seen;
    my %m_seen;
    $s_seen {$_}              = 1 for @$singles;
    $m_seen {join "_" => @$_} = 1 for @$doubles;

    my   @passes   =   map {"single_$_"} @$singles;
    push @passes   =>  map {join _ => "multi",  @$_} @$doubles;
    push @passes   =>  map {join _ => "multi2", @$_} @$doubles;
    my   @failures =   map {"single_$_"} grep {!$s_seen {$_}} @s_tokens;
    push @failures =>  map {"single_fail_$_"} @$singles;
    push @failures => "single_fail";
    # Multiline comments using *other* delimiters.
    push @failures =>  map  {join _ => "multi", $_}
                       grep {!$m_seen {$_}}
                       map  {join _ => $mo_tokens [$_], $mc_tokens [$_]}
                             0 .. $#mo_tokens;
    push @failures =>  map  {join _ => "multi_fail", @$_} @$doubles;
    push @failures => "fail";

    foreach my $lang (@$langs) {
        my $name = ref $lang ? join "/" => @$lang : $lang;
        my $sub  = ref $lang ? join "_" => "RE_comment", @$lang
                             : "RE_comment_$lang";
        $sub =~ s/\W/X/g;
        my $re   = ref $lang ? $RE {comment} {$$lang [0]} {$$lang [1]}
                             : $RE {comment} {$lang};

        no strict 'refs';
        push @tests => {
            name    => $name,
            re      => $re,
            sub     => \&{$sub},
            pass    => \@passes,
            fail    => \@failures,
        };
    }
}

run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::comment',


__END__
