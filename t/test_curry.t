# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

my $num = $RE{num}{real};

# TEST BASE 10

try $num->{'-base' => '10'}{-sep};

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


# TEST BASE 2

try $num->{'-base' => '2'}{-sep};

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
