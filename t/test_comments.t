# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST C COMMENTS

foreach my $language (qw /C LPC/) {
    try $RE{comment}{$language};

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

foreach my $language (qw /REBOL zonefile/) {
    try $RE{comment}{$language};

    pass ";\n";
    pass ";a comment\n";
    pass ";/*a comment */\n";
    pass ";/************\n";
    pass ";/////////////\n";
    fail ";a\n;multiline\n;comment\n";
    fail ";a comment";
    fail ";/*a comment */";
    fail ";/************";
    fail ";/////////////";
    fail "#\n";
    fail "#a comment\n";
    fail "#/*a comment */\n";
    fail "#/************\n";
    fail "#;////////////\n";
    fail "//a comment\n";
    fail "///*a comment */\n";
    fail "///************\n";
    fail "///////////////\n";
    fail "//a\n//multiline\n//comment\n";
    fail "//a comment";
    fail "///*a comment */";
    fail "///************";
    fail "///////////////";
    fail '/*a comment */';
    fail '/************/';
    fail "/*a\nmultiline\ncomment*/";
    fail "/*a /*pretend*/ nested comment*/";
    fail "/*a /*pretend*/";
    fail "/***********";
}

foreach my $language (qw /Ada Eiffel SQL/) {
    try $RE{comment}{$language};

    pass "--\n";
    pass "--a comment\n";
    pass "--/*a comment */\n";
    pass "--/************\n";
    pass "--/////////////\n";
    pass "-----\n";
    pass "-----/////////////\n";
    fail "--a\n--multiline\n--comment\n";
    fail "--a comment";
    fail "--/*a comment */";
    fail "--/************";
    fail "--/////////////";
    fail "#\n";
    fail "#a comment\n";
    fail "#/*a comment */\n";
    fail "#/************\n";
    fail "#--////////////\n";
    fail "//a comment\n";
    fail "///*a comment */\n";
    fail "///************\n";
    fail "///////////////\n";
    fail "//a\n//multiline\n//comment\n";
    fail "//a comment";
    fail "///*a comment */";
    fail "///************";
    fail "///////////////";
    fail '/*a comment */';
    fail '/************/';
    fail "/*a\nmultiline\ncomment*/";
    fail "/*a /*pretend*/ nested comment*/";
    fail "/*a /*pretend*/";
    fail "/***********";
}


try $RE{comment}{vi};

pass qq !"\n!;
pass qq !"a comment\n!;
pass qq !"/*a comment */\n!;
pass qq !"/************\n!;
pass qq !"/////////////\n!;
fail qq !"a\n"multiline\n"comment\n!;
fail qq !"a comment!;
fail qq !"/*a comment */!;
fail qq !"/************!;
fail qq !"/////////////!;
fail qq !#\n!;
fail qq !#a comment\n!;
fail qq !#/*a comment */\n!;
fail qq !#/************\n!;
fail qq !#"////////////\n!;
fail qq !//a comment\n!;
fail qq !///*a comment */\n!;
fail qq !///************\n!;
fail qq !///////////////\n!;
fail qq !//a\n//multiline\n//comment\n!;
fail qq !//a comment!;
fail qq !///*a comment */!;
fail qq !///************!;
fail qq !///////////////!;
fail qq !/*a comment */!;
fail qq !/************/!;
fail qq !/*a\nmultiline\ncomment*/!;
fail qq !/*a /*pretend*/ nested comment*/!;
fail qq !/*a /*pretend*/!;
fail qq !/***********!;

foreach my $language (qw /shell Perl Python awk Ruby Tcl/) {
    try $RE{comment}{$language};

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
    fail "//a comment\n";
    fail "///*a comment */\n";
    fail "///************\n";
    fail "///////////////\n";
    fail "//a\n//multiline\n//comment\n";
    fail "//a comment";
    fail "///*a comment */";
    fail "///************";
    fail "///////////////";
    fail '/*a comment */';
    fail '/************/';
    fail "/*a\nmultiline\ncomment*/";
    fail "/*a /*pretend*/ nested comment*/";
    fail "/*a /*pretend*/";
    fail "/***********";
}

