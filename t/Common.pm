package t::Common;

use strict;
use lib  qw {blib/lib}, ".";

use Regexp::Common;
use Exporter ();

use warnings;

our $DEBUG;
our @ISA       = qw /Exporter/;
our @EXPORT    = qw /run_tests run_new_tests NORMAL_PASS NORMAL_FAIL
                                             FAIL $DEBUG/;
our @EXPORT_OK = qw /cross criss_cross pass fail
                     d pd dd pdd l ll L LL a aa w ww _x xx X XX h hh
                     gimme sample/;

my @STATES = qw /pass fail/;

our $SKIP;

use constant   NORMAL_PASS =>  0x01;   # Normal test, should pass.
use constant   NORMAL_FAIL =>  0x02;   # Normal test, should fail.
use constant   NORMAL      =>  NORMAL_PASS | NORMAL_FAIL;
use constant   FAIL        =>  0x04;   # Test for failure.

sub run_test;
sub run_old_keep;
sub run_fail;
sub count_me;
sub is_skipped;


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
    $count ++;
    if ($SKIP) {printf qq !%4d # SKIP: %s\n! => $count, $SKIP;}
    else       {printf qq !%4d - %-40s (%s)\n! => $count, qq !"$str"!, $com;}
}

sub pass {print          "ok ";             &mess}
sub fail {print +$SKIP ? "ok " : "not ok "; &mess}

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

    print "ok ", ++ $count, "\n";

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
# Messages printed at end are of the form:
#   [XX/Y/ZZ], with XX denoting the type of match, Y the expected result,
#              and ZZ the result.
#
#   XX: - RE:  Regular expression
#       - SB:  Subroutine call
#       - OM:  OO -> match
#       - OS:  OO -> subs
#       - KP:  Regular expression with -keep
#
#    Y: -  P:  Expected to pass
#       -  F:  Expected to fail
#
#   ZZ: - MT:  Pattern matched correctly
#       - NM:  Pattern did not match
#       - WM:  Pattern matched, but incorrectly.


#
# Given a regex and a string, test whether the regex fails to match.
# Matching anything other than the entire string is a pass (as it regex
# fails to match the entire string)
#
sub run_fail {
    my %args = @_;

    my $re   = $args {re};
    my $name = $args {name};

    /^$re/ && $_ eq $& ? fail "[RE/F/MT] $name"
                       : pass "[RE/F/NM] $name";
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

    $_ =~ $sub -> (@args) && $_ eq $& ? fail "[SB/F/MT] $name"
                                      : pass "[SB/F/NM] $name";
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

    if ($match) {pass "[OM/P/MT] $name"}
    else        {fail "[OM/P/NM] $name"}

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

    if    ($good)  {pass "[SB/P/MT] $name"}
    elsif ($match) {Fail "[SB/P/WM] $name", got => $&, expected => $_}
    else           {fail "[SB/P/NM] $name"}
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

    if    ($good)      {pass "[OS/P/MT] $name"}
    elsif ($sub ne $_) {Fail "[OS/P/NM] $name", got => $sub, expected => $token}
    else               {fail "[OS/P/WM] $name"}
}


sub run_pass {
    my %args = @_;

    my $re           = $args {re};
    my $name         = $args {name};

    my $match   = /^$re/;   # Not anchored at the end on purpose.
    my $good    = $match && $_ eq $&;
    my $perfect = $good  && !defined $1;  # Should *not* set $1 and friends.

    if    ($perfect) {pass "[RE/P/MT] $name"}
    elsif ($good)    {fail "[RE/P/MT], sets \$1; $name"}
    elsif ($match)   {Fail "[RE/P/WM] $name", got => $&, expected => $_}
    else             {fail "[RE/P/NM] $name"}
}


