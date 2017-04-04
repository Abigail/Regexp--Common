#!/usr/bin/perl

use strict;
use lib "blib/lib", ".";

use Regexp::Common qw /RE_comment_ALL/;
use t::Common qw /run_new_tests ww/;


use warnings;


# 1. List of tokens.
# 2. List of languages.
my @data   = do {
    no warnings;
    (
        {start_tokens =>  ["\\"],  # No qw here, 5.6.0 parses it incorrectly.
         languages    =>  [qw {ABC Forth}],
        },
        {start_tokens =>  [qw {# //}],
         languages    =>  [qw {Advisor}],
        },
        {start_tokens =>  [qw {--}],
         languages    =>  [qw {Ada Alan Eiffel lua}],
        },
        {start_tokens =>  [qw {;}],
         languages    =>  [qw {Advsys CQL Lisp LOGO M MUMPS REBOL Scheme
                                      SMITH zonefile}],
        },
        {start_tokens =>  [qw {#}],
         languages    =>  [qw {awk fvwm2 Icon m4 mutt Perl Python QML R Ruby
                               shell Tcl}],
        },
        {start_tokens =>  [qw {* ! REM}],
         languages    =>  [[BASIC => 'mvEnterprise']],
        },
        {start_tokens =>  [qw {//}],
         languages    =>  [qw {beta-Juliet Portia Ubercode},
                           q  {Crystal Report}],
        },
        {start_tokens =>  [qw {%}],
         languages    =>  [qw {CLU LaTeX TeX slrn}],
        },
        {start_tokens =>  [qw {!}],
         languages    =>  [qw {Fortran}],
        },
        {start_tokens =>  [qw {NB}],
         languages    =>  [qw {ILLGOL}],
        },
        {start_tokens =>  ["PLEASE NOT", "PLEASE   NOT", "PLEASE N'T", 
                           "DO NOT", "DO     N'T", "DO    NOT",
                           "PLEASE DO NOT", "PLEASE   DO    NOT",
                           "PLEASE  DO  N'T"],
         languages    =>  [qw {INTERCAL}]},
        {start_tokens =>  [qw {NB.}],
         languages    =>  [qw {J}],
        },
        {start_tokens =>  [qw !{!],
         languages    =>  [[qw {Pascal Alice}]],
         end_tokens   =>  [qw !}!],
        },
        {start_tokens =>  [qw {. ;}],
         languages    =>  [qw {PL/B}],
        },
        {start_tokens =>  [qw {`}],
         languages    =>  [qw {Q-BAL}],
        },
        {start_tokens =>  [qw {-- --- -----}],
         languages    =>  [qw {SQL}],   # SQL comments start with /-{2,}/
        },
        {start_tokens =>  ['\\"'], # No qw here, 5.6.0 parses it incorrectly.
         languages    =>  [qw {troff}],
        },
        {start_tokens =>  [qw {"}],
         languages    =>  [qw {vi}],
        },
        {start_tokens =>  [qw {'}],
         languages    =>  [qw {ZZT-OOP}],
        },
    );
};


#
# Extract the markers.
#
# my @tokens = map {@{$$_ {start_tokens}}} @data;
my @tokens;
foreach my $data (@data) {
    if ($$data {end_tokens}) {
        push @tokens =>
              map {[$$data {start_tokens} [$_] =>
                    $$data {end_tokens}   [$_]]} 0 .. $#{$$data {start_tokens}};
    }
    else {
        push @tokens => map {[$_ => "\n"]} @{$$data {start_tokens}}
    }
}


#
# Some basic comments, not including delimiters.
#
my @comments = ("", "This is a comment", "A\tcomment", "Another /* comment");

# Targets, and test suites.
my %targets;
my @tests;
my @bad;

foreach my $token (@tokens) {
    my ($start, $end) = @$token;
    my $pass_key      = "pass_${start}_${end}";
    my $fail_key      = "fail_${start}_${end}";
    my @my_bad;

    $targets {$pass_key} = {
        list   => \@comments,
        query  => sub {$start . $_ [0] . $end},
        wanted => sub {$_, $start, $_ [0], $end},
    };

    # No trailing newline.
    push @bad => map {"$start$_"} @comments;
    # No leading token.
    push @bad => map {"$_$end"} @comments;
    # Double newlines.
    push @my_bad => map {"$start$_$end$end"} @comments;
    # Double comments.
    push @my_bad => map {"$start$_$end" x 2} @comments;
    # Garbage trailing the comments.
    push @my_bad => map {"$start$_$end" . ww (1, 5)} @comments;
    # Garbage leading the comments.
    push @my_bad => map {ww (1, 5) . "$start$_$end"} @comments;

    $targets {$fail_key} = {
        list   => \@my_bad
    }
}

# A few extras.
push @bad => ("/* This is a C comment */",
              "(*  This is a Pascal comment *)",
              "<!-- This is an HTML comment -->");

$targets {bad} = {
    list => \@bad
};

foreach my $entry (@data) {
    my ($start_tokens, $langs) = @$entry {qw /start_tokens languages/};
    my $end_tokens = $$entry {end_tokens} ? $$entry {end_tokens}
                                          : [("\n") x @$start_tokens];

    my @my_tokens = map {[$$start_tokens [$_], $$end_tokens [$_]]}
                         0 .. $#$start_tokens;
    my %my_tokens = map {$_ => 1}
                    map {join _ => $$start_tokens [$_], $$end_tokens [$_]}
                         0 .. $#$start_tokens;

    my   @pass_tokens = map {join _ => "pass", $$start_tokens [$_],
                                               $$end_tokens   [$_]}
                             0 .. $#$start_tokens;


    #
    # Find out what should fail.
    #
    # 1. A global 'bad' list.
    #
    my   @fail_tokens = ("bad");
    #
    # 2. Failures for our tokens.
    #
    push @fail_tokens => map {join _ => "fail", $$start_tokens [$_],
                                                $$end_tokens   [$_]}
                              0 .. $#$start_tokens;
    #
    # 3. Passes for tokens that aren't ours, and don't "fit" ours.
    #
  TOKEN:
    foreach my $token (@tokens) {
        my ($start, $end) = @$token;
        foreach my $my_token (@my_tokens) {
            my ($my_start, $my_end) = @$my_token;
            if ($start =~ /^\Q$my_start\E/ && $end =~ /\Q$my_end\E$/) {
                next TOKEN;
            }
        }
        push @fail_tokens => join _ => pass => @$token;
    }

    foreach my $lang (@$langs) {
        my $name = ref $lang ? join "/" => @$lang : $lang;
        my $re   = ref $lang ? $RE {comment} {$lang -> [0]} {$lang -> [1]}
                             : $RE {comment} {$lang};
        my $sub  = ref $lang ? join "_" => "RE_comment", @$lang
                             : "RE_comment_$lang";
        $sub =~ s/\W/X/g;

        no strict 'refs';
        push @tests => {
            name    => $name,
            regex   => $re,
            sub     => \&$sub,
            pass    => \@pass_tokens,
            fail    => \@fail_tokens,
        };
    }
}

run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::comment',


__END__
