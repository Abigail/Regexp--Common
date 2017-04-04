#!/usr/bin/perl

use strict;
use lib "blib/lib", ".";

use Regexp::Common qw /RE_comment_Pascal/;
use t::Common qw /run_new_tests/;

use warnings;


my @open  = qw [{ (*];
my @close = qw [} *)];


#
# Some basic comments, not including delimiters.
#
my @comments = ("", "This is a comment", "This is a\nmultiline comment",
                "\n", "*", "\n*\n", "**", "*****", "** **", "/*", "||");

# Targets, and test suites.
my %targets;
my @tests;

foreach my $start (@open) {
    foreach my $end (@close) {
        my  $lang      = "Pascal";
        my $pass_key   = "pass_${start}_${end}";
        my $fail_key   = "fail_${start}_${end}";

        $targets {$pass_key} = {
            list     => \@comments,
            query    => sub {$start . $_ [0] . $end},
            wanted   => sub {$_, $start, $_ [0], $end},
        };

        # Create bad comments.
        my @bad_comments;
        # No terminating token.
        push @bad_comments => map  {"$start$_"} @comments;
        # No starting token.
        push @bad_comments => map  {"$_$end"}
                              grep {index ($_, $start)} @comments;
        # Double terminators.
        push @bad_comments => map {"$start$_$end$end"} @comments;
        # Double the comment.
        push @bad_comments => map {"$start$_$end" x 2} @comments;
        # Different token.
        my @bad_open       =  qw [// /* --];
        my @bad_close      = (qw [*/ --], "\n");

        foreach my $close (@close) {
            push @bad_comments =>
                  map {my $o = $_; map {"ot$_$close"} @comments} @bad_open;
        }
        foreach my $open (@open) {
            push @bad_comments =>
                  map {my $c = $_; map {"$open$_$c"} @comments} @bad_close;
        }

        # No tokens.
        push @bad_comments => @comments;

        # Text preceeding comment.
        push @bad_comments => map {"Text $start$_$end"} @comments;
        # Some more.
        push @bad_comments => "<!-- This is an HTML  comment -->";
        push @bad_comments => "/*   This is a C      comment */";

        $targets {$fail_key} = {
            list     => \@bad_comments,
        };

        no strict 'refs';
        push @tests => {
            name     => $lang,
            regex    => $RE {comment} {$lang},
            sub      => \&{"RE_comment_$lang"},
            pass     => [$pass_key],
            fail     => [$fail_key],
        }
    }
}

run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::comment',


__END__
