package t::Common;

use strict;
use lib  qw {blib/lib};
use vars qw /$VERSION @ISA @EXPORT @EXPORT_OK $DEBUG/;

use Regexp::Common;
use Exporter ();

@ISA       = qw /Exporter/;
@EXPORT    = qw /run_tests run_new_tests NORMAL_PASS NORMAL_FAIL FAIL $DEBUG/;
@EXPORT_OK = qw /cross criss_cross pass fail
                 d pd dd pdd l ll L LL a aa w ww _x xx X XX
                 gimme sample/;

use constant   NORMAL_PASS =>  0x01;   # Normal test, should pass.
use constant   NORMAL_FAIL =>  0x02;   # Normal test, should fail.
use constant   NORMAL      =>  NORMAL_PASS | NORMAL_FAIL;
use constant   FAIL        =>  0x04;   # Test for failure.

sub run_test;
sub run_old_keep;
sub run_fail;

local $^W = 1;

($VERSION) = q $Revision: 2.113 $ =~ /[\d.]+/;

my $count;

sub stringify;
sub stringify {
    my $arg = shift;

    if    (!defined $arg)        {return ""}
    elsif (!ref $arg)            {$arg =~ s/\\/\\\\/g;
                                  $arg =~ s/\n/\\n/g;
                                  $arg =~ s/\t/\\t/g;
                                  return "$arg"}
    elsif ( ref $arg eq "ARRAY") {
        local $" = ", ";
        return "[@{[map {q{'} . stringify ($_) . q{'}} @$arg]}]";
    }
    else {return ref $arg}
}

sub mess {
    my $str = stringify $_;
    my $com = join " " => map {stringify $_} @_;
    printf qq !%4d - %-40s (%s)\n! => ++ $count, qq !"$str"!, $com;
}

sub pass {print     "ok "; &mess}
sub fail {print "not ok "; &mess}

sub Fail {
    my $mess = shift;
    my %args = @_;

    if ($args {got} && $args {expected}) {
        printf "# Expected: '%s'\n", stringify $args {expected};
        printf "# Got:      '%s'\n", stringify $args {got};
    }

    fail $mess;
}


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

#
# Return a cross product from its arguments. Arguments are array refs.
# Result is a list of array refs.
#
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
     # !defined $$a1 [$i] && !defined $$a2 [$i] ||
     #  defined $$a1 [$i] &&  defined $$a2 [$i] && $$a1 [$i] eq $$a2 [$i]
      (!defined $$a1 [$i] || $$a1 [$i] eq "") &&
      (!defined $$a2 [$i] || $$a2 [$i] eq "") ||
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

##################
#                #
# New style subs #
#                #
##################

#
# Given a regex and a string, test whether the regex fails to match.
# Matching anything other than the entire string is a pass (as it regex
# fails to match the entire string)
#
sub run_fail {
    my %args = @_;

    my $re   = $args {re};
    my $name = $args {name};

    /^$re/ && $_ eq $& ? fail "fail/match; $name"
                       : pass "fail/no match; $name";
}


#
# Same as 'run_fail', except now not a regex, but a subroutine is given.
#
sub run_sub_fail {
    my %args = @_;

    my $sub  = $args {sub};
    my $name = $args {name};
    my @args = $args {sub_args} ? ref $args {sub_args} ? @{$args {sub_args}}
                                                       :   $args {sub_args}
                                : ();

    $_ =~ $sub -> (@args) && $_ eq $& ? fail "sub-fail/match; $name"
                                      : pass "sub-fail/no match; $name";
}

#
# We can test whether it matched, but we can't really test whether
# it matched the entire string. $& relates to the last successful
# match in the current scope, but the match done in $re -> matches()
# is done in a subscope. @-/@+ are equally useless.
#
sub run_OO_pass {
    my %args  = @_;

    my $re    = $args {re};
    my $name  = $args {name};

    my $match = $re -> matches ($_);

    if ($match) {pass "OO-pass/match; $name"}
    else        {fail "OO-pass/no match; $name"}

}


