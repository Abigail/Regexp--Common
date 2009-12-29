# $Id: test_comments.t,v 2.100 2003/01/21 23:19:13 abigail Exp $
#
# $Log: test_comments.t,v $
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

# LOAD

use Regexp::Common;
ok;

my @markers  =   (
   ['--'     =>  [qw /Ada Eiffel/]],
   ['#'      =>  [qw /awk Perl Python Ruby shell Tcl/]],
   ['//'     =>  [qw /beta-Juliet Portia/]],
   ['NB'     =>  [qw /ILLGOL/]],
   [';'      =>  [qw /LOGO REBOL SMITH zonefile/]],
   ['`'      =>  [qw /Q-BAL/]],
   ['--'     =>  [qw /SQL/]],
   ['---'    =>  [qw /SQL/]],
   ['%'      =>  [qw /TeX LaTeX/]],
   ['\\"'    =>  [qw /troff/]],
   ['"'      =>  [qw /vi/]],
);

my @ids = (
   [';'      =>  [qw /Befunge-98 Funge-98 Shelta/]],
   [","      =>  [qw /Haifu/]],
   ['"'      =>  [qw /Smalltalk/]],
);

my @from_to = (
   [[qw /ALPACA C LPC/]   =>  "/*", "*/"],
   [[qw /False/]          =>  "{",  "}"],
   [[qw /*W/]             =>  "||", "!!"],
);

my @plain_or_nested = (                       
   {language  =>  [qw /Haskell/],
    single    =>  ["--", "---"],
    nested    =>  ["{-"  => "-}"],
   },
   {language  =>  [qw /Dylan/],
    single    =>  ["//"],
    nested    =>  ["/*"  => "*/"],
   },
   {language  =>  [qw /Hugo/],
    single    =>  ["!.", "!!", "!"],
    nested    =>  ["!\\" => "\\!"],
   },
);


foreach my $info (@markers) {
    my ($mark, $languages) = @$info;
    my $not_a_mark  = $mark eq '//' ? '/*' : '//';
    my $not_a_mark2 = $mark eq '/*' ? '{-' : '/*';
    my $not_a_mark3 = $mark eq '/*' ? '-}' : '*/';
    foreach my $language (@$languages) {

        try $RE{comment}{$language};

        pass "${mark}\n";
        pass "${mark}a comment\n";
        pass "${mark}${not_a_mark2}a comment ${not_a_mark3}\n";
        pass "${mark}${not_a_mark2}***********\n";
        pass "${mark}/////////////\n";
        fail "${mark}a\n${mark}multiline\n${mark}comment\n";
        fail "${mark}a comment";
        fail "${mark}${not_a_mark2}a comment ${not_a_mark3}";
        fail "${mark}/************";
        fail "${mark}/////////////";
        fail "${not_a_mark}a comment\n";
        fail "${not_a_mark}${mark}a comment\n";
        fail "${not_a_mark}${not_a_mark2}a comment ${not_a_mark3}\n";
        fail "${not_a_mark}/************\n";
        fail "${not_a_mark}/////////////\n";
        fail "${not_a_mark}a\n${not_a_mark}multiline\n${not_a_mark}comment\n";
        fail "${not_a_mark}a comment";
        fail "${not_a_mark}${not_a_mark2}a comment ${not_a_mark3}";
        fail "${not_a_mark}/************";
        fail "${not_a_mark}/////////////";
        fail '${not_a_mark2}a comment ${not_a_mark3}';
        fail '${not_a_mark2}**********${not_a_mark3}';
        fail "${not_a_mark2}a\nmultiline\ncomment${not_a_mark3}";
        fail "${not_a_mark2}a ${not_a_mark2}pretend" .
             "${not_a_mark3} nested comment${not_a_mark3}";
        fail "${not_a_mark2}a ${not_a_mark2}pretend${not_a_mark3}";
        fail "${not_a_mark2}**********";
    }
}


foreach my $info (@ids) {
    my ($mark, $languages) = @$info;
    my $not_mark = $mark eq '#' ? '!' : '#';
    foreach my $language (@$languages) {
        try $RE{comment}{$language};

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
        try $RE{comment}{$language};

        pass "${from}a comment ${to}";
        my $str = "${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${to}";
        if (${to} =~ /^(?:\Q${t}\E)+$/) {fail $str;}
        else                            {pass $str;}
        pass "${from}a\nmultiline\ncomment${to}";
        fail "${from}a ${from}pretend${to} nested comment${to}";
        pass "${from}a ${from}pretend${to}";
        fail "${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}";
        fail "#\n";
        fail "#a comment\n";
        fail "#${from}a comment ${to}\n";
        fail "#${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}\n";
        fail "#${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}\n";
        fail "#a\n#multiline\n#comment\n";
        fail "#a comment";
        fail "#${from}a comment ${to}";
        fail "#${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}";
        fail "#${from}${t}${t}${t}${t}${t}${t}${t}${t}${t}${t}${to}";
        fail "#${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}${f}";
    }
}
    

foreach my $language (qw /C++ Java/) {
    try $RE{comment}{$language};

    pass "//\n";
    pass "//a comment\n";
    pass "///*a comment */\n";
    pass "///************\n";
    pass "///////////////\n";
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
    fail "#\n";
    fail "#a comment\n";
    fail "#/*a comment */\n";
    fail "#/************\n";
    fail "#/////////////\n";
    fail "#a\n#multiline\n#comment\n";
    fail "#a comment";
    fail "#/*a comment */";
    fail "#/************";
    fail "#/////////////";
}


try $RE{comment}{PHP};

pass "//\n";
pass "//a comment\n";
pass "///*a comment */\n";
pass "///************\n";
pass "///////////////\n";
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
pass "#\n";
pass "#a comment\n";
pass "#/*a comment */\n";
pass "#/************\n";
pass "#/////////////\n";
fail "#a\n#multiline\n#comment\n";
fail "#a comment";
fail "#/*a comment */";
fail "#/************";
fail "#/////////////";


try $RE{comment}{HTML};

pass '<!-- A comment -->';
pass '<!-- A comment with trailing white space --   >';
pass "<!-- A comment with a new\nline -->";
pass "<!-- A comment with trailing new lines --\n\n>";
pass '<!-- Multi comment --  -- This is a comment too -->';
pass '<!---------------->';
pass '<!---->';
pass '<!-- A comment with - two - dashes -->';
pass '<!-- Multi comments with - two - dashes -- ---- >';
pass '<!-- -- --> Comment <!-- -- -->';
pass '<!------><a href = "http://cpan.perl.org">Click here!</a><!------>';
pass '<!>';   # Empty comment.
fail '<!->';
fail '<!-->';
fail '<!--->';
fail '<!-- Comment -- Not a comment -->';
fail '-- No MDO -->';
fail '<-- No MDO either -->';
fail '<!-- No MDC --';
fail '<! No leading COM -->';
fail '<!- No leading COM either -->';
fail '<!-- No trailing COM>';
fail '<!-- No trailing COM either ->';
fail '<!-- To many dashes --->';


try $RE{comment}{SQL}{MySQL};

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

pass "This is a comment";
pass "   ";
pass "\n";
pass "\x80\x90\xA0";
fail "[]";
fail "<";
fail "------";
fail "This is - a - comment";


exit if $] < 5.006;

