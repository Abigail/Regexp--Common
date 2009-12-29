# $Id: test_comments.t,v 2.111 2008/05/26 17:07:26 abigail Exp $
#
# $Log: test_comments.t,v $
# Revision 2.111  2008/05/26 17:07:26  abigail
# use warnings
#
# Revision 2.110  2005/03/16 00:20:33  abigail
# Moved many comments to t/comment/*.t
#
# Revision 2.109  2004/12/28 23:07:01  abigail
# Moved tests into seperate files in t/comment
#
# Revision 2.108  2004/06/09 21:41:04  abigail
# test_comments.t
#
# Revision 2.107  2003/09/24 08:39:36  abigail
# Stupid "syntax" warning issues false positives
#
# Revision 2.106  2003/08/19 21:27:56  abigail
# Nickle language
#
# Revision 2.105  2003/08/13 10:07:39  abigail
# Added patterns for C--, C#, Cg and SLIDE comments
#
# Revision 2.104  2003/08/01 11:30:25  abigail
# Comments for 'QML' and 'PL/SQL'
#
# Revision 2.103  2003/03/12 22:25:48  abigail
# - Comments for Advisor, Advsys, Alan, Algol 60, Algol 68, B,
#   BASIC (mvEnterprise), Forth, Fortran (both fixed and free form),
#   fvwm2, mutt, Oberon, 6 versions of Pascal,
#   PEARL (one of the at least four...), PL/B, PL/I, slrn, Squeak.
#
# Revision 2.102  2003/02/21 14:50:52  abigail
# Crystal Reports
#
# Revision 2.101  2003/02/07 15:26:16  abigail
# Lua and FPL
#
# Revision 2.100  2003/01/21 23:19:13  abigail
# The whole world understands RCS/CVS version numbers, that 1.9 is an
# older version than 1.10. Except CPAN. Curse the idiot(s) who think
# that version numbers are floats (in which universe do floats have
# more than one decimal dot?).
# Everything is bumped to version 2.100 because CPAN couldn't deal
# with the fact one file had version 1.10.
#
# Revision 1.15  2002/09/04 17:04:28  abigail
# Q-BAL
#
# Revision 1.14  2002/08/27 16:31:31  abigail
# Beatnik requires 5.008.
#
# Revision 1.13  2002/08/27 16:10:22  abigail
# + More languages tested using data arrays (@ids, @from_to, @plain_or_nested).
# + Added tests for Beatnik, Befunge-98, Funge-98, Shelta, SMITH and *W.
#
# Revision 1.12  2002/08/21 15:57:48  abigail
# Combined all the tests for comments of the form "foo" to eol,
# using a data array, as in Regexp::Common::comment.
#
# Tests for beta-Juliet, Portia, ILLGOL and Brainfuck.
#
# Revision 1.11  2002/08/20 17:33:06  abigail
# Haifu tests
#
# Revision 1.10  2002/08/20 17:04:57  abigail
# Tests for Hugo
# 
# Revision 1.9  2002/07/31 23:13:22  abigail
# Made the tests for Dylan and Haskell comment conditional of the Perl
# version. Version 5.6.0 or above is required.
# 
# Revision 1.8  2002/07/31 14:48:23  abigail
# Added LOGO (to please petdance)
# 
# Revision 1.7  2002/07/31 13:07:11  abigail
# Tests for MySQL, Dylan and Haskell.
# 
# Revision 1.6  2002/07/31 00:31:31  abigail
# Added tests for Haskell, Dylan and Smalltalk.
# 
# Revision 1.5  2002/07/30 16:38:58  abigail
# Added tests for the languages: LaTeX, Tcl, TeX and troff.
# 
# Revision 1.4  2002/07/26 16:36:08  abigail
# Added tests for new language comments.
# 
# Revision 1.3  2002/07/23 21:38:20  abigail
# Added a few more test for HTML comments.
# 
# Revision 1.2  2002/07/23 21:15:07  abigail
# Added $RE{comment}{HTML}.
# 
# Revision 1.1  2002/07/23 12:22:51  abigail
# Initial revision
# 
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

ok (defined $Regexp::Common::comment::VERSION &&
            $Regexp::Common::comment::VERSION =~ /^\d+[.]\d+$/);

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
pass "-- /*a comment */\n";
pass "-- /************\n";
pass "-- /////////////\n";
pass "-- ---\n";
fail "--- --\n";
fail "--\n";
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
pass "/*a\nmultiline\ncomment*/";
fail "/*a /*pretend*/ nested comment*/";
pass "/*a /*pretend*/";
fail "/***********";
pass "/* Comment ;";
fail "/* Comment ; */";
pass "/* Comment ';' */";
pass "/* Comment ';' ;";
pass '/* Comment ";" */';
pass '/* Comment ";" ;';
pass "/* Comment '\n;*/' */";
pass "/* Comment '*/' more comment */";


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

exit if $] < 5.006;

exit if $] < 5.008;

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

