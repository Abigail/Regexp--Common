#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W    = 1;


sub create_parts;

my $wais          = $RE {URI} {WAIS};

# No point in crosschecking, URI creation is tag independent.
my @tests = (
   [wais          => $wais          => {wais          => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version        =>   "Regexp::Common::URI::wais",
          tests          =>  \@tests,
          good           =>   $good,
          bad            =>   $bad,
          query          =>  \&wais,
          wanted         =>  \&wanted,
          filter         =>  \&filter,
          filter_passes  =>  \&filter_passes,
;

sub wais {
    my ($tag, $host, $port, $database, $search, $wtype, $wpath) =
       ($_ [0], @{$_ [1]});

    my $wais  =     "wais://";
       $wais .=     $host        if defined $host;
       $wais .=   ":$port"       if defined $port;
       $wais .=   "/$database"   if defined $database;
       $wais .=   "?$search"     if defined $search;
       $wais .=   "/$wtype"      if defined $wtype;
       $wais .=   "/$wpath"      if defined $wpath;

    $wais;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "wais";
       $wanted [2]  = $$parts [0];   # host.
       $wanted [3]  = $$parts [1];   # port.
       $wanted [4]  = $$parts [2];   # database.
       $wanted [4] .= "?" . $$parts [3] if defined $$parts [3];
       $wanted [4] .= "/" . $$parts [4] if defined $$parts [4];
       $wanted [4] .= "/" . $$parts [5] if defined $$parts [5];
       $wanted [5]  = $$parts [2];   # database.
       $wanted [6]  = undef;
       $wanted [6] .= "?" . $$parts [3] if defined $$parts [3];
       $wanted [6] .= "/" . $$parts [4] if defined $$parts [4];
       $wanted [6] .= "/" . $$parts [5] if defined $$parts [5];
       $wanted [7]  = $$parts [3];   # search.
       $wanted [8]  = $$parts [4];   # wtype.
       $wanted [9]  = $$parts [5];   # wpath.

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Hosts.
    # Host/ports are tested with other URIs as well, we're not using
    # all the combinations here.
    $good [0] = [qw /www.abigail.be 127.0.0.1 w--w--w3.ABIGAIL.nl/];
    $bad  [0] = [qw /www.example..com w+w.example.com 127.0.0.0.1/];

    # Ports.
    $good [1] = [undef, 210];
    $bad  [1] = ["", qw /: port/];

    # Database
    $good [2] = ["", qw /database 0/, '%00%FF-!*,'];
    $bad  [2] = [undef, qw /~/];

    # Search
    $good [3] = [undef, "", qw /database 0/, '%00%FF-!*,'];
    $bad  [3] = [qw {~ []}];

    # Wtype
    $good [4] = [undef, "", qw /wtype 0/, '%00%FF-!*,'];
    $bad  [4] = [qw {~ []}];

    # Wpath
    $good [5] = [undef, "", qw /wpath 0/, '%00%FF-!*,'];
    $bad  [5] = [qw {~ []}];

    return (\@good, \@bad);
}

sub filter_passes {
    # Good URIs have either both a wtype and a wpath, or none at all.
    return 0 if defined $_ [0] -> [4] xor defined $_ [0] -> [5];
    return 1;
}

sub filter {
    # At most one of 'search' and 'wtype/wpath' should be defined.
    return 0 if defined $_ [0] -> [3] && (defined $_ [0] -> [4] ||
                                          defined $_ [0] -> [5]);

    return 0 if !defined $_ [0] -> [2] && grep {defined} @{$_ [0]} [3 .. 5];

    return 1;
}


__END__
