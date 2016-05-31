# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common 'RE_ALL';
ok;

try RE_balanced;
pass '(a(b))';
fail '(a(b)';

try RE_num_real;
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try RE_num_dec;
pass '-1.234e+567', qw( - 1.234 1 . 234 e +567 + 567 );

try RE_num_real(-base=>2,-expon=>'x2\^');
pass '-101.010x2^101010', qw( - 101.010 101 . 010 x2^ 101010 ), "", "101010";

try RE_num_bin;
pass '-101.010E101010', qw( - 101.010 101 . 010 E 101010 ), "", "101010";

try RE_num_real(-base=>10, -sep);
pass '-1,234,567.234e+567';

try RE_comment_C;
pass '/*abc*/', qw( /* abc */ );

try RE_comment_CXX;
pass '/*abc*/';
pass "// abc\n";

try RE_comment_Perl;
pass "# abc\n", "#", " abc", "\n";

try RE_comment_shell;
pass "# abc\n", "#", " abc", "\n";

try RE_comment_HTML;
pass "<!-- A comment -->", "<!", "-- A comment --", " A comment ", ">";


try RE_delimited(-delim=>'/');
pass '/a\/b/', qw( / a\/b / );

try RE_delimited(-delim=>'/', -esc=>'/');
pass '/a//b/', qw( / a//b / );

try RE_net_IPv4;
pass '123.234.1.0', qw( 123 234 1 0 );

try RE_list_conj(-word=>'(?:and|or)');
pass 'a, b, and c', ', and ';

my $profane    = 'uneqba';
my $contextual = 'funttref';
foreach ($profane, $contextual) { tr/A-Za-z/N-ZA-Mn-za-m/ }

try RE_profanity;
pass $profane;

try RE_profanity_contextual;
pass $contextual;
