# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# Domains.

try $RE{net}{domain};

pass 'host.example.com';
pass 'a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z';
pass 'A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z';
pass 'host1.example.com';
pass 'host-1.example.com';
pass 'host';
pass 'a-----------------1.example.com';
pass 'a123456a.example.com';
pass 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789.com';
pass ' ';
fail '123host.example.com';
fail 'host-.example.com';
fail 'host.example.com.';
fail 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789a.com';
fail '  ';
fail 'host. .example.com';
fail 'host .example.com';
fail 'ho st.example.com';

try $RE{net}{domain}{-nospace};

pass 'host.example.com';
pass 'a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z';
pass 'A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z';
pass 'host1.example.com';
pass 'host-1.example.com';
pass 'host';
pass 'a-----------------1.example.com';
pass 'a123456a.example.com';
pass 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789.com';
fail ' ';
fail '123host.example.com';
fail 'host-.example.com';
fail 'host.example.com.';
fail 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789a.com';
fail '  ';
fail 'host. .example.com';
fail 'host .example.com';
fail 'ho st.example.com';