#
# Test whether the subroutine gives the right answer.
#
sub run_sub_pass {
    my %args  = @_;

    my $sub   = $args {sub};
    my $name  = $args {name};
    my @args  = $args {sub_args} ? ref $args {sub_args} ? @{$args {sub_args}}
                                                        :   $args {sub_args}
                                 : ();

    my $match = $_ =~ $sub -> (@args);
    my $good  = $match && $_ eq $&;

    if    ($good)  {pass "sub-pass/match; $name"}
    elsif ($match) {Fail "sub-pass/fail; $name", got => $&, expected => $_}
    else           {fail "sub-pass/no match; $name"}
}


#
# Check whether the substitution (only for OO) works correctly.
#
sub run_OO_substitution_pass {
    my %args  = @_;

    my $re    = $args {re};
    my $name  = $args {name};
    my $token = $args {token} || "---";

    my $sub   = $re -> subs ($_, $token);
    my $good  = $sub eq $token;

    if    ($good)      {pass "OO-subs-pass/match; $name"}
    elsif ($sub ne $_) {Fail "OO-subs-pass/fail; $name",
                              got => $sub, expected => $token}
    else               {fail "OO-subs-pass/no match; $name"}
}


sub run_pass {
    my %args = @_;

    my $re           = $args {re};
    my $name         = $args {name};

    my $match   = /^$re/;   # Not anchored at the end on purpose.
    my $good    = $match && $_ eq $&;
    my $perfect = $good  && !defined $1;  # Should *not* set $1 and friends.

    if    ($perfect) {pass "pass/match; $name"}
    elsif ($good)    {fail "pass/match, sets \$1; $name"}
    elsif ($match)   {Fail "pass/fail; $name", got => $&, expected => $_}
    else             {fail "pass/no match; $name"}
}


sub run_keep {
    my %args = @_;

    my $re         = $args {re};     # Regexp that's being tried.
    my $name       = $args {name};   # Name of the test.
    my $wanted     = $args {wanted}; # Wanted list.

    my @chunks = /^$re->{-keep}/;
    unless (@chunks) {fail "keep/no match; $name"; return}

    array_cmp (\@chunks, $wanted)
         ? pass "keep/match; $name"
         : Fail "keep/fail; $name", got => \@chunks, expected => $wanted;
}


sub run_new_test_set {
    my %args     = @_;

    my $test_set = $args {test_set};
    my $targets  = $args {targets};
    my $name     = $$test_set {name};
    my $regex    = $$test_set {regex} || $$test_set {re}; # Getting tired of
                                                          # getting this wrong.
    my $sub      = $$test_set {sub};
    my $sub_args = $$test_set {sub_args};
    my $keep     = $regex -> {-keep};

    # Run the passes.
    foreach my $target_name (@{$$test_set {pass}}) {
        my $query = $$targets {$target_name} {query};
        foreach my $parts (@{$$targets {$target_name} {list}}) {
            my @args = ref $parts ? @$parts : $parts;
            local $_ = $query     ? $query -> (@args)  :
                       ref $parts ? join "" => @$parts : $parts;

            my @wanted = $$targets {$target_name} {wanted}            ?
                         $$targets {$target_name} {wanted} -> (@args) : $_;
            if (@wanted == 1 && ref $wanted [0] eq "ARRAY") {
                @wanted = @{$wanted [0]};
            }

            run_pass                 name     => $name,
                                     re       => $regex;
            run_OO_pass              name     => $name,
                                     re       => $regex;
            run_OO_substitution_pass name     => $name,
                                     re       => $regex;
            run_sub_pass             name     => $name,
                                     sub_args => $sub_args,
                                     sub      => $sub if $sub;
            run_keep                 name     => $name,
                                     re       => $keep,
                                     wanted   => \@wanted;
        }
    }

    # Run the failures.
    foreach my $target_name (@{$$test_set {fail}}) {
        my $query = $$targets {$target_name} {query};
        foreach my $parts (@{$$targets {$target_name} {list}}) {
            my @args = ref $parts ? @$parts : $parts;
            local $_ = $query     ? $query -> (@args) :
                       ref $parts ? join "" => @$parts : $parts;
            run_fail                 name     => $name,
                                     re       => $regex;
            run_sub_fail             name     => $name,
                                     sub_args => $sub_args,
                                     sub      => $sub if $sub;
        }
    }
}