sub run_keep {
    my %args = @_;

    my $re         = $args {re};     # Regexp that's being tried.
    my $name       = $args {name};   # Name of the test.
    my $wanted     = $args {wanted}; # Wanted list.

    my @chunks = /^$re->{-keep}/;
    unless (@chunks) {fail "[KP/P/NM] $name"; return}

    array_cmp (\@chunks, $wanted)
         ? pass "[KP/P/MT] $name"
         : Fail "[KP/P/WM] $name", got => \@chunks, expected => $wanted;
}

sub get_args {
    my $key = shift;
    foreach my $ref (@_) {
        next unless exists $$ref {$key};
        return ref $$ref {$key} eq 'ARRAY' ? @{$$ref {$key}} : $$ref {$key}
    }
    return;
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

    my $pass     = $$test_set {pass};
    my $fail     = $$test_set {fail};

    my $skip_sub = $$test_set {skip_sub};

    #
    # Run the passes.
    #
    foreach my $target_info (@$pass) {
        my $target_name = $$target_info {name};
        my $query  = $$targets {$target_name} {query};
        next unless $$targets {$target_name} {list} &&
                  @{$$targets {$target_name} {list}};
        my $un_seen = @{$$targets {$target_name} {list}};
        my $samples = count_me $$targets {$target_name} {list},
                               $$target_info {limit},
                               $$test_set {limit};
        foreach my $parts (@{$$targets {$target_name} {list}}) {
            next unless $samples > rand $un_seen --;
            $samples --;

            #
            # Calculate the sections we're going to skip.
            #
            my %skips;
            foreach my $skip (qw /RE SB OO OM OS KP/) {
                $skips {$skip} = is_skipped $skip => $target_info, $test_set;
            }
            $skips {OM} ||= $skips {OO};
            $skips {OS} ||= $skips {OO};

            #
            # Find the thing we need to match against.
            # Note that we're going to match against $_.
            #
            my @args    =  ref $parts ? @$parts : $parts;
            my @qargs   =  get_args query_args => $target_info, $test_set;
            local $_    =  $query     ? $query -> (@qargs, @args)  :
                           ref $parts ? join "" => @$parts : $parts;

            #
            # See whether we want to skip the test
            #
            local $SKIP = $skip_sub && $skip_sub -> (pass => $_);

            #
            # Find out the things {-keep} should return.
            # The thing we match agains is in $_.
            #
            my @wanted;
            unless ($skips {KP}) {
                my @wargs   =  get_args wanted_args => $target_info, $test_set;
                my $w_sub   =  $$target_info {wanted} ||
                               $$targets {$target_name} {wanted};
                @wanted     =  $w_sub ? $w_sub -> (@wargs, @args) : $_;
                if (@wanted == 1 && ref $wanted [0] eq "ARRAY") {
                    @wanted =  @{$wanted [0]};
                }
            }

            run_pass                 name     => $name,
                                     re       => $regex      unless $skips {RE};
            run_OO_pass              name     => $name,
                                     re       => $regex      unless $skips {OM};
            run_OO_substitution_pass name     => $name,
                                     re       => $regex      unless $skips {OS};
            run_sub_pass             name     => $name,
                                     sub_args => $sub_args,
                                     sub      => $sub   if $sub && !$skips {SB};
            run_keep                 name     => $name,
                                     re       => $keep,
                                     wanted   => \@wanted    unless $skips {KP};
        }
    }

    #
    # Run the failures.
    #
    foreach my $target_info (@$fail) {
        my $target_name = $$target_info {name};
        my $query = $$targets {$target_name} {query};
        next unless $$targets {$target_name} {list} &&
                  @{$$targets {$target_name} {list}};
        my $un_seen = @{$$targets {$target_name} {list}};
        my $samples   = count_me $$targets {$target_name} {list},
                                 $$target_info {limit},
                                 $$test_set {limit};
        foreach my $parts (@{$$targets {$target_name} {list}}) {
            next unless $samples > rand $un_seen --;
            $samples --;

            my @args  = ref $parts ? @$parts : $parts;
            my @qargs = get_args query_args => $target_info, $test_set;
            local $_  = $query     ? $query -> (@qargs, @args) 
                      : ref $parts ? join "" => @$parts : $parts;

            local $SKIP = $skip_sub && $skip_sub -> (fail => $_);

            my %skips;
            foreach my $skip (qw /RE SB/) {
                $skips {$skip} = is_skipped $skip => $target_info, $test_set;
            }

            run_fail                 name     => $name,
                                     re       => $regex      unless $skips {RE};
            run_sub_fail             name     => $name,
                                     sub_args => $sub_args,
                                     sub      => $sub   if $sub && !$skips {SB};
        }
    }
}

