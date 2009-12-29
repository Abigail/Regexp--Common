use ExtUtils::MakeMaker;
use 5.00473;
WriteMakefile (
    NAME         => 'Regexp::Common',
    VERSION_FROM => 'lib/Regexp/Common.pm',
    test         => {TESTS => 't/*.t t/*/*.t'},
);
