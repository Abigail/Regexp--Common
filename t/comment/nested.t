#!/usr/bin/perl

use strict;
use lib "blib/lib", ".";

use Regexp::Common qw /pattern RE_comment_ALL/;
use t::Common qw /run_new_tests cross ww/;


use warnings;


pattern name   => [qw /comment fairy-language-1/],
        create => 
            sub {my $re = Regexp::Common::comment::nested "-(-", "-)-";
                 exists $_ [1] -> {-keep} ? qr /($re)/ : qr /$re/
            },
        version => 5.006
;

pattern name   => [qw /comment fairy-language-2/],
        create => 
            sub {my $re = Regexp::Common::comment::nested "(", ")";
                 exists $_ [1] -> {-keep} ? qr /($re)/ : qr /$re/
            },
        version => 5.006
;
                 

my @data = do {
    no warnings;
    (
        {
            nested_tokens  =>  [["(*" => "*)"]],
            languages      =>  [qw /Caml Modula-2 Modula-3/],
        },
        {
            start_tokens   =>  ["//"],
            nested_tokens  =>  [["/*" => "*/"]],
            languages      =>  [qw /Dylan/],
        },
        {
            start_tokens   =>  ["--", "---", "-----"],
            nested_tokens  =>  [["{-", "-}"]],
            languages      =>  [qw /Haskell/],
        },
        {
            start_tokens   =>  ["!"],    # Should not be followed by \
            nested_tokens  =>  [["!\\", "\\!"]],
            languages      =>  [qw /Hugo/],
        },
        {
            start_tokens   =>  ["#"],
            nested_tokens  =>  [["(*" => "*)"]],
            languages      =>  [qw /SLIDE/],
        },
        {
            nested_tokens  =>  [["-(-" => "-)-"]],
            languages      =>  [qw /fairy-language-1/],
        },
        {
            nested_tokens  =>  [["(" => ")"]],
            languages      =>  [qw /fairy-language-2/],
        },
    );
};

$$_ {start_tokens}  ||= [] for @data;
$$_ {nested_tokens} ||= [] for @data;

my @s_tokens = do {
    my %h;
    grep {!$h {$_} ++} map {@{$$_ {start_tokens}}} @data
};

my @pairs = do {
    my %h;
    grep {!$h {$$_ [0]} {$$_ [1]} ++} map {@{$$_ {nested_tokens}}} @data
};

#
# Create some comments.
#

my @comments = ("", "This is a comment", "This is a\nmultiline comment",
                "\n", map {" $_ "} @s_tokens);
my @no_eol   = grep {!/\n/} @comments;


my (%targets, @tests);
foreach my $s_token (@s_tokens) {
    my $pass_key = "start_pass_$s_token";
    my $fail_key = "start_fail_$s_token";

    $targets {$pass_key} = {
        list   =>  \@no_eol,
        query  =>  sub {$s_token . $_ [0] . "\n"},
    };

    # Build a list of "bad" comments.
    my @bad;
    # No trailing newline.
    push @bad => map {"$s_token$_"} @no_eol;
    # Double newline.
    push @bad => map {"$s_token$_\n\n"} @no_eol;
    # Double comment.
    push @bad => map {"$s_token$_\n" x 2} @no_eol;
    # Leading garbage.
    push @bad => map {ww (1, 10) . "$s_token$_\n"} @no_eol;
    # Trailing garbage.
    push @bad => map {"$s_token$_\n" . ww (1, 10)} @no_eol;

    $targets {$fail_key} = {
        list   => \@bad,
    };
}

my @parts = cross ["", "[]", "\n"],
                  ["", "7^%", "\n"],
                  ["", "comment", "\n"];

foreach my $pair (@pairs) {
    my ($start, $end) = @$pair;
    my $pass_key = "nested_pass_${start}_${end}";
    my $fail_key = "nested_fail_${start}_${end}";

    $targets {"${pass_key}_simple"} = {
        list   =>  \@comments,
        query  =>  sub {$start . $_ [0] . $end},
    };

    my @nested = map {$start . $$_ [0] . $start . $$_ [1] .
                      $end   . $$_ [2] . $end} @parts;

    $targets {"${pass_key}_nested"} = {
        list   =>  \@nested,
    };

    # Build a list of "bad" comments.
    my @bad;
    # No end token.
    push @bad => map {"$start$_"} @comments;
    # No begin token.
    push @bad => map {"$_$end"} @comments;
    # Double end token.
    push @bad => map {"$start$_$end$end"} @comments;
    # Double begin token.
    push @bad => map {"$start$start$_$end"} @comments;
    # Double comment.
    push @bad => map {"$start$_$end" x 2} @comments;
    # Leading garbage.
    push @bad => map {ww (1, 10) . "$start$_$end"} @comments;
    # Trailing garbage.
    push @bad => map {"$start$_$end" . ww (1, 10)} @comments;

    # Bad nested comments.
    # Extra start token.
    push @bad => map {"$start$_"} @nested;
    # Extra end token.
    push @bad => map {"$_$end"} @nested;
    # Leading garbage.
    push @bad => map {ww (1, 10) . $_} @nested;
    # Trailing garbage.
    push @bad => map {$_ . ww (1, 10)} @nested;
    # Double comment.
    push @bad => map {$_ x 2} @nested;

    $targets {$fail_key} = {
        list => \@bad
    };
}


foreach my $data (@data) {
    foreach my $language (@{$$data {languages}}) {
        my (@passes, @failures);
        foreach my $my_token (@{$$data {start_tokens}}) {
            push @passes   => "start_pass_$my_token";
            push @failures => "start_fail_$my_token";
        }
        foreach my $s_token (@s_tokens) {
            # Failure, unless there's a token that's a prefix of $s_token.
            my $ok = 1;
            foreach my $my_token (@{$$data {start_tokens}}) {
                $ok = 0 if index ($s_token, $my_token) == 0;
            }
            push @failures => "start_pass_$s_token" if $ok;
        }

        foreach my $my_pair (@{$$data {nested_tokens}}) {
            my ($my_start, $my_end) = @$my_pair;
            push @passes   => "nested_pass_${my_start}_${my_end}_simple",
                              "nested_pass_${my_start}_${my_end}_nested";
            push @failures => "nested_fail_${my_start}_${my_end}";
        }
        foreach my $pair (@pairs) {
            my ($start, $end) = @$pair;
            # Failure, unless there's a pair that fits.
            my $ok = 1;
            foreach my $my_pair (@{$$data {nested_tokens}}) {
                my ($my_start, $my_end) = @$my_pair;
                $ok = 0 if index ($start, $my_start) == 0 &&
                          rindex ($end, $my_end) ==
                          length ($end) - length ($my_end);
            }
            push @failures => "nested_pass_${start}_${end}_simple",
                              "nested_pass_${start}_${end}_nested" if $ok;
        }

       (my $sub = "RE_comment_$language") =~ s/\W/X/g;

        my $test = {
            name  =>  $language,
            re    =>  $RE {comment} {$language},
            pass  =>  \@passes,
            fail  =>  \@failures,
        };

        # If we call 'pattern' after the 'use Regexp::Common', we won't
        # (can't) import a subroutine.

        no strict 'refs';
        $$test {sub} = \&{$sub} if defined &{"main::$sub"};

        push @tests => $test;
    }
}


run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::comment',
              version      =>  5.006,
;


__END__
