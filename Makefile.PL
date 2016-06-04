#!/usr/bin/perl

use 5.10.0;

use strict;

use ExtUtils::MakeMaker;

my @tests = qw [t/*.t t/*/*.t];

my %args  = (
    NAME                 => 'Regexp::Common',
    VERSION_FROM         => 'lib/Regexp/Common.pm',
    ABSTRACT_FROM        => 'lib/Regexp/Common.pm',
    PREREQ_PM            => {
        'vars'                    => 0,
        'strict'                  => 0,
        'warnings'                => 0,
        'Config'                  => 0,
    },
    MIN_PERL_VERSION     =>  5.010,
    AUTHOR               => 'Abigail <regexp-common@abigail.be>',
    LICENSE              => 'mit',
    META_MERGE           => {
       "meta-spec"       => {version => 2},
        license          => [qw [mit bsd artistic_1 artistic_2]],

        #
        # This section is provided for laughts and giggles only.
        # It seems to be completely and utterly ignored when
        # running "perl Makefile.PL", and extracting the information
        # from PREREQ_PM instead.
        #
        # The result will be that less and less tests will be run,
        # as we're are moving towards using Test::Regexp, which is
        # never going to be a prerequisite to running Regexp::Common.
        #
        prereqs          => {
            configure        => {
                requires         => {
                    'ExtUtils::MakeMaker' => 0,
                    'strict'              => 0,
                    'warnings'            => 0,
                },
            },
            runtime          => {
                requires         => {
                    'vars'                => 0,
                    'strict'              => 0,
                    'warnings'            => 0,
                    'Config'              => 0,
                },
            },
            test             => {
                requires         => {
                    'Test::More'          => 0,
                },
                recommends       => {
                    'Test::Regexp'        => 0,
                },
            },
        },
        resources        => {
            repository   => 'git://github.com/Abigail/Regexp--Common.git',
        },
        keywords         => ['regular expression', 'pattern'],
    },
    test                 => {
        TESTS                => $^O eq 'MSWin32'
                                ? "@{[map {glob} @tests]}" : "@tests"
    },
);


$args {BUILD_REQUIRES}     = $args {PREREQ_PM};
$args {CONFIGURE_REQUIRES} = $args {PREREQ_PM};
$args {TEST_REQUIRES}      = {
                                 %{$args {PREREQ_PM}}, 
                                 "Test::More"  => 0,
                             };


my %filter = (
    MIN_PERL_VERSION     => '6.48',
    META_MERGE           => '6.46',
    AUTHOR               => '6.07',
    ABSTRACT_FROM        => '6.07',
    LICENSE              => '6.07',
);

delete $args {$_} for grep {defined $filter {$_} &&
                            $ExtUtils::MakeMaker::VERSION lt $filter {$_}}
                            keys %args;


WriteMakefile %args;

__END__
