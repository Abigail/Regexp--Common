#!/usr/bin/perl

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use t::Common;

$^W    = 1;
$DEBUG = 1;


sub create_parts;

my $prospero = $RE {URI} {prospero};

# No point in crosschecking, URI creation is tag independent.
my @tests = (
   [prospero      => $prospero      => {prospero      => NORMAL_PASS | FAIL}],
);

my ($good, $bad) = create_parts;

run_tests version        =>   "Regexp::Common::URI::prospero",
          tests          =>  \@tests,
          good           =>   $good,
          bad            =>   $bad,
          query          =>  \&prospero,
          wanted         =>  \&wanted,
          filter         =>  \&filter,
;

sub prospero {
    my ($tag, $host, $port, $ppath, $fieldnames, $fieldvalues) =
       ($_ [0], @{$_ [1]});

    my $prospero  =     "prospero://";
       $prospero .=     $host        if defined $host;
       $prospero .=   ":$port"       if defined $port;
       $prospero .=   "/$ppath"      if defined $ppath;
    if (defined $fieldnames) {
        foreach my $i (0 .. $#$fieldnames) {
           $prospero .= ";$fieldnames->[$i]";
           $prospero .= "=$fieldvalues->[$i]" if defined $fieldvalues -> [$i];
       }
    }

    $prospero;
}

sub wanted {
    my ($tag, $parts) = @_;

    my @wanted;
       $wanted [0]  = $_;
       $wanted [1]  = "prospero";
       $wanted [2]  = $$parts [0];   # host.
       $wanted [3]  = $$parts [1];   # port.
       $wanted [4]  = $$parts [2];   # ppart.
       $wanted [5]  = "";
    if (defined $$parts [3]) {
        foreach my $i (0 .. $#{$$parts [3]}) {
            $wanted [5] .= ";${$$parts [3]}[$i]=${$$parts [4]}[$i]";
        }
    }

    \@wanted;
}


sub create_parts {
    my (@good, @bad);

    # Hosts.
    $good [0] = [qw /www.abigail.freedom.nl www.PERL.com a.b.c.d.e.f.g.h.i.j.k.x
                     127.0.0.1 w--w--w.abigail.freedom.nl w3.abigail.freedom.nl/];
    $bad  [0] = [qw /www.example..com w+w.example.com w--.example.com
                     127.0.0.0.1 -w.example.com www.example.1com/];

    # Ports.
    $good [1] = [undef, 1525];
    $bad  [1] = ["", qw /: port/];

    # Ppart
    $good [2] = ["", qw {part foo/bar fnord:&=?%FF}];
    $bad  [2] = [undef, qw {~}, ' '];

    # Fieldname
    $good [3] = [undef, [qw /name/], [qw /name1 name2/], [""], ["", ""], 
                        ["", qw /name/], [qw /fnord:&?%FF/]];
    $bad  [3] = [[qw /name==/], ['~']];

    # Fieldvalue
    $good [4] = [undef, [qw /value/], [qw /value1 value2/], [""], ["", ""], 
                        ["", qw /value/], [qw /fnord:&?%FF/]];
    $bad  [4] = [[qw /value==/], ['~'], [undef], [undef, undef]];

    return (\@good, \@bad);
}


sub filter {
    return 1 if !defined ${$_ [0]} [3] && !defined ${$_ [0]} [4];
    return 0 if  defined ${$_ [0]} [3] && !defined ${$_ [0]} [4] ||
                !defined ${$_ [0]} [3] &&  defined ${$_ [0]} [4];
    return 0 if @{${$_ [0]} [3]} != @{${$_ [0]} [4]};

    return 1;
}


__END__
