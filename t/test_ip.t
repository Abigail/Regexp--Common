# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
# sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}
sub try {
    $P = qr /^$_[0]/
}
sub pass {
    ok ($_ [0] =~ $P && $& eq $_ [0])
}
sub fail {
    ok ($_ [0] !~ $P || $& ne $_ [0])
}

# LOAD

use Regexp::Common;
ok;

# DOTTED DECIMAL

try $RE{net}{IPv4};

pass '0.0.0.0';
pass '1.1.1.1';
pass '255.255.255.255';
pass '255.0.128.23';
fail '256.0.128.23';
fail '255.0.1287.23';
fail '255.a.127.23';
fail '255 0 127 23';
fail '255,0,127,23';
fail '255012723';


try $RE{net}{IPv4}{dec};

pass '0.0.0.0';
pass '1.1.1.1';
pass '255.255.255.255';
pass '255.0.128.23';
fail '256.0.128.23';
fail '255.0.1287.23';
fail '255.a.127.23';
fail '255 0 127 23';
fail '255,0,127,23';
fail '255012723';


# DOTTED HEXADECIMAL #

try $RE{net}{IPv4}{hex};

pass '0.0.0.0';
pass '1.1.1.1';
pass '55.55.25.5';
pass '7A.B4.2C.D';
pass 'FF.FF.FF.FF';
fail 'FF.FF.FF.1FF';
fail '255.0.1287.23';
fail '255.a.127.23';
fail '255 0 127 23';
fail '255,0,127,23';
fail '255012723';

try $RE{net}{IPv4}{hex}{-sep=>""};

fail '0.0.0.0';
fail '1.1.1.1';
pass '55552505';
pass '7AB42CD';
pass 'FFFFFFFF';
fail 'FFFFFF1FF';
fail '55 55 25 05';
fail '7A B4 2C D';
fail 'FF FF FF FF';
fail 'FF FF FF 1FF';

try $RE{net}{IPv4}{hex}{-sep=>" "};

fail '0.0.0.0';
fail '1.1.1.1';
fail '55552505';
fail '7AB42CD';
fail 'FFFFFFFF';
fail 'FFFFFF1FF';
pass '55 55 25 05';
pass '7A B4 2C D';
pass 'FF FF FF FF';
fail 'FF FF FF 1FF';


# DOTTED OCTAL #

try $RE{net}{IPv4}{oct};

pass '0.0.0.0';
pass '1.1.1.1';
pass '55.55.25.5';
fail '7A.B4.2C.D';
pass '377.377.377.377';
fail '400.400.400.400';
fail '377.377.377.1377';
fail '255.a.127.23';
fail '255 0 127 23';
fail '255,0,127,23';
fail '255012723';


# DOTTED BINARY #

try $RE{net}{IPv4}{bin};

pass '0.0.0.0';
pass '1.1.1.1';
pass '101010.101011.1.10000000';
fail '12.01.01.01';
fail '101010101.101011.1.10000000';
fail '10101010-101011-1-10000000';
fail '10101010101011110000000';
