#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W = 1;


sub create_parts;

my $telnet = $RE {URI} {telnet};

my @tests  = (
   [telnet => $telnet => {telnet => NORMAL_PASS | FAIL}]
);

my ($good, $bad) = create_parts;

run_tests version   =>  "Regexp::Common::URI",
          tests     =>  \@tests,
          good      =>  $good,
          bad       =>  $bad,
          query     =>  \&uri,
          wanted    =>  \&wanted,
          filter    =>  \&filter;


sub uri {
    my ($scheme, $user, $password, $host, $port, $slash) = ($_ [0], @{$_ [1]});

    my $uri  =  "$scheme://";
       $uri .=   $user      if defined $user;
       $uri .= ":$password" if defined $user && defined $password;
       $uri .= '@'          if defined $user;
       $uri .=   $host;
       $uri .= ":$port"     if defined $port;
       $uri .=   $slash     if defined $slash;

    $uri;
}


sub wanted {
    my ($scheme, $parts) = @_;
    my @wanted;
       $wanted [0] = $_;
       $wanted [1] = $scheme;
       if (defined $$parts [0]) {
           $wanted [2] = $$parts [0];
           $wanted [3] = $$parts [0];
           if (defined $$parts [1]) {
               $wanted [2] .= ":$$parts[1]";
               $wanted [4]  =   $$parts [1];
           }
       }
       $wanted [5] = $$parts [2];
       $wanted [6] = $$parts [2];
       if (defined $$parts [3]) {
           $wanted [5] .= ":$$parts[3]";
           $wanted [7]  =   $$parts [3];
       }
       $wanted [8] = undef;
       $wanted [8] = "/" if $$parts [4];

    \@wanted;
}



sub create_parts {
    my (@good, @bad);

    # Users.
    $good [0] = [undef, "", qw /abigail ab?ga?l; abi%67ai%6C/];
    $bad  [0] = [qw /abigail-][/];

    # Passwords.
    $good [1] = [undef, "", qw /secret se??et se%FFret/];
    $bad  [1] = [qw /se{}cret/];

    # Hosts.
    $good [2] = [qw /www.abigail.be www.PERL.com 127.0.0.1 w3.abigail.be/];
    $bad  [2] = [qw /www.example..com w+w.example.com w--.example.com
                     127.0.0.0.1 -w.example.com www.example.1com/];

    # Ports.
    $good [3] = [undef, 123];
    $bad  [3] = ["", qw /-19 : port/];

    # Trailing /.
    $good [4] = [undef, '/'];
    $bad  [4] = ['//', '/foo', '@'];

    (\@good, \@bad);
}


sub filter {
    return !defined $_ [0] -> [0] && defined $_ [0] -> [1] ? 0 : 1
}

__END__