sub run_new_tests {
    my %args = @_;

    my ($tests, $targets, $version, $version_from,
        $extra_runs, $extra_runs_sub) =
        @args {qw /tests targets version version_from
                   extra_runs extra_runs_sub/};
    my  $runs  = defined $version_from;  # VERSION test.
    my  $no_tests;

    if ($extra_runs) {
        $runs  += $extra_runs;
        $count += $extra_runs;
    }

    if (defined $version && $version > $]) {
        $no_tests = 1;
    }
    else {
        # Count the tests to be run.
        foreach my $test (@$tests) {
            # Test: pass: regex, regex/keep, OO, OO-substitution, sub (if given)
            #       fail: regex, sub (if given).
            my $pass_mult = 4; $pass_mult ++ if $$test {sub};
            my $fail_mult = 1; $fail_mult ++ if $$test {sub};
            foreach my $t (@{$$test {pass}}) {
                my $size = $$targets {$t} {list} ? @{$$targets {$t} {list}} : 0;
                $runs += $pass_mult * $size;
            }
            foreach my $t (@{$$test {fail}}) {
                my $size = $$targets {$t} {list} ? @{$$targets {$t} {list}} : 0;
                $runs += $fail_mult * $size;
            }
        }
    }

    print "1..$runs\n";

    # Check whether a version is defined.
    if (defined $version_from) {
        no strict 'refs';
        print "not " unless defined ${$version_from . '::VERSION'};
        print "ok    ", ++ $count, " - ", $version_from, "::VERSION\n";
    }

    if ($extra_runs_sub) {
        $extra_runs_sub -> (\$count)
    }

    unless ($no_tests) {
        foreach my $test (@$tests) {
            run_new_test_set test_set => $test,
                             targets  => $targets;
        }
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


#
# Pass a number N and a callback C. Return N different results from C.
# Will do at most 100 * N tries.
#
sub gimme {
    my ($count, $call) = @_;
    my %cache;
    foreach (1 .. 100 * $count) {
        $cache {$call -> ()} = 1;
        last if keys %cache >= $count;
    }
    keys %cache;
}

#
# Given a number N, and a list of things, return a sample of N
#
sub sample {
    my $N = shift;
    return @_ if @_ <= $N;

    my @cache = splice @_ => 0, $N;
    my $count = $N;
    map {rand ++ $count < $N and splice @cache, rand @cache, 1, $_} @_;

    @cache;
}



1;

__END__

$Log: Common.pm,v $
Revision 2.113  2005/03/16 00:00:56  abigail
Changes

Revision 2.112  2005/01/01 16:40:21  abigail
- New functions 'sample' and 'gimme'.
- Renamed 'version' argument of 'run_new_tests' to 'version_from'.
  Introduced new argument 'version'.

Revision 2.111  2004/12/28 23:03:26  abigail
More details on failure

Revision 2.110  2004/12/21 23:13:01  abigail
Even more tests when doing a 'run_new_tests'. We're now testing the
following:
  -  Tied hash,  testing for match.
  -  OO form,    testing for a match.
  -  OO form,    testing for substitution.
  -  Subroutine, testing for a match.
  -  Tied hash,  testing -keep.
  -  Tied hash,  testing for failure.
  -  Subroutine, testing for failure.

Revision 2.109  2004/12/14 23:03:17  abigail
Test OO form when running 'new' tests

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