foreach my $language (qw /TeX LaTeX/) {
    try $RE{comment}{$language};

    pass "%\n";
    pass "%a comment\n";
    pass "%/*a comment */\n";
    pass "%/************\n";
    pass "%/////////////\n";
    fail "%a\n%multiline\n%comment\n";
    fail "%a comment";
    fail "%/*a comment */";
    fail "%/************";
    fail "%/////////////";
    fail "//a comment\n";
    fail "///*a comment */\n";
    fail "///************\n";
    fail "///////////////\n";
    fail "//a\n//multiline\n//comment\n";
    fail "//a comment";
    fail "//%*a comment */";
    fail "//%************";
    fail "///////////////";
    fail '/*a comment */';
    fail '/************/';
    fail "/*a\nmultiline\ncomment*/";
    fail "/*a /*pretend*/ nested comment*/";
    fail "/*a /*pretend*/";
    fail "/***********";
}



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

try $RE{comment}{troff};

pass qq !\\"\n!;
pass qq !\\"a comment\n!;
pass qq !\\"/*a comment */\n!;
pass qq !\\"/************\n!;
pass qq !\\"/////////////\n!;
fail qq !\\"a\n\\"multiline\n\\"comment\n!;
fail qq !\\"a comment!;
fail qq !\\"/*a comment */!;
fail qq !\\"/************!;
fail qq !\\"/////////////!;
fail qq !#\n!;
fail qq !#a comment\n!;
fail qq !#/*a comment */\n!;
fail qq !#/************\n!;
fail qq !#"////////////\n!;
fail qq !//a comment\n!;
fail qq !//\\"*a comment */\n!;
fail qq !//\\"************\n!;
fail qq !///////////////\n!;
fail qq !//a\n//multiline\n//comment\n!;
fail qq !//a comment!;
fail qq !//\\"*a comment */!;
fail qq !//\\"************!;
fail qq !///////////////!;
fail qq !/*a comment */!;
fail qq !/************/!;
fail qq !/*a\nmultiline\ncomment*/!;
fail qq !/*a /*pretend*/ nested comment*/!;
fail qq !/*a /*pretend*/!;
fail qq !/***********!;

try $RE{comment}{Haskell};

pass "--\n";
pass "-- comment\n";
pass "{- comment -}";
pass "{- comment {- nested -} comment -}";
pass "{--}";
pass "{-{-{-{-{-{--}-}-}-}-}-}";
pass "{---}";
pass "{- -- -}";
pass "{---------------}";
pass "{-----{-------{-------}---{---}---}---}";
pass "{- {- -}}-}";
fail "-- comment";
fail "--";
fail "-\n";
fail "- comment\n";
fail "{- comment }";
fail "{- comment -";
fail "{-}";
fail "{-{-{--}-}";
fail "{- -}{- -}";
fail "-} {-";
fail "-} {- -}";
fail "{- {- -}}";

try $RE{comment}{Dylan};

pass "//\n";
pass "// comment\n";
pass "/* comment */";
pass "/* comment /* nested */ comment */";
pass "/**/";
pass "/*/*/*/*/*/**/*/*/*/*/*/";
pass "/***/";
pass "/* // */";
pass "/***************/";
pass "/* /***/ */";
fail "// comment";
fail "//";
fail "*\n";
fail "* comment\n";
fail "/* comment /";
fail "/* comment *";
fail "/*/";
fail "/*/*/**/*/";
fail "/* *//* */";
fail "*/ /*";
fail "*/ /* */";
fail "/* /* *//";
fail "/* /* *//*/";
fail "/*****/*******/*******/***/***/***/***/";

try $RE{comment}{Smalltalk};

pass qq !""!;
pass qq !"a comment"!;
pass qq !"/*a comment */"!;
pass qq !"/************"!;
pass qq !"/////////////"!;
fail qq !"a""multiline""comment"!;
fail qq !"a comment!;
fail qq !"/*a comment */!;
fail qq !"/************!;
fail qq !"/////////////!;
fail qq !#"!;
fail qq !#a comment"!;
fail qq !#/*a comment */"!;
fail qq !#/************"!;
fail qq !#"////////////"!;
fail qq !//a comment"!;
fail qq !///*a comment */"!;
fail qq !///************"!;
fail qq !///////////////"!;
fail qq !//a"//multiline"//comment"!;
fail qq !//a comment!;
fail qq !///*a comment */!;
fail qq !///************!;
fail qq !///////////////!;
fail qq !/*a comment */!;
fail qq !/************/!;
fail qq !/*a"multiline"comment*/!;
fail qq !/*a /*pretend*/ nested comment*/!;
fail qq !/*a /*pretend*/!;
fail qq !/***********!;

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
