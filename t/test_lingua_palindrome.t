#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};

use Regexp::Common;

use warnings;


my $count;

my $palindrome = qr /^$RE{lingua}{palindrome}$/;
my $fail       = qr /^$RE{lingua}{palindrome}{-chars => '\d'}$/;
my $keep       = qr /^$RE{lingua}{palindrome}{-keep}$/;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

my (@passes, @entries, @failures);
while (<DATA>) {
    chomp;
    last unless /\S/;
    push @passes => $_;
}
while (<DATA>) {
    chomp;
    last unless /\S/;
    push @entries => $_;
}
while (<DATA>) {
    chomp;
    push @failures => $_;
}
push @failures => " ", "";

my $max = 2 * @failures + 3 * (@passes + 3 * grep {!/^[<>] .*:$/} @entries);

print "1..$max\n";

# print "$fail\n"; exit;

foreach (@passes) {
    /$palindrome/ ? pass "match"       : fail "no match";
    /$keep/       ? $1 eq $_           ? pass "match; keep"
                                       : fail "match ($1); keep"
                                       : fail "no match; keep";
    /$fail/       ? fail "match; fail" : pass "no match; fail";
}

foreach (@failures) {
    /$palindrome/ ? fail "match"       : pass "no match";
    /$keep/       ? fail "match; keep" : pass "no match; keep";
}

foreach my $entry (@entries) {
    if ($entry =~ /^> (.*):/) {
        $palindrome = qr /^$RE{lingua}{palindrome}{-chars => $1}$/;
        $keep       = qr /^$RE{lingua}{palindrome}{-chars => $1}{-keep}$/;
        next;
    }
    if ($entry =~ /^< (.*):/) {
        $fail       = qr /^$RE{lingua}{palindrome}{-chars => $1}$/;
        next;
    }
    local $_ = $entry;
    /$palindrome/ ? fail "match"       : pass "no match";
    /$keep/       ? fail "match; keep" : pass "no match; keep";
    /$fail/       ? fail "match; fail" : pass "no match; fail";
    local $_ = $entry . reverse $entry;
    /$palindrome/ ? pass "match"       : fail "no match";
    /$keep/       ? $1 eq $_           ? pass "match; keep"
                                       : fail "match ($1); keep"
                                       : fail "no match; keep";
    /$fail/       ? fail "match; fail" : pass "no match; fail";
    local $_ = reverse ($entry) . substr $entry, 1;
    /$palindrome/ ? pass "match"       : fail "no match";
    /$keep/       ? $1 eq $_           ? pass "match; keep"
                                       : fail "match ($1); keep"
                                       : fail "no match; keep";
    /$fail/       ? fail "match; fail" : pass "no match; fail";
}



__DATA__
aha
ara
bib
bob
boob
civic
daad
dad
deed
did
dood
dud
ebbe
egge
eke
ene
ere
etste
ewe
eye
gag
gezeg
gig
goog
huh
jij
kaak
kajak
kak
kazak
keek
kek
kik
kok
kook
lal
lel
lepel
level
lil
lol
lul
madam
mam
meeneem
mem
mom
mum
nebben
neen
negen
neggen
nekken
nellen
nemen
nepen
neppen
neren
nessen
neten
netten
neven
non
noon
nun
oho
paap
pap
peep
pep
pip
pop
pup
raar
radar
redder
reder
refer
rekker
remmer
renner
reviver
rotator
rotor
sas
sees
serres
sexes
sis
solos
soos
staats
stoots
sus
temet
tit
toot
tot
tut
wow

