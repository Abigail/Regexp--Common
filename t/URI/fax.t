# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST URIs

try $RE{URI}{fax};
pass 'fax:+12345';
pass 'fax:+358-555-1234567';
pass 'fax:456-7890;phone-context=213';
pass 'fax:456-7890;phone-context=X-COMPANY-NET';
pass 'fax:+1-212-555-1234;tsp=terrifictelecom.com';
pass 'fax:+1-212-555-1234;tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
pass 'fax:+358-555-1234567;postd=pp22';
pass 'fax:0w003585551234567;phone-context=+3585551234';
pass 'fax:+1234567890;phone-context=+1234;vnd.company.option=foo';
pass 'fax:+1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
pass 'fax:+1234;option=%22!%22';
pass 'fax:+1234;option=%22%5C%22%22';
pass 'fax:+1234;option=%22%5C!%22';
pass 'fax:+1234;option=%22bar%22';
pass 'fax:+456-7890;phone-context=213;phone-context=213';
pass 'fax:456-7890;phone-context=213;phone-context=213';
pass 'fax:+12345;tsub=0123456789-.()';
pass 'fax:+358-555-123456;tsub=0123456789-.()7';
pass 'fax:456-7890;tsub=0123456789-.();phone-context=213';
pass 'fax:456-7890;tsub=0123456789-.();phone-context=X-COMPANY-NET';
pass 'fax:+1-212-555-1234;tsub=0123456789-.();tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
fail 'fax:456-7890';
fail 'fax:+1-800-RUN-PERL';
fail 'fax:+1234;option=%22%22%22';
fail 'fax:+1234;option=%22%5C%22';
pass 'fax:+123-456-789;isub=123(456)';
pass 'fax:+123456;postd=***';
fail 'fax:456-7890;phone-context=213;tsub=0123456789-.()';
fail 'fax:456-7890;tsub=213;tsub=456';
fail 'fax:456-7890;tsub=213;';


try $RE{URI}{fax}{nofuture};
pass 'fax:+12345';
pass 'fax:+358-555-1234567';
pass 'fax:456-7890;phone-context=213';
pass 'fax:456-7890;phone-context=X-COMPANY-NET';
pass 'fax:+1-212-555-1234;tsp=terrifictelecom.com';
pass 'fax:+1-212-555-1234;tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
pass 'fax:+358-555-1234567;postd=pp22';
pass 'fax:0w003585551234567;phone-context=+3585551234';
fail 'fax:+1234567890;phone-context=+1234;vnd.company.option=foo';
fail 'fax:+1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
fail 'fax:+1234;option=%22!%22';
fail 'fax:+1234;option=%22%5C%22%22';
fail 'fax:+1234;option=%22%5C!%22';
fail 'fax:+1234;option=%22bar%22';
pass 'fax:+456-7890;phone-context=213;phone-context=213';
pass 'fax:456-7890;phone-context=213;phone-context=213';
fail 'fax:456-7890';
fail 'fax:+1-800-RUN-PERL';
fail 'fax:+1234;option=%22%22%22';
fail 'fax:+1234;option=%22%5C%22';
fail 'fax:+358-555-1234567;phone-context=+1234;postd=pp22';
pass 'fax:+123-456-789;isub=123(456)';
fail 'fax:+123-456-789;isub=123(456);isub=123(456)';
fail 'fax:+123-456-789;isub=A23(456)';
pass 'fax:+123456;postd=***';
fail 'fax:1234567890;phone-context=+1234;vnd.company.option=foo';
fail 'fax:1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
fail 'fax:1234;option=%22!%22';
fail 'fax:1234;option=%22%5C%22%22';
fail 'fax:1234;option=%22%5C!%22';
fail 'fax:1234;option=%22bar%22';
fail 'fax:+12345;tsub=foo';
fail 'fax:456-7890;tsub=213;tsub=456';
fail 'fax:456-7890;tsub=213;';
pass 'fax:456-7890;tsub=0123456789-.();phone-context=213';
pass 'fax:456-7890;tsub=0123456789-.();phone-context=X-COMPANY-NET';
pass 'fax:+1-212-555-1234;tsub=0123456789-.();tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
