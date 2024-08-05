# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

sub try2  {$P = qr /$_[0]$/}
sub pass2 {ok ($S=($_[0] =~ $P && $& eq $_[1]))}
sub fail2 {ok ($S=($_[0] !~ $P || $& ne $_[1]))}

# LOAD

use Regexp::Common;
ok;

my @ids = (
   ['"'      =>  [[Pascal => 'Workshop']]],
);

my @from_to = (
   [[[Pascal => 'Workshop']] =>  "/*", "*/"],

   [[qw /Pascal/, [Pascal => 'Workshop']] =>  "{",  "}"],

   [[qw /Pascal/, [Pascal => 'Workshop']] =>  "(*", "*)"],

   [[qw /Pascal/]                =>  "{", "*)"],
   [[qw /Pascal/]                =>  "(*", "}"],

);


foreach my $info (@ids) {
    my ($mark, $languages) = @$info;
    my $not_mark = $mark eq '#' ? '!' : '#';
    foreach my $language (@$languages) {
        if (ref $language) {
            try $RE{comment}{$language -> [0]}{$language -> [1]};
            $language = join ":" => @$language;
        }
        else {
            try $RE{comment}{$language};
        }

        $M .= "# $language\n";

        pass qq !${mark}${mark}!;
        pass qq !${mark}a comment${mark}!;
        pass qq !${mark}/*a comment */${mark}!;
        pass qq !${mark}/************${mark}!;
        pass qq !${mark}/////////////${mark}!;
        fail qq !${mark}a${mark}${mark}multiline${mark}${mark}comment${mark}!;
        fail qq !${mark}a comment!;
        fail qq !${mark}/*a comment */!;
        fail qq !${mark}/************!;
        fail qq !${mark}/////////////!;
        fail qq !${not_mark}${mark}!;
        fail qq !${not_mark}a comment${mark}!;
        fail qq !${not_mark}/*a comment */${mark}!;
        fail qq !${not_mark}/************${mark}!;
        fail qq !${not_mark}${mark}////////////${mark}!;
        fail qq !//a comment${mark}!;
        fail qq !///*a comment */${mark}!;
        fail qq !///************${mark}!;
        fail qq !///////////////${mark}!;
        fail qq !//a${mark}//multiline${mark}//comment${mark}!;
        fail qq !//a comment!;
        fail qq !///*a comment */!;
        fail qq !///************!;
        fail qq !///////////////!;
        next if $language eq 'Pascal:Workshop';
        fail qq !/*a comment */!;
        fail qq !/************/!;
        fail qq !/*a${mark}multiline${mark}comment*/!;
        fail qq !/*a /*pretend*/ nested comment*/!;
        fail qq !/*a /*pretend*/!;
    }
}

foreach my $info (@from_to) {
    my ($languages, $from, $to) = @$info;
    my $f = substr $from => 0, 1;
    my $t = substr $to   => 0, 1;

    foreach my $language (@$languages) {
        if (ref $language) {
            try $RE{comment}{$language -> [0]}{$language -> [1]};
            $language = join ":" => @$language;
        }
        else {
            try $RE{comment}{$language};
        }

        my $mark = $language eq 'Nickle' ? ';' : '#';

        $M .= "# $language\n";

        pass "${from}a comment ${to}";
        my @str = ("${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${to}",
                   "${from}${t}${to}",
        );
        if (${to} =~ /^(?:\Q${t}\E)+$/) {fail $_ for @str;}
        else                            {pass $_ for @str;}
        if ($language eq 'Pascal:Alice') {
            fail "${from}a\nmultiline\ncomment${to}";
        }
        else {
            pass "${from}a\nmultiline\ncomment${to}";
        }
        pass "${from}${to}";
        fail "${from}a ${from}pretend${to} nested comment${to}";
        pass "${from}a ${from}pretend${to}";
        pass "${from} {) ${to}";
        fail "${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}";
        fail "${mark}\n";
        fail "${mark}a comment\n";
        fail "${mark}${from}a comment ${to}\n";
        fail "${mark}${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}\n";
        fail "${mark}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}\n";
        fail "${mark}a\n${mark}multiline\n${mark}comment\n";
        fail "${mark}a comment";
        fail "${mark}${from}a comment ${to}";
        fail "${mark}${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}";
        fail "${mark}${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${to}";
        fail "${mark}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}";
    }
}
    