foreach my $info (@plain_or_nested) {
    foreach my $language (@{$info -> {language}}) {
        try $RE{comment}{$language};

        foreach my $mark (@{$info -> {single}}) {
            my $half_mark = substr $mark, 0, -1;
            pass "${mark}\n";
            pass "${mark} comment\n";
            fail "${mark} comment";
            fail "${mark}";
            unless (grep {$_ eq $half_mark} @{$info -> {single}}) {
                fail "${half_mark}\n";
                fail "${half_mark} comment\n";
            }
        }

        my ($open, $close) = @{$info -> {nested}};

        my $m  = substr $open,  1;
        my $lc = substr $close, 1;
        my $fc = substr $close, 0, -1;

        pass "${open} comment ${close}";
        pass "${open} comment ${open} nested ${close} comment ${close}";
        pass "${open}${close}";
        pass "${open}${open}${open}${open}${close}${close}${close}${close}";
        pass "${open}${m}${close}";
        pass "${open} ${m}${m} ${close}";
        pass "${open}${m}${m}${m}${m}${m}${m}${m}${m}${m}${m}${m}${m}${close}";
        pass "${open} ${open} ${close}}${close}";
        pass "${open}${m}${m}${m}${m}${open}${m}${m}${m}${m}${m}${m}${open}"   .
             "${m}${m}${m}${m}${m}${close}${m}${m}${m}${open}${m}${close}${m}" .
             "${m}${close}${m}${m}${close}"
             unless "${m}${open}" =~ /^\Q${close}/;

        fail "${open} comment ${lc}";
        fail "${open} comment ${fc}";
        fail "${open}}";
        fail "${open}${open}${open}${close}${close}";
        fail "${open} ${close}${open} ${close}";
        fail "${close} ${open}";
        fail "${close} ${open} ${close}";
        fail "${open} ${open} ${close}}";
    }
}

exit if $] < 5.008;

try $RE{comment}{Beatnik};
pass "is";
pass "IS";
pass "whiskers";
fail "whisker";
fail "Zulu";
fail "Hello";
fail "Is a";
fail "Is;";
