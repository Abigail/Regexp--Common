package t::Common;

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION @ISA @EXPORT @EXPORT_OK $DEBUG/;

use Regexp::Common;
use Exporter ();

@ISA       = qw /Exporter/;
@EXPORT    = qw /run_tests NORMAL_PASS NORMAL_FAIL FAIL $DEBUG/;
@EXPORT_OK = qw /cross/;

use constant   NORMAL_PASS =>  0x01;   # Normal test, should pass.
use constant   NORMAL_FAIL =>  0x02;   # Normal test, should fail.
use constant   NORMAL      =>  NORMAL_PASS | NORMAL_FAIL;
use constant   FAIL        =>  0x04;   # Test for failure.

sub run_test;
sub run_keep;
sub run_fail;

local $^W = 1;

($VERSION) = q $Revision: 2.107 $ =~ /[\d.]+/;

my $count;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

sub import {
    if (@_ > 1) {
        my $version = pop;
        if ($version > $]) {
            print "1..1\n";
            print "ok 1\n";
            exit;
        }
    }
    __PACKAGE__ -> export_to_level (1, @_);
}

sub cross {
    my @r = [];
       @r = map {my $s = $_; map {[@$_ => $s]} @r} @$_ for @_;
       @r
}
sub __ {map {defined () ? $_ : "UNDEF"} @_}

sub count_test_runs {
    my ($tests, $passes, $failures) = @_;

    my $keep     = 0;
    my $normal   = 0;
    my $fail     = 0;

    foreach my $test (@$tests) {
        while (my ($name, $mask) = each %{$test -> [2]}) {
            $normal += @{$passes   -> {$name}} if $mask & NORMAL;
            $keep   += @{$passes   -> {$name}} if $mask & NORMAL_PASS;
            $fail   += @{$failures -> {$name}} if $mask & FAIL;
        }
    }

    1 + $normal + $keep + $fail;
}

