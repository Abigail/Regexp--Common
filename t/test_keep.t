# $Id: test_keep.t,v 2.101 2003/04/02 20:58:02 abigail Exp $
#
# $Log: test_keep.t,v $
# Revision 2.101  2003/04/02 20:58:02  abigail
# $; is no longer set to '='
#
# Revision 2.100  2003/01/21 23:19:13  abigail
# The whole world understands RCS/CVS version numbers, that 1.9 is an
# older version than 1.10. Except CPAN. Curse the idiot(s) who think
# that version numbers are floats (in which universe do floats have
# more than one decimal dot?).
# Everything is bumped to version 2.100 because CPAN couldn't deal
# with the fact one file had version 1.10.
#
# Revision 1.19  2002/09/18 18:12:39  abigail
# Ignore warnings for 5.005
#
# Revision 1.18  2002/08/27 16:30:29  abigail
# Tests for Beatnik comments.
#
# Revision 1.17  2002/08/20 17:04:57  abigail
# Tests for Hugo
#
# Revision 1.16  2002/08/09 15:12:00  abigail
# Added test for generic balanced strings.
#
# Revision 1.15  2002/08/06 13:02:58  abigail
# Cosmetic changes.
#
# Revision 1.14  2002/08/06 12:59:38  abigail
# Added tests for 'tel:' URIs.
#
# Revision 1.13  2002/08/05 20:22:36  abigail
# Tests for $RE{net}{domain}
#
# Revision 1.12  2002/08/04 22:52:07  abigail
# Added FTP URIs.
# 
# Revision 1.11  2002/08/04 19:52:22  abigail
# Testing {-scheme} for HTTP URIs.
# 
# Revision 1.10  2002/08/04 19:36:11  abigail
# First set of URI regexes is ready.
# 
# Revision 1.9  2002/07/31 23:15:17  abigail
# Added tests for MAC addresses.
# 
# Revision 1.8  2002/07/31 13:07:11  abigail
# Tests for MySQL, Dylan and Haskell.
# 
# Revision 1.7  2002/07/31 00:31:09  abigail
# Tests for Smalltalk.
# 
# Revision 1.6  2002/07/28 22:17:55  abigail
# Changed a qw// with commas to a list of strings to keep -w happy.
# 
# Revision 1.5  2002/07/26 16:36:08  abigail
# Added tests for new language comments.
# 
# Revision 1.4  2002/07/25 23:58:05  abigail
# Cosmetic changes (again).
# 
# Revision 1.3  2002/07/25 23:57:35  abigail
# Cosmetic changes.
# 
# Revision 1.2  2002/07/23 22:49:06  abigail
# Added tests for $RE{comment}{HTML}.
# 
# Revision 1.1  2002/07/23 12:22:51  abigail
# Initial revision
# 

# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{my($S,@M)=@_;my $C=0;unshift@M,$S;
print"wanted\t[",join('][',@M),"]\n";print"got\t[",join('][',$S=~$P),"]\n";}
sub pass{my($S,@M)=@_;my$C=0;unshift@M,$S;foreach($S=~$P){++$C and next
if(shift()eq$_);ok(0)&&return;}ok($C>0);}

# Shut up some warnings for 5.005.
$SIG{__WARN__} = sub { };

# LOAD

use Regexp::Common;
ok;

if ($] >= 5.006) {
	try $RE{balanced}{-keep};
	pass '(a(b))';

        try $RE{balanced}{-begin => ">>"}{-end => "<<"}{-keep};
        pass '>>>>>>a<<>>b<<<<>>c<<<<';
}
try $RE{num}{real}{-keep};
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try $RE{num}{dec}{-keep};
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try $RE{num}{real}{'-base' => '2'}{-expon=>'x2\^'}{-keep};
pass '-101.010x2^101010', qw( - 101.010 101 . 010 x2^ 101010 ), "", "101010";

try $RE{num}{bin}{-keep};
pass '-101.010E101010', qw( - 101.010 101 . 010 E 101010 ), "", "101010";

try $RE{num}{real}{'-base' => '10'}{-sep}{-keep};
pass '-1,234,567.234e+567', "-", "1,234,567.234", "1,234,567", ".",
                            "234", "e", "+567", "+", "567";

try $RE{comment}{C}{-keep};
pass '/*abc*/', qw( /* abc */ );

try $RE{comment}{'C++'}{-keep};
pass '/*abc*/';
pass "// abc\n";

try $RE{comment}{Perl}{-keep};
pass "# abc\n", "#", " abc", "\n";

try $RE{comment}{shell}{-keep};
pass "# abc\n", "#", " abc", "\n";

