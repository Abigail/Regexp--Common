# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common qw (RE_balanced RE_num_real);
ok;

try RE_balanced;
pass '(a(b))';
fail '(a(b)';

try RE_num_real;
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try RE_num_real(-base=>2,-expon=>'x2\^');
pass '-101.010x2^101010', qw( - 101.010 101 . 010 x2^ 101010 ), "", "101010";
