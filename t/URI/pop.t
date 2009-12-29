#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;
use t::Common;

$^W    = 1;
$DEBUG = 1;

($VERSION) = q $Revision: 2.102 $ =~ /[\d.]+/;

sub create_parts;

my $scheme = 'pop';
my $pop = $RE {URI} {uc $scheme};

# No point in crosschecking, URI creation is tag independent.
my @tests = (
   [pop      => $pop      => {pop      => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version        =>   "Regexp::Common::URI::$scheme",
          tests          =>  \@tests,
          good           =>   $good,
          bad            =>   $bad,
          query          =>  \&query,
          wanted         =>  \&wanted,
          filter         =>  \&filter,
;

sub query {
    my ($tag, $user, $auth_type, $host, $port) = ($_ [0], @{$_ [1]});

    my $url  =  "$scheme://";
    if (defined $user) {
        $url .= $user;
        $url .= ";AUTH=$auth_type" if defined $auth_type;
        $url .= '@';
    }
    $url .=   $host  if defined $host;
    $url .= ":$port" if defined $port;

    $url;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "$scheme";
       $wanted [2]  = $$parts [0];   # user.
       $wanted [3]  = $$parts [1];   # auth.
       $wanted [4]  = $$parts [2];   # host.
       $wanted [5]  = $$parts [3];   # port.

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Users
    $good [0] = [undef, qw /abigail/];
    push  @{$good [0]} => qw /abigail%20&%20a%20camel=/ unless $] < 5.006;
    $bad  [0] = ["", qw /abigail%GG [abigail]/];

    # Auth_type
    $good [1] = [undef, qw /* password &~=~& +APOP +password +/];
    $bad  [1] = ["", qw /"password" camel-][/];

    # Hosts.
    $good [2] = [qw /pop3.abigail.be pop3.PERL.com 127.0.0.1/];
    push @{$good [2]} => qw /a.b.c.d.e.f.g.h.i.j.k.x p--p--p.abigail.be/
                         unless $] < 5.006;  # Speed.
    $bad  [2] = [qw /www.example..com w+w.example.com 127.0.0.0.1
                     w--.example.com -w.example.com www.example.1com/];

    # Ports.
    $good [3] = [undef, 110];
    $bad  [3] = ["", qw /: port/];

    return (\@good, \@bad);
}


sub filter {
    return 0 if defined ${$_ [0]} [1] && !defined ${$_ [0]} [0];

    return 1;
}


__END__

 $Log: pop.t,v $
 Revision 2.102  2008/05/23 21:32:07  abigail
 Changed domain name

 Revision 2.101  2004/06/09 21:35:31  abigail
 Reducing the number of tests for pre-5.6 perls (for speed)

 Revision 2.100  2003/03/25 13:02:07  abigail
 Tests for POP URIs.

