# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

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


try $RE{balanced}{-begin => 'begin'}{-end => 'end'};

pass 'begin end';
fail 'begin en';
fail 'begin nd';
pass 'begin begin end end';
pass 'beginend';
pass 'beginbeginbeginendendend';
pass 'begin begin end begin begin end begin end end end';
fail 'begin begin end begin  egin end begin end end end';
fail 'begin end begin end';

try $RE{balanced}{-begin => 'start'}{-end => 'stop'};

pass 'start stop';
fail 'start st';
fail 'start op';
pass 'start start stop stop';
pass 'startstop';
pass 'startstartstartstopstopstop';
pass 'start start stop start start stop start stop stop stop';
fail 'start start stop start  tart stop start stop stop stop';
fail 'start stop start stop';

try $RE{balanced}{-parens => '()[]'}{-begin => 'start'}{-end => 'stop'};

pass 'start stop';
fail 'start st';
fail 'start op';
pass 'start start stop stop';
pass 'startstop';
pass 'startstartstartstopstopstop';
pass 'start start stop start start stop start stop stop stop';
fail 'start start stop start  tart stop start stop stop stop';
fail 'start stop start stop';

try $RE{balanced}{-begin => 'S'}{-end => 'T'};

pass 'S T';
fail 'S Q';
pass 'S S T T';
pass 'ST';
pass 'SSSTTT';
pass 'S S T S S T S T T T';
fail 'S S T S Q T S T T T';
fail 'S T S T';

try $RE{balanced}{-start => "(|["}{-end => ")|]"};

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

# Test '|' delimiters.

try $RE{balanced}{-begin => '\|'}{-end => '-'};

pass '| -';
fail '| Q';
pass '| | - -';
pass '|-';
pass '|||---';
pass '| | - | | - | - - -';
fail '| | - | Q - | - - -';
fail '| - | -';

try $RE{balanced}{-begin => '!'}{-end => '\|'};

pass '! |';
fail '! Q';
pass '! ! | |';
pass '!|';
pass '!!!|||';
pass '! ! | ! ! | ! | | |';
fail '! ! | ! Q | ! | | |';
fail '! | ! |';

try $RE{balanced}{-begin => '\||['} {-end => ')|]'};

pass "|)";
pass "|a)";
pass "|a b)";
pass "|a|)b)";
pass "|a| )b)";
pass "|a|b))";
pass "|a|b)|c)|d|e)))";
pass "|a|})b)";
pass "|a|[[|)]])b)";
fail "|";
fail "|a";
fail "|a|b)";
fail "|a| b)";
fail "|a|]b)";
fail "|a|[[[)b";

try $RE{balanced}{-begin => '(|['}{-end => ']'};

pass "(]";
pass "(a]";
pass "(a b]";
pass "(a(]b]";
pass "(a( ]b]";
pass "(a(b]]";
pass "(a(b](c](d(e]]]";
pass "(a(}]b]";
pass "(a([[(]]]]b]";
fail "(";
fail "(a";
fail "(a(b]";
fail "(a( b]";
pass "(a(]b]";
fail "(a([[[]b";

