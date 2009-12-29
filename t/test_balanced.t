# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;
exit unless $] >= 5.006;


# SIMPLE BALANCING ACT

try $RE{balanced};

pass "()";
pass "(a)";
pass "(a b)";
pass "(a()b)";
pass "(a( )b)";
pass "(a(b))";
pass "(a(b)(c)(d(e)))";
pass "(a(])b)";
pass "(a({{{)b)";
fail "(";
fail "(a";
fail "(a(b)";
fail "(a( b)";
fail "(a(]b)";
fail "(a({{{)b";


# MULTIPLE BALANCING ACT

try $RE{balanced}{-parens=>"()[]"};

pass "()";
pass "(a)";
pass "(a b)";
pass "(a()b)";
pass "(a( )b)";
pass "(a(b))";
pass "(a(b)(c)(d(e)))";
pass "(a(})b)";
pass "(a([[()]])b)";
fail "(";
fail "(a";
fail "(a(b)";
fail "(a( b)";
fail "(a(]b)";
fail "(a([[[)b";