#
# If there's no list, or an empty list, 0 tests have to be run.
# If no limits are given, return the size of the list.
# Else, for the first defined limit,
#           if the limit is negative, return the size of the list,
#           else if the limit is 0, return 0,
#           else if the limit is less than 1, treat it as a fraction,
#           else, return the smaller of the limit and the size of the list.
#
sub count_me {
    my ($list, @limits) = @_;
    
    return 0 unless $list && @$list;
    foreach my $limit (@limits) {
        if (defined $limit) {
            return @$list if $limit < 0;
            return int (@$list * $limit) if $limit < 1;
            return $limit if $limit < @$list;
            return @$list;
        }
    }
    @$list;
}


#
# Normify any 'pass','fail' and 'skip' entries in a test. 
# What we want is a 'pass' and a 'fail' pointing to an array of hashes,
# each hash being a 'target'.
#
# Since we are passed a reference, the modification is done in situ.
#
sub normify {
    my $test = shift;
    foreach my $state (@STATES) {
        my @list;

        foreach my $postfix ("", "_arg") {
            my $key = "$state$postfix";
            next unless exists $$test {$key};
            my $targets = $$test {$key};
            if (ref $targets eq 'ARRAY') {
                foreach my $thingy (@$targets) {
                    if (ref $thingy eq 'HASH') {
                        push @list => $thingy;
                    }
                    elsif (!ref $thingy) {
                        push @list => {name => $thingy}
                    }
                }
            }
            elsif (ref $targets eq 'HASH') {
                push @list => $targets;
            }
            else {
                push @list => {name => $targets};
            }
            delete $$test {$key};
        }

        $$test {$state} = \@list;
    }

    #
    # Skips.
    #
    if (!exists $$test {skip}) {$$test {skip} = {}}
    elsif (ref  $$test {skip} eq 'ARRAY') {
        $$test {skip} = {map {$_ => 1} @{$$test {skip}}}
    }

    foreach my $state (@STATES) {
        foreach my $target (@{$$test {state}}) {
            if (!exists $$target {skip}) {$$target {skip} = {}}
            elsif (ref  $$target {skip}) {
                $$target {skip} = {map {$_ => 1} @{$$target {skip}}}
            }
        }
    }
}

sub is_skipped {
    my ($type, @things) = @_;
    foreach my $thingy (@things) {
        return $$thingy {skip} {$type} if defined $$thingy {skip} {$type};
    }
    return;
}

sub mult {
    my ($state, $has_sub, @things) = @_;

    my $mult;

    # Regular expression test.
    $mult ++ unless is_skipped RE => @things;

    # Subroutine check.
    $mult ++ if $has_sub && !is_skipped SB => @things;

    if ($state eq "pass") {
        # OO checks.
        $mult ++ unless is_skipped OO => @things or is_skipped OM => @things;
        $mult ++ unless is_skipped OO => @things or is_skipped OS => @things;
        # Keep check.
        $mult ++ unless is_skipped RE => @things or is_skipped KP => @things;
    }

    return $mult;
}

