#!/usr/bin/perl

use strict;
use lib "blib/lib", ".";

use Regexp::Common qw /RE_comment_HTML/;
use t::Common qw /run_new_tests cross/;


use warnings;


my @good = ("", "This is a comment", "This is - a comment",
                "This is - - comment", ">This is a comment", 
                ">This is a comment<", "This is <a> comment",
                ">", "<>", "><", "<");
my @spec = ("", ">", "->", "<!", "-<");

sub ss {(!@_ && 1 < rand 4) ? ""   :
               (1 < rand 4) ? "\n" :
               (1 < rand 3) ? "\t" : " " x (1 + rand 5)};

my @spaced  = map {[$_, ss (1)]} @good;
my @crossed = cross \@good, \@good;
my @cross3  = map {[$_ -> [0], ss, $_ -> [1], ss, $_ -> [2], ss]}
                   cross \@spec, \@spec, \@spec;

# Targets, and test suites.
my %targets;
my @tests;

$targets {simple} =  {
    list          => \@good,
    query         => sub {"<!--$_[0]-->"},
    wanted        => sub {$_, "<!", "--$_[0]--", $_ [0], ">"},
};

$targets {simple_space} =  {
    list          => \@spaced,
    query         => sub {"<!--$_[0]--$_[1]>"},
    wanted        => sub {$_, "<!", "--$_[0]--$_[1]", $_ [0], ">"},
};

$targets {crossed} =  {
    list          => \@crossed,
    query         => sub {"<!--$_[0]----$_[1]-->"},
    wanted        => sub {$_, "<!", "--$_[0]----$_[1]--", $_ [1], ">"},
};

$targets {crossed2} =  {
    list          => \@cross3,
    query         => sub {"<!--$_[0]--$_[1]--$_[2]--$_[3]--$_[4]--$_[5]>"},
    wanted        => sub {$_, "<!",
                           "--$_[0]--$_[1]--$_[2]--$_[3]--$_[4]--$_[5]",
                          $_ [4], ">"},
};

my @bad = map {("<--$_-->",    # Missing !
                "<!-$_-->",    # Not enough dashes,
                "<!--$_->",    # Again.
                "<!----$_-->", # Too many starting dashes.
                "<! --$_-->",  # Space after <!
                "<!--$_--!>",  # Garbage after comment
               )} @good;

$targets {bad1} = {
    list        => \@bad,
};
$targets {bad2} = {
    list        => \@crossed,
    query       => sub {"<!--$_[0]--$_[1]-->"},
};

push @tests => {
    name          => 'HTML',
    regex         => $RE {comment} {HTML},
    pass          => [qw /simple simple_space crossed crossed2/],
    fail          => [qw /bad1 bad2/],
    sub           => \&RE_comment_HTML,
};


run_new_tests tests        => \@tests,
              targets      => \%targets,
              version_from => 'Regexp::Common::comment',
;


__END__
