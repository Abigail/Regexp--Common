use ExtUtils::MakeMaker;
use 5.00473;
my @tests = qw {t/*.t t/*/*.t};
WriteMakefile (
    NAME         => 'Regexp::Common',
    VERSION_FROM => 'lib/Regexp/Common.pm',
    test         => {TESTS => $^O eq 'MSWin32'          
                              ? "@{[map {glob} @tests]}" : "@tests" }

);
