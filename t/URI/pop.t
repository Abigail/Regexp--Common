#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W    = 1;
$DEBUG = 1;


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
    $bad  [0] = ["", qw /abigail%GG [abigail]/];

    # Auth_type
    $good [1] = [undef, qw /* password &~=~& +APOP +password +/];
    $bad  [1] = ["", qw /"password" camel-][/];

    # Hosts.
    $good [2] = [qw /pop3.abigail.be pop3.PERL.com 127.0.0.1/];
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
