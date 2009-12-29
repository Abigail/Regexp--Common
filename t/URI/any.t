# $Id: any.t,v 2.101 2003/02/02 03:09:30 abigail Exp $
#
# $Log: any.t,v $
# Revision 2.101  2003/02/02 03:09:30  abigail
# File moved to t/URI
#
# Revision 2.100  2003/01/21 23:19:13  abigail
# The whole world understands RCS/CVS version numbers, that 1.9 is an
# older version than 1.10. Except CPAN. Curse the idiot(s) who think
# that version numbers are floats (in which universe do floats have
# more than one decimal dot?).
# Everything is bumped to version 2.100 because CPAN couldn't deal
# with the fact one file had version 1.10.
#
# Revision 1.11  2002/08/06 14:43:40  abigail
# Local phone numbers can have "future extensions" as well.
#
# Revision 1.10  2002/08/06 13:02:58  abigail
# Cosmetic changes.
#
# Revision 1.9  2002/08/06 12:59:38  abigail
# Added tests for 'tel:' URIs.
#
# Revision 1.8  2002/08/05 12:23:55  abigail
# Moved tests for FTP and HTTP URIs to separate files.
# 
# Revision 1.7  2002/08/04 23:06:52  abigail
# Quoted a bareword.
# 
# Revision 1.6  2002/08/04 22:55:17  abigail
# Added tests for $RE{URI}{FTP}{-test}
# 
# Revision 1.5  2002/08/04 22:52:07  abigail
# Added FTP URIs.
# 
# Revision 1.4  2002/08/04 19:52:22  abigail
# Testing {-scheme} for HTTP URIs.
# 
# Revision 1.3  2002/08/04 19:36:11  abigail
# First set of URI regexes is ready.
# 
# Revision 1.2  2002/07/31 13:15:42  abigail
# Regexp::Common::URL isn't ready for shipment yet.
# 
# Revision 1.1  2002/07/25 19:57:27  abigail
# Tests for URL regexes.
# 

# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST URIs

try $RE{URI};

pass 'http://www.example.com';
pass 'http://www.example.com/';
pass 'http://www.example.com/some/file/some/where';
pass 'http://www.example.com/some/directory/some/where';
pass 'http://www.example.com:80/some/file';
pass 'http://127.0.0.1';
pass 'http://127.0.0.1/';
pass 'http://127.0.0.1:12345/some/file';
pass 'http://www.example.com:80/some/path?query';
pass 'http://www.example.com/%7Eabigail/';
# Test "safe" chars.
pass 'http://www.example.com/--_$.+++';
pass 'http://www.example.com/.';
# Test "extra" chars.
pass "http://www.example.com/**!(),,''";
# Test HTTP additional chars.
pass 'http://www.example.com/:;@=&=;';
pass 'http://www.example.com/some/path?query';
pass 'http://www.example.com/some/path?funny**!(),,:;@=&=';
pass 'http://www.example.com/some/?';
pass 'http://www.example.com/?';
pass 'http://www.example.com//////////////';
# Usernames/passwords are NOT allowed in http URIs.
fail 'http://abigail@www.example.com';
fail 'http://abigail@www.example.com:80/some/file';
fail 'http://abigail:secret@www.example.com:80/some/file';
fail 'http://abigail:secret@127.0.0.1:80/some/file';
# ~ was NOT allowed by RFC 1738, but currently is.
pass 'http://www.example.com/~abigail/';
# Fail on "national" characters.
fail 'http://www.example.com/nope|nope';
fail 'http://www.example.com/`';
# Fail on "punctation" characters.
fail 'http://www.example.com/some/file#target';
# Two question marks used to be failure, but is now allowed.
pass 'http://www.example.com/some/path?query1?query2';
pass 'http://www.example.com/some/??';
# Can have slashes in query.
pass 'http://www.example.com/some/path?query/path';
# Scheme must be lower case, and correct.
fail 'HTTP://www.example.com/';

pass 'ftp://ftp.example.com';
pass 'ftp://ftp.example.com/';
pass 'ftp://ftp.example.com/some/file/some/where';
pass 'ftp://ftp.example.com/some/directory/some/where/';
pass 'ftp://ftp.example.com:21/some/file';
pass 'ftp://127.0.0.1';
pass 'ftp://127.0.0.1/';
pass 'ftp://127.0.0.1:12345/some/file';
pass 'ftp://ftp.example.com/%7Eabigail/';
fail 'ftp://ftp.example.com:21/some/path?query';
# Test "safe" chars.
pass 'ftp://ftp.example.com/--_$.+++';
pass 'ftp://ftp.example.com/.';
# Test "extra" chars.
pass "ftp://ftp.example.com/**!(),,''";
# Test URI additional chars.
pass 'ftp://www.example.com/:@=&=';
pass 'ftp://www.example.com//////////////';
# Should fail on ';'.
fail 'ftp://www.example.com/some/path;here';
# Usernames/passwords are allowed in ftp URIs.
pass 'ftp://abigail@ftp.example.com';
pass 'ftp://abigail@ftp.example.com:21/some/file';
pass 'ftp://abigail:secret@ftp.example.com:21/some/file';
pass 'ftp://abigail:secret@127.0.0.1:21/some/file';
pass 'ftp://abigail:secret:here@127.0.0.1:21/some/file';
# ~ was NOT allowed by RFC 1738, but currently is.
pass 'ftp://ftp.example.com/~abigail/';
# Fail on "national" characters.
fail 'ftp://ftp.example.com/nope|nope';
fail 'ftp://ftp.example.com/`';
# Fail on "punctation" characters.
fail 'ftp://www.example.com/some/file#target';
# Cannot have queries.
fail 'ftp://ftp.example.com/some/path?query1?query2';
fail 'ftp://ftp.example.com/some/??';
fail 'ftp://ftp.example.com/some/path?query/path';
# Test type.
pass 'ftp://ftp.example.com/some/path;type=A';
pass 'ftp://ftp.example.com/some/path;type=i';
pass 'ftp://abigail@ftp.example.com/some/path/somewhere;type=a',
fail 'ftp://ftp.example.com/some/path;type=Q';
fail 'ftp://ftp.example.com/some/path;type=AI';
pass 'ftp://ftp.example.com/;type=I';
# Scheme must be lower case, and correct.
fail 'HTTP://ftp.example.com/';
fail 'FTP://ftp.example.com/';
fail 'feeble://ftp.example.com/';

pass 'tel:+12345';
pass 'tel:+358-555-1234567';
pass 'tel:456-7890;phone-context=213';
pass 'tel:456-7890;phone-context=X-COMPANY-NET';
pass 'tel:+1-212-555-1234;tsp=terrifictelecom.com';
pass 'tel:+1-212-555-1234;tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
pass 'tel:+358-555-1234567;postd=pp22';
pass 'tel:0w003585551234567;phone-context=+3585551234';
pass 'tel:+1234567890;phone-context=+1234;vnd.company.option=foo';
pass 'tel:+1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
pass 'tel:+1234;option=%22!%22';
pass 'tel:+1234;option=%22%5C%22%22';
pass 'tel:+1234;option=%22%5C!%22';
pass 'tel:+1234;option=%22bar%22';
pass 'tel:+456-7890;phone-context=213;phone-context=213';
pass 'tel:456-7890;phone-context=213;phone-context=213';
fail 'tel:456-7890';
fail 'tel:+1-800-RUN-PERL';
fail 'tel:+1234;option=%22%22%22';
fail 'tel:+1234;option=%22%5C%22';
pass 'tel:+123-456-789;isub=123(456)';
pass 'tel:+123456;postd=***';
