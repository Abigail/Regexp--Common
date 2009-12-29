# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{my($S,@M)=@_;my $C=0;unshift@M,$S;
print"wanted\t[",join('][',@M),"]\n";print"got\t[",join('][',$S=~$P),"]\n";}
sub pass{my($S,@M)=@_;my$C=0;unshift@M,$S;foreach($S=~$P){++$C and next
if(shift()eq$_);ok(0)&&return;}ok($C>0);}

# LOAD

use Regexp::Common;
ok;

if ($] >= 5.006) {
	try $RE{balanced}{-keep};
	pass '(a(b))', 'a(b)';
}
try $RE{num}{real}{-keep};
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try $RE{num}{dec}{-keep};
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try $RE{num}{real}{'-base=2'}{-expon=>'x2\^'}{-keep};
pass '-101.010x2^101010', qw( - 101.010 101 . 010 x2^ 101010 ), "", "101010";

try $RE{num}{bin}{-keep};
pass '-101.010E101010', qw( - 101.010 101 . 010 E 101010 ), "", "101010";

try $RE{num}{real}{'-base=10'}{-sep}{-keep};
pass '-1,234,567.234e+567', qw( - 1,234,567.234 1,234,567 . 234 e +567 + 567 );

try $RE{comment}{C}{-keep};
pass '/*abc*/', qw( /* abc */ );

try $RE{comment}{'C++'}{-keep};
pass '/*abc*/';
pass "// abc\n";

try $RE{comment}{Perl}{-keep};
pass "# abc\n", "#", " abc", "\n";

try $RE{comment}{shell}{-keep};
pass "# abc\n", "#", " abc", "\n";

try $RE{comment}{HTML}{-keep};
pass "<!-- A comment -->", "<!", "-- A comment --", " A comment ", ">";
pass "<!---->", "<!", "----", "", ">";
pass "<!-- A -- -- B -- >", "<!", "-- A -- -- B -- ", " B ", ">";


try $RE{delimited}{q{-delim=/}}{-keep};
pass '/a\/b/', qw( / a\/b / );

try $RE{delimited}{q{-delim=/}}{q{-esc=/}}{-keep};
pass '/a//b/', qw( / a//b / );

try $RE{net}{IPv4}{-keep};
pass '123.234.1.0', qw( 123 234 1 0 );

try $RE{list}{conj}{-word=>'(?:and|or)'}{-keep};
pass 'a, b, and c', ', and ';

my $profane    = 'uneqba';
my $contextual = 'funttref';
foreach ($profane, $contextual) { tr/A-Za-z/N-ZA-Mn-za-m/ }

try $RE{profanity}{-keep};
pass $profane;

try $RE{profanity}{contextual}{-keep};
pass $contextual;