sub run_new_tests {
    my %args = @_;

    my ($tests, $targets, $version, $version_from,
        $extra_runs, $extra_runs_sub) =
        @args {qw /tests targets version version_from
                   extra_runs extra_runs_sub/};

    #
    # Modify any 'pass' and 'fail' entries to arrays of hashes.
    #
    foreach my $test (@$tests) {
        normify $test;
    }

    #
    # Count the number of runs.
    #
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
            my $has_sub = $$test {sub} ? 1 : 0;

            for my $state (@STATES) {
                foreach my $target (@{$$test {$state}}) {
                    my $size = count_me $$targets {$$target {name}} {list},
                                        $$target {limit},
                                        $$test   {limit};
                    $runs += $size * mult $state, $has_sub => $target, $test;
                }
            }
        }
    }

    print "1..$runs\n";

    # Check whether a version is defined.
    if (defined $version_from) {
        print "ok ", ++ $count, "\n";
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
# Any case hex digit
sub  h {(0 .. 9, 'A' .. 'F', 'a' .. 'f') [int rand 22]}
# String of anycase hex digits
sub hh {my ($min, $max) = @_ > 1 ? (@_) : ($_ [0], $_ [0]);
        join "" => map {h} 1 .. $min + int rand ($max - $min)}


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

=head1 DESCRIPTION

C<run_new_tests> is called with three (named) parameters:

=over 4

=item C<tests>

A references to an array of I<tests> (explained below).

=item C<targets>

A reference to a hash of I<targets> (explained below).

=item C<version_from>

The name of the file that is checked for a version number.

=back

=head2 Targets

Targets provide a set of strings to match against. Targets are 
indexed by name. Each target is a hash, with the following keys:

=over 4

=item C<list>

Required. This is a reference to an array that will act as building
blocks to build strings to match against. In the simplest form, this
is just an array with strings - but typically, this is an array of
arrays, each subarray used to create a string.

=item C<query>

A coderef. For each entry in array given above, this coderef is called.
It takes a set of arguments and returns a string to match against. If
the corresponding entry in C<list> is reference to an array, all its
elements are passed - otherwise, the entry is passed as a whole. Extra
arguments provided with C<query_args> below are prepended. If no coderef
is given, C<sub {$_ [0]}> is assumed.

=item C<wanted>

A coderef. If the target is used for positive matches (that is, it's
expected to match), this sub is called with the same arguments as C<query>
- except that C<wanted_args> are prepended. It should return a list of
strings as if the regular expression was called with C<{-keep}>. The
string to match against may be assumed to be C<$_>. If no coderef is given,
C<sub {$_}> is assumed.

=back

=head2 Tests

The tests to run are put in an array, and run in that order. Each test
tests a specific pattern. Up to seven types of tests are performed, depending
whether the tests includes expected failures, expected passes or both. 
Expected passes are tested as a regular expression, as a regular expression
with the C<{-keep}> option, as a subroutine, as an object using the C<match>
method, and as an object using the C<subs> method. Expected failures are 
tested as a regular expression, and as a subroutine. Each test is a hash
with the following keys:

=over 4

=item C<name>

The name of this test - mostly used in the test output.

=item C<regex>

The pattern to test with.

=item C<sub>

The subroutine to test with, if any.

=item C<sub_args>

Any arguments that need to be passed into the subroutine. If more than
one argument needs to be passed, use a reference to an array - the array
will be flattened when calling the subroutine.

=item C<query_args>

Extra arguments to pass into the C<query> coderef for all the targets
belonging to this tests, if not overriden as discussed below.

=item C<wanted_args>

Extra arguments to pass into the C<wanted> coderef for all the targets
belonging to this tests, if not overriden as discussed below.

=item C<pass>

Indicates which targets (discussed above) should be run with expected
passes.  The value of C<pass> is either a reference to an array - the
array containing the names of the targets to run, or a reference to a
hash. In the latter case, the keys are the targets to be run, while the
keys are hash references, containing more configuration options for the
target. Values allowed:

=over 4

=item C<query_args>

Extra arguments to pass into the C<query> coderef belonging to this test.
See discussion above.

=item C<wanted_args>

Extra arguments to pass into the C<wanted> coderef belonging to this test.
See discussion above.

=back

=item C<fail>

As C<pass>, except that it will list targets with an expected failure.

=back