try $RE{comment}{SQL}{MySQL};

$M .= "# SQL:MySQL\n";

pass "-- \n";
pass "-- a comment\n";
pass "--\ta comment\n";
pass "--\x{A0}a comment\n";
pass "-- /*a comment */\n";
pass "-- /************\n";
pass "-- /////////////\n";
pass "-- ---\n";
fail "--- --\n";
pass "--\n";
pass "-- ---/////////////\n";
fail "-- a\n-- multiline\n-- comment\n";
fail "-- a comment";
fail "-- /*a comment */";
fail "-- /************";
fail "-- /////////////";
pass "#\n";
pass "#a comment\n";
pass "#/*a comment */\n";
pass "#/************\n";
pass "#--////////////\n";
fail "//a comment\n";
fail "///*a comment */\n";
fail "///************\n";
fail "///////////////\n";
fail "//a\n//multiline\n//comment\n";
fail "//a comment";
fail "///*a comment */";
fail "///************";
fail "///////////////";
pass '/*a comment */';
pass '/************/';
pass '/*************/';
pass "/*a\nmultiline\ncomment*/";
fail "/*a /*pretend*/ nested comment*/";
pass "/*a /*pretend*/";
fail "/***********";
pass "/* Comment ';' */";
pass '/* Comment ";" */';


try $RE{comment}{Brainfuck};

$M .= "# Brainfuck\n";

pass "This is a comment";
pass "   ";
pass "\n";
pass "\x80\x90\xA0";
fail "[]";
fail "<";
fail "------";
fail "This is - a - comment";

try $RE{comment}{'Algol 68'};

$M .= "# Algol 68\n";

pass "# This is a comment #";
pass "co foo bar co";
pass "co co";
pass "co This is a comment co";
pass "comment This code isn't executed comment";
pass "comment\nMultiline\ncomment";
fail "######################";
fail "# This is not a comment\n";
fail "# # #";
fail "co co co";
fail "comment comment comment";
fail "# Wrong closer co";
fail "# Wrong closer comment";
fail "co foo bar baco";
fail "  # foo #";
fail "# foo #   ";

try $RE{comment}{Squeak};

$M .= "# Squeak\n";

pass '"This is a comment"';
pass '"###########"';
pass '"//"';
pass '""';
pass '"Comment "" with "" double "" quotes"';
fail '#####';
fail '"Multiline"' . "\n" . '"comment"';
fail '"Comment';
fail '"Comment " comment"';
fail '"Comment """ comment"';

try2 $RE{comment}{Fortran}{fixed};

$M .= "# Fortran:fixed\n";

pass2 "!This is a comment\n",   "!This is a comment\n";
pass2 "CThis is a comment\n",   "CThis is a comment\n";
pass2 "cThis is a comment\n",   "cThis is a comment\n";
pass2 "*This is a comment\n",   "*This is a comment\n";
pass2 "  !This is a comment\n", "!This is a comment\n";
fail  "  CThis is a comment\n";
fail  "  cThis is a comment\n";
fail  "  *This is a comment\n";
fail  "!This is a comment";
fail  "CThis is a comment";
fail  "cThis is a comment";
fail  "*This is a comment";
pass2 "    !This is a comment\n",   "!This is a comment\n";
fail  "     !This is a comment\n";
pass2 "      !This is a comment\n", "!This is a comment\n";


try $RE{comment}{Beatnik};

$M .= "# Beatnik\n";

pass "is";
pass "IS";
pass "whiskers";
fail "whisker";
fail "Zulu";
fail "Hello";
fail "Is a";
fail "Is;";

try2 $RE{comment}{COBOL};

$M .= "# COBOL\n";
fail  "This is a comment\n";
fail  "*This is a comment\n";
fail  " *This is a comment\n";
fail  "  *This is a comment\n";
fail  "   *This is a comment\n";
fail  "    *This is a comment\n";
fail  "     *This is a comment\n";
pass2 "      *This is a comment\n", "*This is a comment\n";
fail  "       *This is a comment\n";
fail  "        *This is a comment\n";
fail  "         *This is a comment\n";
fail  "      !This is a comment\n";
fail  "      *This is a comment";
fail  "      *This is a comment\n     *This is a comment\n";
pass2 "      ******************\n",  "******************\n";

