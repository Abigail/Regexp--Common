package t::Common;

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION @ISA @EXPORT @EXPORT_OK $DEBUG/;

use Regexp::Common;
use Exporter ();

@ISA       = qw /Exporter/;
@EXPORT    = qw /run_tests run_new_tests NORMAL_PASS NORMAL_FAIL FAIL $DEBUG/;
@EXPORT_OK = qw /cross criss_cross pass fail
                 d pd dd pdd l ll L LL a aa w ww _x xx X XX/;

use constant   NORMAL_PASS =>  0x01;   # Normal test, should pass.
use constant   NORMAL_FAIL =>  0x02;   # Normal test, should fail.
use constant   NORMAL      =>  NORMAL_PASS | NORMAL_FAIL;
use constant   FAIL        =>  0x04;   # Test for failure.

sub run_test;
sub run_old_keep;
sub run_fail;

local $^W = 1;

($VERSION) = q $Revision: 2.108 $ =~ /[\d.]+/;

my $count;

sub mess {print ++ $count, " - $_ (@_)\n"}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

sub import {
    if (@_ > 1 && $_ [-1] =~ /^\d+\.\d+$/) {
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
sub criss_cross {
    my ($f, $s) = @_;
    my @r;

    push @r => cross @$f [0 .. $_ - 1], $$s [$_], @$f [$_ + 1 .. $#$f]
               for 0 .. $#$f;

    @r;
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

    # Collect the names of all tags.
    my %tag_names;
       @tag_names {keys %{$_ -> [2]}} = () foreach @$tests;

    my (@passes, @failures);

    if ($args {good}) {
        @passes   = cross @{$args {good}};

        @failures = ();
        foreach my $i (0 .. $#{$args {good}}) {
            push @failures => cross @{$args {good}} [0 .. $i - 1],
                                      $args {bad}   [$i],
                                    @{$args {good}} [$i + 1 .. $#{$args {good}}]
        }
    }
    elsif ($args {good_list}) {
        @passes   = @{$args {good_list}};
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

                    run_test     re    => $re,
                                 name  => $name,
                                 match => $match & NORMAL_PASS;

                    run_old_keep re     => $re,
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

sub run_old_keep {
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


sub run_pass {
    my %args = @_;

    my $re           = $args {re};
    my $name         = $args {name};

    my $match = /^$re/;   # Not anchored at the end on purpose.
    my $good  = $match && $_ eq $&;
    my $line  = $good  ? "match; $name"                 :
                $match ? "wrong match (got: $&); $name" :
                         "no match; $name";
    $good ? pass $line
          : fail $line
}


sub run_keep {
    my %args = @_;

    my $re         = $args {re};     # Regexp that's being tried.
    my $name       = $args {name};   # Name of the test.
    my $wanted     = $args {wanted}; # Wanted list.

    my @chunks = /^$re->{-keep}$/;
    unless (@chunks) {fail "no match; $name - keep"; return}

    local $" = ", ";
    array_cmp (\@chunks, $wanted)
         ? pass "match; $name - keep"
         : $DEBUG ?  fail "wrong match,\n#      got [@{[__ @chunks]}]\n" .
                                        "# expected [@{[__ @$wanted]}]"
                  :  fail "wrong match [@{[__ @chunks]}]"
}


sub run_new_test_set {
    my %args     = @_;

    my $test_set = $args {test_set};
    my $targets  = $args {targets};
    my $name     = $$test_set {name};
    my $regex    = $$test_set {regex};
    my $keep     = $regex -> {-keep};

    # Run the passes.
    foreach my $target_name (@{$$test_set {pass}}) {
        my $query = $$targets {$target_name} {query};
        foreach my $parts (@{$$targets {$target_name} {list}}) {
            local $_ = $query -> ($parts);
            run_pass name   => $name,
                     re     => $regex;
            run_keep name   => $name,
                     re     => $keep,
                     wanted => $$targets {$target_name} {wanted} -> ($parts);
        }
    }

    # Run the failures.
    foreach my $target_name (@{$$test_set {fail}}) {
        my $query = $$targets {$target_name} {query};
        foreach my $parts (@{$$targets {$target_name} {list}}) {
            local $_ = $query -> ($parts);
            run_fail name => $name,
                     re   => $regex,
        }
    }
}


sub run_new_tests {
    my %args = @_;

    my ($tests, $targets) = @args {qw /tests targets/};

    # Count the tests to be run.
    my $runs = 1;
    foreach my $test (@$tests) {
        $runs += 2 * @{$$targets {$_} {list}} for @{$$test {pass}};
        $runs += 1 * @{$$targets {$_} {list}} for @{$$test {fail}};
    }

    print "1..$runs\n";

    # Check whether a version is defined.
    {
        no strict 'refs';
        print "not " unless defined ${$args {version} . '::VERSION'};
        print "ok ", ++ $count, " - ", $args {version}, "::VERSION\n";
    }

    foreach my $test (@$tests) {
        run_new_test_set test_set => $test,
                         targets  => $targets;
    }
}

#
# Function to produce random strings.
#

# Digit.
sub  d {int rand 10}
# Positive digit.
sub pd {1 + int rand 9}
# String of digits.
sub dd {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {d} 1 .. $min + int rand ($max - $min)}
# String of digits, not all 0.
sub pdd {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
    TRY: my $dd = join "" => map {d} 1 .. $min + int rand ($max - $min);
         goto TRY unless $dd =~ /[^0]/;
         $dd}
# Lowercase letter.
sub  l {chr (ord ('a') + int rand 26)}
# String of lowercase letters.
sub ll {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {l} 1 .. $min + int rand ($max - $min)}
# Uppercase letter.
sub  L {chr (ord ('a') + int rand 26)}
# String of uppercase letters.
sub LL {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {L} 1 .. $min + int rand ($max - $min)}
# Alpha.
sub  a {50 < rand (100) ? l : L}
# String of alphas.
sub aa {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {a} 1 .. $min + int rand ($max - $min)}
# Alphanum.
sub  w {52 < rand (62) ? d : a}
# String of alphanums.
sub ww {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {w} 1 .. $min + int rand ($max - $min)}
# Lowercase hex digit.
sub _x {(0 .. 9, 'a' .. 'f') [int rand 16]}
# String of lowercase hex digits.
sub xx {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {_x} 1 .. $min + int rand ($max - $min)}
# Uppercase hex digit.
sub  X {(0 .. 9, 'A' .. 'F') [int rand 16]}
# String of uppercase hex digits.
sub XX {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {X} 1 .. $min + int rand ($max - $min)}


1;

__END__

$Log: Common.pm,v $
Revision 2.108  2004/06/09 21:39:49  abigail
New way of doing tests

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
