# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/$_[0]/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

try $RE{ws}{crop};

pass "  a sentence here\t\t";
pass "  a sentence here";
pass "a sentence here\t\t";
fail "a sentence here";

ok $RE{ws}{crop}->matches("  a sentence here\t\t");
ok $RE{ws}{crop}->matches("  a sentence here");
ok $RE{ws}{crop}->matches("a sentence here\t\t");
ok ! $RE{ws}{crop}->matches("a sentence here");

ok 'a sentence here' eq $RE{ws}{crop}->subs("  a sentence here\t\t");
ok 'a sentence here' eq $RE{ws}{crop}->subs("  a sentence here");
ok 'a sentence here' eq $RE{ws}{crop}->subs("a sentence here\t\t");
ok 'a sentence here' eq $RE{ws}{crop}->subs("a sentence here");
