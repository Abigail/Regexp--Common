# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST BASE 10

try $RE{num}{real}{-base => '10'}{-sep};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass 1.23456789;
pass 12.23456789;
pass 123.23456789;
fail 1234.23456789;
pass '+1';
pass '+12';
fail '+1234567.89';
pass '+1,234,567.89';
pass '-1';
pass '-12.333333333333333333333333333333333333333';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1,234,567";
pass "12,345.6789";
fail "1,2345,6789";
fail "1.2345.6789";


# TRY WIERD ORDERING 

try $RE{-base => '10'}{num}{'-sep' => ' '}{real};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass 1.23456789;
pass 12.23456789;
pass 123.23456789;
fail 1234.23456789;
pass '+1';
pass '+12';
fail '+1234567.89';
pass '+1 234 567.89';
pass '-1';
pass '-12.333333333333333333333333333333333333333';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1 234 567";
pass "12 345.6789";
fail "1 2345 6789";
fail "1.2345.6789";


# TRY FANCY FLAGS

try $RE{-base=>10}{num}{-sep=>' '}{real};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass 1.23456789;
pass 12.23456789;
pass 123.23456789;
fail 1234.23456789;
pass '+1';
pass '+12';
fail '+1234567.89';
pass '+1 234 567.89';
pass '-1';
pass '-12.333333333333333333333333333333333333333';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1 234 567";
pass "12 345.6789";
fail "1 2345 6789";
fail "1.2345.6789";

try $RE{num}{dec}{-sep};

pass 0;
pass 1;
pass 12;
fail 1234567;
pass 1.23456789;
pass '+1';
pass '+12';
fail '+1234567.89';
pass '-1';
pass '-12.333333333333333333333333333333333333333';
fail '-1234567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1,234,567";
pass "12,345.6789";
fail "1,2345,6789";
fail "1.2345.6789";


# TEST BASE 2

try $RE{num}{real}{'-base' => '2'}{-sep};

pass 0;
pass 1;
fail 12;
fail 1234567;
fail 1.23456789;
pass '+1';
fail '+12';
fail '+101010';
fail '+101010.0001010';
pass '+101,010.0001010';
fail '+1234567.89';
pass '-1';
pass -1;
fail "a"; 
fail "";
fail "1a";
fail "- 1010";
pass "1,001,101";
pass "1,010.1110";
fail "1,0101,0011";
fail "1.0011.0011";

try $RE{num}{bin}{-sep};

pass 0;
pass 1;
fail 12;
fail 1234567;
fail 1.23456789;
pass '+1';
fail '+12';
fail '+101010';
fail '+101010.0001010';
fail '+1234567.89';
pass '-1';
pass -1;
fail "a"; 
fail "";
fail "1a";
fail "- 1010";
pass "1,001,101";
pass "1,010.1110";
fail "1,0101,0011";
fail "1.0011.0011";


# TEST BASE 8

try $RE{num}{real}{'-base' => '8'}{-sep};

pass 0;
pass 1;
pass 12;
fail 1234567;
fail 12345678;
pass 1.23456;
pass '+1';
pass '+12';
fail '+1234567.01';
fail '+1234567.09';
pass '-1';
pass '-12.333333333333333333333333333333333333333';
fail '-1234567';
fail '-1234568';
pass -1;
pass -12;
fail -1234567;
fail -1234568;
pass 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1,234,567";
pass "12,345.67";
fail "12,345.68";
fail "1,2345,5670";
fail "1.234.567";

try $RE{num}{oct}{-sep};

pass 0;
pass 1;
pass 12;
fail 1234567;
fail 12345678;
pass 1.23456;
pass '+1';
pass '+12';
fail '+1234567.01';
fail '+1234567.09';
pass '-1';
pass '-12.333333333333333333333333333333333333333';
fail '-1234567';
fail '-1234568';
pass -1;
pass -12;
fail -1234567;
fail -1234568;
pass 1.2;
fail "a"; 
fail "";
fail "1a";
fail "- 1234";
pass "1,234,567";
pass "12,345.67";
fail "12,345.68";
fail "1,2345,5670";
fail "1.234.567";


# TEST BASE 16

try $RE{num}{real}{'-base' => '16'}{-sep};

pass 0;
pass 1;
pass 12;
fail '12A4C67';
fail '12345678G';
pass '1.23A56';
fail '1.23Z56';
pass '+1';
pass '+12';
fail '+1234567.01A';
fail '+1234567.09Q';
pass '-1';
pass '-12.ddddddddddddddddddddddddddddddddddddddd';
fail '-123B4567';
fail '-123H4567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
pass "a"; 
fail "";
pass "1a";
pass "a1a";
fail "DeadBeef";
pass "De,adB,eef";
fail "LiveLamb";
fail "- 1234";
pass "1,abc,def";
pass "12,345.67A";
fail "12,3C5,68";
fail "1,23C5,5670";
fail "1.234.567";

try $RE{num}{hex}{-sep};

pass 0;
pass 1;
pass 12;
fail '12A4C67';
fail '12345678G';
pass '1.23A56';
fail '1.23Z56';
pass '+1';
pass '+12';
fail '+1234567.01A';
fail '+1234567.09Q';
pass '-1';
pass '-12.ddddddddddddddddddddddddddddddddddddddd';
fail '-123B4567';
fail '-123H4567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
pass "a"; 
fail "";
pass "1a";
pass "a1a";
fail "DeadBeef";
fail "LiveLamb";
fail "- 1234";
pass "1,abc,def";
pass "12,345.67A";
fail "12,3C5,68";
fail "1,23C5,5670";
fail "1.234.567";


# TEST BASE 34

try $RE{num}{real}{'-base' => '34'}{-sep};

pass 0;
pass 1;
pass 12;
fail '12A4C67';
fail '12345678G';
pass '1.23A56';
fail '1.23Z56';
pass '+1';
pass '+12';
fail '+1234567.01A';
fail '+1234567.09Q';
pass '-1';
pass '-12.ddddddddddddddddddddddddddddddddddddddd';
fail '-123B4567';
fail '-123H4567';
pass -1;
pass -12;
fail -1234567;
pass 1.2;
pass "a"; 
fail "";
pass "1a";
pass "a1a";
fail "DeadBeef";
fail "LiveLamb";
pass "De,adB,eef";
pass "Li,veL,amb";
fail "- 1234";
pass "1,abc,def";
pass "12,345.67A";
fail "12,3C5,68";
fail "1,23C5,5670";
fail "1.234.567";
