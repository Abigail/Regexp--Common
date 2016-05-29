# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# Domains.

my @data = (
   ['host.example.com'                                    => 'PPPP'],
   ['a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z' => 'PPPP'],
   ['A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z' => 'PPPP'],
   ['host1.example.com'                                   => 'PPPP'],
   ['host-1.example.com'                                  => 'PPPP'],
   ['host'                                                => 'PPPP'],
   ['a-----------------1.example.com'                     => 'PPPP'],
   ['a123456a.example.com'                                => 'PPPP'],
   #
   # 63 char limit
   #
   ['abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789.com'
                                                          => 'PPPP'],
   ['abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789a.com'
                                                          => 'FFFF'],
   #
   # By default, we can match a single space, but not two
   #
   [' ',                                                  => 'PFPF'],
   ['  '                                                  => 'FFFF'],
   #
   # Parts may only start with a number if -rfc1101 is given
   #
   ['123host.example.com'                                 => 'FFPP'],
   ['host.12example.com'                                  => 'FFPP'],
   #
   # But it may not look it starts with an IP address
   #
   ['127.0.0.1'                                           => 'FFFF'],
   ['127.0.0.1.com'                                       => 'FFFF'],
   ['127.0.0.1333.com'                                    => 'FFPP'],
   #
   # Parts may not end with a dash
   #
   ['host-.example.com'                                   => 'FFFF'],
   #
   # May not end with a dot
   #
   ['host.example.com.'                                   => 'FFFF'],
   #
   # Mind your dots and spaces
   #
   ['host. .example.com'                                  => 'FFFF'],
   ['host..example.com'                                   => 'FFFF'],
   ['host .example.com'                                   => 'FFFF'],
   ['ho st.example.com'                                   => 'FFFF'],
);

my @pats = (
    ['$RE {net} {domain}'             => $RE {net} {domain}],
    ['$RE {net} {domain} {-nospace}'  => $RE {net} {domain} {-nospace}],
    ['$RE {net} {domain} {-rfc1101}'  => $RE {net} {domain} {-rfc1101}],
    ['$RE {net} {domain} {-nospace} {-rfc1101}'
                             => $RE {net} {domain} {-nospace} {-rfc1101}],
);


foreach (my $i = 0; $i < @pats; $i ++) {
    my ($name, $pat) = @{$pats [$i]};
    try $pat;
    $M .= "# Trying $name\n";
    foreach my $entry (@data) {
        my ($domain, $results) = @$entry;
        my $entry = substr $results, $i, 1;
        $entry eq 'P' ? pass $domain : fail $domain;
    }
}


