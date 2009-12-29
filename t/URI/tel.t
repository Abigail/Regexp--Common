# $Id: tel.t,v 2.101 2003/02/02 03:09:30 abigail Exp $
#
# $Log: tel.t,v $
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
# Revision 1.4  2002/08/06 14:43:40  abigail
# Local phone numbers can have "future extensions" as well.
#
# Revision 1.3  2002/08/06 12:59:38  abigail
# Added tests for 'tel:' URIs.
#
# Revision 1.2  2002/08/06 00:10:07  abigail
# Removed debugging statement
#
# Revision 1.1  2002/08/06 00:09:22  abigail
# Tests for tel URIs
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

try $RE{URI}{tel};
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


try $RE{URI}{tel}{nofuture};
pass 'tel:+12345';
pass 'tel:+358-555-1234567';
pass 'tel:456-7890;phone-context=213';
pass 'tel:456-7890;phone-context=X-COMPANY-NET';
pass 'tel:+1-212-555-1234;tsp=terrifictelecom.com';
pass 'tel:+1-212-555-1234;tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
pass 'tel:+358-555-1234567;postd=pp22';
pass 'tel:0w003585551234567;phone-context=+3585551234';
fail 'tel:+1234567890;phone-context=+1234;vnd.company.option=foo';
fail 'tel:+1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
fail 'tel:+1234;option=%22!%22';
fail 'tel:+1234;option=%22%5C%22%22';
fail 'tel:+1234;option=%22%5C!%22';
fail 'tel:+1234;option=%22bar%22';
pass 'tel:+456-7890;phone-context=213;phone-context=213';
pass 'tel:456-7890;phone-context=213;phone-context=213';
fail 'tel:456-7890';
fail 'tel:+1-800-RUN-PERL';
fail 'tel:+1234;option=%22%22%22';
fail 'tel:+1234;option=%22%5C%22';
fail 'tel:+358-555-1234567;phone-context=+1234;postd=pp22';
pass 'tel:+123-456-789;isub=123(456)';
fail 'tel:+123-456-789;isub=123(456);isub=123(456)';
fail 'tel:+123-456-789;isub=A23(456)';
pass 'tel:+123456;postd=***';
fail 'tel:1234567890;phone-context=+1234;vnd.company.option=foo';
fail 'tel:1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
fail 'tel:1234;option=%22!%22';
fail 'tel:1234;option=%22%5C%22%22';
fail 'tel:1234;option=%22%5C!%22';
fail 'tel:1234;option=%22bar%22';
