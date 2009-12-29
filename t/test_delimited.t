# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

ok (defined $Regexp::Common::delimited::VERSION &&
            $Regexp::Common::delimited::VERSION =~ /^\d+[.]\d+$/);

if ($] >= 5.006) {
    # This gives a 'panic: POPSTACK' in 5.005_*
    eval {"" =~ $RE {delimited}};
    ok $@ =~ /Must specify delimiter in \$RE{delimited}/;
}

try $RE {delimited} {-delim => ' '};
pass q { a-few-words };
pass q { a\ few\ words };
fail q { a few words };

try $RE{delimited}{qq{-delim$;"}};

pass q{"a few words "};
pass q{"a few \"words\" "};
pass q{"a few 'words' "};
fail q{"a few "words" "};
fail q{'a few words '};
fail q{'a few \"words\" '};
fail q{'a few "words" '};
fail q{a "few" words "};


try $RE{delimited}{qq{-delim$;"}}{qq{-esc$;"}};

pass q{"a few words "};
fail q{"a few \"words\" "};
pass q{"a few ""words"" "};
pass q{"a few 'words' "};
fail q{"a few "words" "};
fail q{a "few" words "};


try $RE{delimited}{qq{-delim$;'}};

fail q{"a few words "};
fail q{"a few \"words\" "};
fail q{"a few 'words' "};
fail q{"a few "words" "};
pass q{'a few words '};
pass q{'a few \"words\" '};
pass q{'a few "words" '};
fail q{a "few" words "};


try $RE{quoted};

pass q{"a few words "};
pass q{"a few \"words\" "};
pass q{"a few 'words' "};
fail q{"a few "words" "};
pass q{'a few words '};
pass q{'a few \"words\" '};
pass q{'a few "words" '};
fail q{a "few" words "};


try $RE{quoted}{qq{-esc$;_!}};

pass q{"a few words "};
fail q{"a few \"words\" "};
pass q{"a few _"words_" "};
pass q{"a few 'words' "};
fail q{"a few "words" "};
pass q{'a few words '};
fail q{'a few \'words\' '};
pass q{'a few !'words!' '};
pass q{'a few "words" '};
fail q{a "few" words "};

try $RE{quoted}{qq{-esc$;}};

pass q{"a few words "};
fail q{"a few \"words\" "};
fail q{"a few _"words_" "};
pass q{"a few 'words' "};
fail q{"a few "words" "};
pass q{'a few words '};
fail q{'a few \'words\' '};
fail q{'a few !'words!' '};
pass q{'a few "words" '};
fail q{a "few" words "};