try $RE{comment}{Eiffel}{-keep};
pass "-- A comment\n", "--", " A comment", "\n";
pass "---- A comment\n", "--", "-- A comment", "\n";

try $RE{comment}{SQL}{-keep};
pass "-- A comment\n", "--", " A comment", "\n";
pass "---- A comment\n", "----", " A comment", "\n";

try $RE{comment}{HTML}{-keep};
pass "<!-- A comment -->", "<!", "-- A comment --", " A comment ", ">";
pass "<!---->", "<!", "----", "", ">";
pass "<!-- A -- -- B -- >", "<!", "-- A -- -- B -- ", " B ", ">";

try $RE{comment}{Smalltalk}{-keep};
pass '"A comment"', '"', 'A comment', '"';

unless ($] < 5.006) {
    try $RE{comment}{Dylan}{-keep};
    pass "// Comment\n";
    pass "/* Nested /* Comment */ */";

    try $RE{comment}{Haskell}{-keep};
    pass "--- Comment\n";
    pass "{- Nested {- Comment -} -}";

    try $RE{comment}{Hugo}{-keep};
    pass "!comment\n";
    pass "!\\!\\ \\!\\!";
}

unless ($] < 5.008) {
    try $RE{comment}{Beatnik}{-keep};
    pass "is";
    pass "whiskers";
}

try $RE{delimited}{qq{-delim$;/}}{-keep};
pass '/a\/b/', qw( / a\/b / );

try $RE{delimited}{qq{-delim$;/}}{qq{-esc$;/}}{-keep};
pass '/a//b/', qw( / a//b / );

try $RE{net}{IPv4}{-keep};
pass '123.234.1.0', qw( 123 234 1 0 );

try $RE{net}{MAC}{-keep};
pass '12:34:56:78:9a:bc', qw /12 34 56 78 9a bc/;

try $RE{net}{domain}{-keep};
pass 'host.example.com';

try $RE{list}{conj}{-word=>'(?:and|or)'}{-keep};
pass 'a, b, and c', ', and ';

my $profane    = 'uneqba';
my $contextual = 'funttref';
foreach ($profane, $contextual) { tr/A-Za-z/N-ZA-Mn-za-m/ }

try $RE{profanity}{-keep};
pass $profane;

try $RE{profanity}{contextual}{-keep};
pass $contextual;

try $RE{URI}{HTTP}{-keep};
pass 'http://www.example.com:80/some/path?query',
     'http', 'www.example.com', '80',
     '/some/path?query', 'some/path?query', 'some/path', 'query';
pass 'http://www.example.com',
     'http', 'www.example.com', undef, undef, undef, undef, undef;
pass 'http://www.example.com/some/path?query',
     'http', 'www.example.com', undef,
     '/some/path?query', 'some/path?query', 'some/path', 'query';
pass 'http://www.example.com/some/path',
     'http', 'www.example.com', undef,
     '/some/path', 'some/path', 'some/path', undef;

try $RE{URI}{HTTP}{-keep}{-scheme => "https?"};
pass 'https://www.example.com:80/some/path?query',
     'https', 'www.example.com', '80',
     '/some/path?query', 'some/path?query', 'some/path', 'query';
pass 'https://www.example.com',
     'https', 'www.example.com', undef, undef, undef, undef, undef;
pass 'http://www.example.com/some/path?query',
     'http', 'www.example.com', undef,
     '/some/path?query', 'some/path?query', 'some/path', 'query';
pass 'http://www.example.com/some/path',
     'http', 'www.example.com', undef,
     '/some/path', 'some/path', 'some/path', undef;

try $RE{URI}{FTP}{-keep};
pass 'ftp://ftp.example.com/some/path/somewhere',
     'ftp', undef, undef, 'ftp.example.com', undef,
     '/some/path/somewhere', 'some/path/somewhere',
     'some/path/somewhere', undef;
pass 'ftp://abigail@ftp.example.com:21/some/path/somewhere;type=a',
     'ftp', 'abigail', undef, 'ftp.example.com', 21,
     '/some/path/somewhere;type=a', 'some/path/somewhere;type=a',
     'some/path/somewhere', 'a';

try $RE{URI}{FTP}{-keep}{-password};
pass 'ftp://abigail:secret@ftp.example.com:21/some/path/somewhere;type=a',
     'ftp', 'abigail', 'secret', 'ftp.example.com', 21,
     '/some/path/somewhere;type=a', 'some/path/somewhere;type=a',
     'some/path/somewhere', 'a';

try $RE{URI}{tel}{-keep};
pass 'tel:+123-456-7890;isub=543', 'tel', '+123-456-7890;isub=543';