# Arguments:
#    tests:   hash ref with the re's, names, and when to (not)match.
#    good:    ref to array with arrays, parts making patterns.
#    bad:     ref to array with arrays, parts not making patterns.
#    query:   code ref, creates query strings.
#    wanted:  code ref, creates list what keep should return.
#
#             Filter arguments are used to filter chunks before trying them.
#             All of them are code refs.
#    filter:          filter everything.
#    filter_passes:   filter passes.
#    filter_failures: filter failures.
#    filter_test:     filter called with testname.
sub run_tests {
    my %args = @_;

    my $tests    = $args {tests};
    my @passes   = cross @{$args {good}};

    # Collect the names of all tags.
    my %tag_names;
       @tag_names {keys %{$_ -> [2]}} = () foreach @$tests;

    my @failures = ();
    foreach my $i (0 .. $#{$args {good}}) {
        push @failures => cross @{$args {good}} [0 .. $i - 1],
                                  $args {bad}   [$i],
                                @{$args {good}} [$i + 1 .. $#{$args {good}}]
    }

    # General filters.
    @passes   = grep {$args {filter_passes} -> ($_)} @passes
                if defined $args {filter_passes};
    @passes   = grep {$args {filter} -> ($_)} @passes
                if defined $args {filter};

    @failures = grep {$args {filter_failures} -> ($_)} @failures
                if defined $args {filter_failures};
    @failures = grep {$args {filter} -> ($_)} @failures
                if defined $args {filter};

    my (%passes, %failures);
    # Specific filters.
    if (defined $args {filter_test}) {
        foreach my $name (keys %tag_names) {
            $passes   {$name} = [grep {$args {filter_test} ->
                                             (pass    => $name, $_)} @passes];
            $failures {$name} = [grep {$args {filter_test} ->
                                             (failure => $name, $_)} @failures];
        }
    }
    else {
        foreach my $name (keys %tag_names) {
            $passes   {$name} = [@passes];
            $failures {$name} = [@failures];
        }
    }

    my $runs = count_test_runs $tests, \%passes, \%failures;
    print "1..$runs\n";

    {
        no strict 'refs';
        print "not " unless defined ${$args {version} . '::VERSION'};
        print "ok ", ++ $count, " - ", $args {version}, "::VERSION\n";
    }

    my @test_names = map {$_ -> [1]} @$tests;
    my @tag_names  = keys %tag_names;

    my $wanted = $args {wanted};
    foreach my $test (@$tests) {
        my ($name, $re, $matches) = @$test;

        while (my ($tag, $match) = each %$matches) {
            if ($match & NORMAL) {
                foreach my $pass (@{$passes {$tag}}) {
                    local $_ = $args {query} -> ($tag => $pass);

                    run_test re    => $re,
                             name  => $name,
                             match => $match & NORMAL_PASS;

                    run_keep re     => $re,
                             name   => $name,
                             tag    => $tag,
                             parts  => $pass,
                             wanted => $wanted if $match & NORMAL_PASS;
                }
            }
            if ($match & FAIL) {
                foreach my $failure (@{$failures {$tag}}) {
                    local $_ = $args {query} -> ($tag => $failure);

                    run_fail re    =>  $re,
                             name  =>  $name;
                }
            }
        }
    }
}



sub run_test {
    my %args = @_;

    my $re           = $args {re};
    my $name         = $args {name};
    my $should_match = $args {match};

    my $match = /^$re/;   # Not anchored at the end on purpose.
    my $good  = $match && $_ eq $&;
    my $line  = $good ? "match" : $match ? "wrong match (got: $&)" : "no match";
       $line .= "; $name";
    if ($should_match) {$good  ? pass $line : fail $line}
    else               {$match ? fail $line : pass $line}
}

sub array_cmp {
    my ($a1, $a2) = @_;
    return 0 unless @$a1 eq @$a2;
    foreach my $i (0 .. $#$a1) {
       !defined $$a1 [$i] && !defined $$a2 [$i] ||
        defined $$a1 [$i] &&  defined $$a2 [$i] && $$a1 [$i] eq $$a2 [$i]
        or return 0;
    }
    return 1;
}

sub run_keep {
    my %args = @_;

    my $re         = $args {re};     # Regexp that's being tried.
    my $name       = $args {name};   # Name of the test.
    my $tag        = $args {tag};    # Tag to pass to wanted sub.
    my $parts      = $args {parts};  # Parts to construct string from.
    my $wanted_sub = $args {wanted}; # Sub to contruct wanted array from.

    my @chunks = /^$re->{-keep}$/;
    unless (@chunks) {fail "no match; $name - keep"; return}

    my $wanted = $wanted_sub -> ($tag => $parts);

    local $" = ", ";
    array_cmp (\@chunks, $wanted)
         ? pass "match; $name - keep"
         : $DEBUG ?  fail "wrong match,\n#      got [@{[__ @chunks]}]\n" .
                                        "# expected [@{[__ @$wanted]}]"
                  :  fail "wrong match [@{[__ @chunks]}]"
}

sub run_fail {
    my %args = @_;

    my $re   = $args {re};
    my $name = $args {name};

    /^$re$/ ? fail "match; $name" : pass "no match; $name";
}


1;

__END__

$Log: Common.pm,v $
Revision 2.107  2003/03/12 22:26:54  abigail
More filter flexibility

Revision 2.106  2003/02/21 14:51:08  abigail
Support for

Revision 2.105  2003/02/11 14:12:52  abigail
*** empty log message ***

Revision 2.104  2003/02/10 21:33:08  abigail
import() function

Revision 2.103  2003/02/09 12:43:00  abigail
Minor changes

Revision 2.102  2003/02/07 22:19:52  abigail
Added general filters

Revision 2.101  2003/02/07 14:56:26  abigail
Made it more generic. Moved the file from t/URI/Common.pm to
t/Common.pm. More flexibility. Cleaner code.

Revision 2.100  2003/02/06 16:32:55  abigail
Factoring out common code
