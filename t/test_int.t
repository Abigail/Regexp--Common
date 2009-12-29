# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST NUMBERS

try $RE{num}{int};

pass 0;
pass 1;
pass 12;
pass 1234567;
pass '+1';
pass '+12';
pass '+1234567';
pass '-1';
pass '-12';
pass '-1234567';
pass -1;
pass -12;
pass -1234567;
fail 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
fail "1,234,567";
fail "1,2345,6789";
fail "1.2345.6789";

try $RE{num}{int}{-sep};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass '+1';
pass '+12';
fail '+1234567';
pass '-1';
pass '-12';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
fail 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1,234,567";
fail "1,2345,6789";
fail "1.2345.6789";

try $RE{num}{int}{-sep}{'-group' => '4'};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass '+1';
pass '+12';
fail '+1234567';
pass '-1';
pass '-12';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
fail 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
fail "1,234,567";
pass "1,2345,6789";
fail "1.2345.6789";

try $RE{num}{int}{'-group' => '4'}{'-sep' => '[.]'};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass '+1';
pass '+12';
fail '+1234567';
pass '-1';
pass '-12';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
fail 1.2 if $] > 5.00502;	# REGEX BUG
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
fail "1,234,567";
fail "1,2345,6789";
pass "1.2345.6789";

try $RE{num}{int}{'-group' => '4'}{'-sep' => '[.,]'};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass '+1';
pass '+12';
fail '+1234567';
pass '-1';
pass '-12';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
fail 1.2 if $] > 5.00502;	# REGEX BUG
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
fail "1,234,567";
pass "1,2345,6789";
pass "1.2345.6789";
