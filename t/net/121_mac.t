# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

try $RE{net}{MAC};

pass '0:0:0:0:0:0';
pass '1:1:1:1:1:1';
pass 'a:b:c:d:e:f';
pass 'a0:b0:c0:d0:e0:f0';
pass 'a0:b0:6:80:e0:f';
fail '0:0:0:0:0';
fail '1:1:1:1:1:1:1';
fail 'a:b:c:d:e:g';
fail 'a0-b0-c0-d0-e0-f0';
fail '255:255:255:255:255:255';

try $RE{net}{MAC}{hex};

pass '0:0:0:0:0:0';
pass '1:1:1:1:1:1';
pass 'a:b:c:d:e:f';
pass 'a0:b0:c0:d0:e0:f0';
pass 'a0:b0:6:80:e0:f';
fail '0:0:0:0:0';
fail '1:1:1:1:1:1:1';
fail 'a:b:c:d:e:g';
fail 'a0-b0-c0-d0-e0-f0';
fail '255:255:255:255:255:255';

try $RE{net}{MAC}{dec};

pass '0:0:0:0:0:0';
pass '1:1:1:1:1:1';
pass '10:11:12:13:14:15';
pass '255:255:255:56:255:255';
pass '255:255:27:255:255:255';
pass '255:255:255:255:255:30';
fail '0:0:0:0:0';
fail '1:1:1:1:1:1:1';
fail 'a:b:c:d:e:f';
fail '0-0-0-0-0--0';
fail '255:255:255:256:255:255:';
fail '255:255:274:255:255:255:';
fail '255:255:255:255:255:300:';

try $RE{net}{MAC}{oct};

pass '0:0:0:0:0:0';
pass '1:1:1:1:1:1';
pass '10:11:12:13:14:15';
pass '377:377:377:56:377:377';
pass '377:377:27:377:377:377';
pass '377:377:377:377:377:30';
fail '0:0:0:0:0';
fail '1:1:1:1:1:1:1';
fail '1:1:1:1:8:1';
fail 'a:b:c:d:e:f';
fail '0-0-0-0-0-0';
fail '377:377:377:400:377:377';
fail '377:377:379:377:377:377';
fail '377:377:377:377:377:380';

try $RE{net}{MAC}{bin};

pass '0:0:0:0:0:0';
pass '1:1:1:1:1:1';
pass '10:11:100:101:110:111';
pass '11111111:11111111:11111111:1111111:11111111:11111111';
pass '11111111:11111111:11111111:11111110:11111111:11111111';
pass '11111111:11111111:11111111:11111111:11111111:11111111';
fail '0:0:0:0:0';
fail '1:1:1:1:1:1:1';
fail '1:1:1:1:111111111:1';
fail 'a:b:c:d:e:f';
fail '0-0-0-0-0-0';

try $RE{net}{MAC}{hex}{-sep => ""};

pass '000000';
pass '111111';
pass 'abcdef';
pass 'a0b0c0d0e0f';
pass 'a0b0680e0f';
fail 'cdefgh';
fail 'a0-b0-c0-d0-e0-f0';
fail '255255255255255255';

try $RE{net}{MAC}{hex}{-sep => " "};

pass '0 0 0 0 0 0';
pass '1 1 1 1 1 1';
pass 'a b c d e f';
pass 'a0 b0 c0 d0 e0 f0';
pass 'a0 b0 6 80 e0 f';
fail '0 0 0 0 0';
fail '1 1 1 1 1 1 1';
fail 'c d e f g h';
fail 'a0-b0-c0-d0-e0-f0';
fail '255 255 255 255 255 255';


ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC} -> subs ('8:9:a:b:c:d');
ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC}{hex} -> subs ('8:9:a:b:c:d');
ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC}{hex}{-sep => '-'} -> subs ('8-9-a-b-c-d');
ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC}{hex}{-sep => ''}  -> subs ('89abcd');
ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC}{dec} -> subs ('8:9:10:11:12:13');
ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC}{oct} -> subs ('10:11:12:13:14:15');
ok '08:09:0a:0b:0c:0d' eq
       $RE{net}{MAC}{bin} -> subs ('1000:1001:1010:1011:1100:1101');
ok '8:9:a:b:c:g' eq
       $RE{net}{MAC}{hex} -> subs ('8:9:a:b:c:g');
