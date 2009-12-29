# $Revision: 2.102 $
#
# $Log: test_domain.t,v $
# Revision 2.102  2003/07/04 23:09:36  abigail
# Added tests for
#
# Revision 2.101  2003/03/12 22:26:35  abigail
# -nospace switch for domain names
#
# Revision 2.100  2003/01/21 23:19:13  abigail
# The whole world understands RCS/CVS version numbers, that 1.9 is an
# older version than 1.10. Except CPAN. Curse the idiot(s) who think
# that version numbers are floats (in which universe do floats have
# more than one decimal dot?).
# Everything is bumped to version 2.100 because CPAN couldn't deal
# with the fact one file had version 1.10.
#
# Revision 1.1  2002/08/05 20:22:36  abigail
# Tests for {net}{domain}
#

# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

ok (defined $Regexp::Common::net::VERSION &&
            $Regexp::Common::net::VERSION =~ /^\d+[.]\d+$/);

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
