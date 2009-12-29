# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST COMMA-SEPARATED

try $RE{list};

fail "a";
pass "a,b";
pass "a,  b";
pass "a,b,c";
pass "a, b, c";
fail "a b";
fail "a   b";
fail "a b c";
fail "a  b  c";


# TEST TAB-SEPARATED

try $RE{list}{"-sep$;\t"};

fail "a";
pass "a\tb";
pass "a\tb";
pass "a\tb\tc";
pass "a\tb\tc";
fail "a b";
fail "a   b";
pass "a b\tc";
fail "a  b  c";


# TEST WORDS

try $RE{list}{and};

fail "a";
pass "a and b";
pass "a, b, and c";
pass "a, b and c";
fail "a,b,c";
fail "a, b, c";

try $RE{list}{conj};

fail "a";
pass "a and b";
pass "a, b, and c";
pass "a, b and c";
pass "a, b, or c";
pass "a, b or c";
fail "a,b,c";
fail "a, b, c";

try $RE{list}{conj}{-word => 'ou'};

fail "a";
pass "a ou b";
pass "a, b, ou c";
pass "a, b ou c";
fail "a,b,c";
fail "a, b, c";


# TRY NESTED PATTERNS


try $RE{list}{"-pat$;$RE{quoted}"};

fail q{a};
pass q{'a', 'b'};
fail q{'a', 'b' and 'c'};
pass q{'a', "b", `c`};
fail q{a, b, c};


try $RE{list}{"-pat$;$RE{quoted}"}{-lastsep => '\s*(and|or)\s*'};

fail q{a};
pass q{'a' and 'b'};
pass q{'a', 'b' and 'c'};
fail q{'a', "b", `c`};
pass q{'a', "b" or `c`};
fail q{a, b, c};
