#!/usr/bin/perl

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION/;

use Regexp::Common;
use t::Common;

$^W    = 1;

($VERSION) = q $Revision: 2.103 $ =~ /[\d.]+/;

sub create_parts;

my $gopher        = $RE {URI} {gopher};
my $gopher_notab  = $RE {URI} {gopher} {-notab};

# No point in crosschecking, URI creation is tag independent.
my @tests = (
   [gopher        => $gopher        => {gopher        => NORMAL_PASS | FAIL}],
   [gopher_notab  => $gopher_notab  => {gopher_notab  => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version   =>   "Regexp::Common::URI::gopher",
          tests     =>  \@tests,
          good      =>   $good,
          bad       =>   $bad,
          query     =>  \&gopher,
          wanted    =>  \&wanted,
          filter    =>  \&filter,
;

sub gopher {
    my ($tag, $host, $port, $gtype, $selector, $search, $gopherplus_string) =
       ($_ [0], @{$_ [1]});

    my $gopher  =     "gopher://";
       $gopher .=     $host               if defined $host;
       $gopher .=   ":$port"              if defined $port;
       $gopher .=   "/$gtype"             if defined $gtype;
       $gopher .=     $selector           if defined $selector;
       $gopher .= "%09$search"            if defined $search;
       $gopher .= "%09$gopherplus_string" if defined $gopherplus_string;

    $gopher;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "gopher";
       $wanted [2]  = $$parts [0];   # host.
       $wanted [3]  = $$parts [1];   # port.
       $wanted [4]  = join "" => grep {defined} @$parts [2, 3];
       $wanted [4] .= "%09" . $$parts [4] if defined $$parts [4];
       $wanted [4] .= "%09" . $$parts [5] if defined $$parts [5];
       $wanted [5]  = $$parts [2];   # gtype.

    if ($tag eq 'gopher_notab') {
       $wanted [6]  = $$parts [3];   # selector.
       $wanted [7]  = $$parts [4];   # search.
       $wanted [8]  = $$parts [5];   # gopherplus_string.
    }
    else {
       $wanted [6]  = join "%09" => grep {defined} @$parts [3, 4, 5];
    }

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    local $^W = 0;

    # Hosts.
    # Host/ports are tested with other URIs as well, we're not using
    # all the combinations here.
    $good [0] = [qw /www.abigail.be 127.0.0.1 w--w--w3.ABIGAIL.nl/];
    $bad  [0] = [qw /www.example..com w+w.example.com 127.0.0.0.1/];

    # Ports.
    $good [1] = [undef, 70];
    $bad  [1] = ["", qw /: port/];

    # Gtype
    # No need for both "" and 'undef' in the bad part here - they will
    # result in the same URI.
    $good [2] = [qw /0 + T/];
    $bad  [2] = ["", qw /~/];

    # Selector
    # Don't use an 'undef' here. It will create the same URI as for
    # the empty string, but {-keep} will return "".
    $good [3] = ["", qw {FNURD 0}, q {$_.+!*'(),:@&=%FF}];
    pop @{$good [3]} if $] < 5.006;  # For speed.
    $bad  [3] = [qw {/ []}];

    # Search
    $good [4] = [undef, "", qw {FNORD 0}, q {$_.+!*'(),:@&=%FF}];
    $bad  [4] = [qw {/ []}];

    # Gopherplus string
    $good [5] = [undef, "", qw {fnord 0}, q {$_.+%09!*'(),:@&=%FF}];
    $bad  [5] = [qw {/ []}];

    return (\@good, \@bad);
}


sub filter {
    # Disallow defined gopherplus strings if search is undefined.
    return 0 if defined $_ [0] -> [5] && !defined $_ [0] -> [4];

    # If the gtype is "", but the selector starts with a char that's
    # a valid gtype, we'll see a match where we'd expect a failure.
    return 0 if $_ [0] -> [2] eq "" && defined $_ [0] -> [3]
                                    &&         $_ [0] -> [3] =~ /^[0-9+IgT]/;
    return 1;
}


__END__

 $Log: gopher.t,v $
 Revision 2.103  2008/05/23 21:32:07  abigail
 Changed domain name

 Revision 2.102  2004/06/09 21:35:31  abigail
 Reducing the number of tests for pre-5.6 perls (for speed)

 Revision 2.101  2003/05/23 14:08:11  abigail
 Took words containing comma's out of qw list, to silence warnings.
 (Ticket #2564)

 Revision 2.100  2003/02/21 14:50:22  abigail
 Tests for gopher URIs