SFuHaTEaajrNbFeBpEkPN
YcIUURmSfRLoFjJe
eckIDoGgvoqkCEUsqMBLTWkK
pkgwKxLVxQwhQEtAwUesTSogkaIyJf
xYjBxdGcCfLFzXNtAqKRUOJxGKXeJ
AdXpQMeyEIfyr
SfsapxXkpVfbjsmdXUOou
PktrbesqhkyfluVnPwHRugocwvuq
WODAUSbVppQb
efvqfBZLuqYX
ByPHDLvRms
DhHqdSYYJAKMNiHvXPLbl
eKHZtibxzoXlqgILImYzkCctwhku
ecKrqPQqBtIpOEvGEmLIhVFWBuh
FwrCTwpQnnaJOqPhMPBODgzpBmXnH
lDhQ
KRYddvyTyUEWYEahlWtihNOpDrd
rlEBgFsNFsO
nfjVWYpUdgtiab
qHbABOUypLKobEaQyBjp
NsBpkIzckTmqZycZuQBQxkbfmGaj
ZcNRflemqdsWrCnJeFCydBOnJ
qDFnPI
YiImqMoXUdhnNC
nQGnrxzYicL
WmoOUKJi
NeVHWlCPsIW
PzBTPEoraVOMIbZAIzq
iOJqVDGCOPTyZsbsaPlg
Yl
LDuXxKkGOsmcJWUoKbQUuqLrwh
LGDDKUmrXJhhKWXeoYhVGEpwWVX
ddvJjgOYbVQBlpTB
LAZ
pRrxZfIukSORIjJxz
xYaeftKXISpLasaDZkeWbUDReFJS
YElBQsxQdiddncurlxbKVXov
EZTpMtSLMCx
OAcfWphdMFv
Axref
XMwzzoMfHOSMgGMBhVOV
sCnhq
yLYrxgkXDyfMzNqQxvX
UrhwiKxtOLeWD
blM
efhbKlXqBAtnVzfDbf
qnoSZfhTTvgTruFcGAyiGVX
CFsXnsXF
jjqgFrkIpookzlHpKEDPmAtqMP
MzPZ
> [a-z]:
uehbewnkitmcy
eqeeaphplt
cqmbytmkanwsmkquegylnkuevwxic
gsgyunrvb
tdhzvufhgcqoqzvmoizyevcvn
vmnoqltrdesvnxfyr
ipyroepwytimbdrdmyx
gicxjfzpqctsfoz
wzpksllqjyiyxaquvxbswzgclk
wruucflfyqvitzyzwompwetgd
edskskyxbryntdkzo
jmmigbfxerisfwzwropzxv
dyj
dmjgxwbuisixuqsmhv
jfsdunyulovxszozsuhdoisykwha
beljpcjnbidwiej
ihpjalczkejyreaygautktqoh
zkujheuhkitqsnggnqvo
cpfemiavljvvfsgrmrgvkfx
yjiamfbajifvnlmwhvxnco
zflbfreheohquoehmehklgtijpqekm
oywqmgecvv
thddjpasasumoy
tagxlzsazzwnzzelrp
klvxwmvchyrv
supbdycwkufqqftc
mafws
hlpztnbtbgruqukiroksqscniuqd
mobbxnqfqrhlmfvjbxgbcsxbfcoeh
webaxlcfqsfw
rsxhmxneutngvkgeogmbw
cdryfjtleqzhsxyhi
uuqriyeartlufhmrbutssb
bznyd
hrlkwexwhxrudfdjefikc
nqovsytdjshkupnklycxpxb
zm
zmtdrfdvcedutdjhu
qslxhtkxnrjdxjfyzkedncvbg
thlycnbuhszdtcxqhjyfjtrbc
thlttfpdjfwksigtyhiopgiry
qiwvs
zkcxrrbmqixmuon
paqtpvptus
vbowrpena
xujixuzudptoosuaojdj
miqjwg
yajiqeszalxloaltijpzzhytoij
ueputmp
itczvgkjdmnfcdalyuvtnjxuo
> \w:
rDi5YALoea2yGa0
IO
EzrPIMK04vif
cXSyVEHYbFQ8WzBrAkS0LnsIklfC
dBH0qE5dcg
PolVi_
ywihyxxZXuIeWbqiuMu5a5_hDTVr
DZQ12Cg8g_CTHvZZzHB
5f5NPQwgctuaETEBWi0TaAqLbJS
XZ
nflye5EapNHktnWyUGcOV9vJoHOP
ewoxUSGw_bQr6WiQBJdmVDpNWBM_A
daET_OL48NZ2213dcVT3P
SYav069GQ
17cT4sCDBqbRyaaaP7Ql1
V49uRZmWo2Pq
mVnJOovJarUmvvj6HCWYKcX
3b0q78jBIV4dVkLvqRMDEgmordp3
UiNxe7XNn1suVr3WuXCLn6NNV0voz
GMnUJJbyj_g_nHShSkAQJ2q0V6Ik
Nu5ZWWWmG8bXWH0klxU1iQy
bJm99Sn2IzfaxYHQRYhm74N2U
8rjj9pDVQ2
H9iw8mR4F
2z
YuOudFhIgi3l
DK_vYQ1lmOOo4Hv1JmM
MaEPzGE
FEwFsBhr0rad21pZc5vNBZ35sRi
M1H90gYO
L5Mxi3GuDcrtlOCdmCO7kSmQZAboOA
9Y8CJoGXY2Aj1awnsOehU3pg6_pHHR
3gwnySmFEGhvc7dBcw
FYmqwVHuxi0hepGvNhlEHA5R4d8
LxcoA_CCCG6x6
4axbAGGHEjQ4ChVDAIt5YUqHedgg
hp
qlIj2
SoUXBA0dQc5d7yueCHWL5N1tXWT
nxGFfSG8GIRK
9QvGo36LKz_m8xvniiXuMmKla9RrL
9TjcA
PJwRkL76mkv0g6RZBDF
nzrxgXRI237kKSH6POckTNImHrA
JHmkQ
OW_JRzG1afVb6eC9
cBsJo5C
hp4dUtypQQoToURHf8iEDYPZIuWe
C4Va9
FJ1DVeihL2
< [a-z]:
> \d:
29980996457893057
21313835378243030333668
091
729409601
9719624
370
3789153763679167124200438111
7213
205106612350732070380126
560
9932022468162
294997433
07622546948740
651026122541173516020300
813133424529744256580
260427038421
595082137168646535
7097770631397070695986287
810892652
1220621475
92013886546801507931905918
3767894100
71804184572999032104977644350
3941946950830399143521798239
985536734
4493935115991509368392962898
9655414455050335
172310303035555466194702906201
2402676066185
8834370
021824572200322891809377668051
03495183957
24151107
571087664136929781569896
551
7538
1265
91
821889
30933868030192296343807
7858
4405659824543046178
167460529774400160101784746938
8067316585
242483834532989211693778145
089226
7917129387435406520218042163
299639586008870965630234891
47714904484521065705502616510
0741473983774
