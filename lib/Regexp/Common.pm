package Regexp::Common;

use 5.10.0;
use strict;

use warnings;
no  warnings 'syntax';

our $VERSION = '2016060801';
our %RE;
our %sub_interface;
our $AUTOLOAD;


sub _croak {
    require Carp;
    goto &Carp::croak;
}

sub _carp {
    require Carp;
    goto &Carp::carp;
}

sub new {
    my ($class, @data) = @_;
    my %self;
    tie %self, $class, @data;
    return \%self;
}

sub TIEHASH {
    my ($class, @data) = @_;
    bless \@data, $class;
}

sub FETCH {
    my ($self, $extra) = @_;
    return bless ref($self)->new(@$self, $extra), ref($self);
}

my %imports = map {$_ => "Regexp::Common::$_"}
              qw /balanced CC     comment   delimited lingua list
                  net      number profanity SEN       URI    whitespace
                  zip/;

sub import {
    shift;  # Shift off the class.
    tie %RE, __PACKAGE__;
    {
        no strict 'refs';
        *{caller() . "::RE"} = \%RE;
    }

    my $saw_import;
    my $no_defaults;
    my %exclude;
    foreach my $entry (grep {!/^RE_/} @_) {
        if ($entry eq 'pattern') {
            no strict 'refs';
            *{caller() . "::pattern"} = \&pattern;
            next;
        }
        # This used to prevent $; from being set. We still recognize it,
        # but we won't do anything.
        if ($entry eq 'clean') {
            next;
        }
        if ($entry eq 'no_defaults') {
            $no_defaults ++;
            next;
        }
        if (my $module = $imports {$entry}) {
            $saw_import ++;
            eval "require $module;";
            die $@ if $@;
            next;
        }
        if ($entry =~ /^!(.*)/ && $imports {$1}) {
            $exclude {$1} ++;
            next;
        }
        # As a last resort, try to load the argument.
        my $module = $entry =~ /^Regexp::Common/
                            ? $entry
                            : "Regexp::Common::" . $entry;
        eval "require $module;";
        die $@ if $@;
    }

    unless ($saw_import || $no_defaults) {
        foreach my $module (values %imports) {
            next if $exclude {$module};
            eval "require $module;";
            die $@ if $@;
        }
    }

    my %exported;
    foreach my $entry (grep {/^RE_/} @_) {
        if ($entry =~ /^RE_(\w+_)?ALL$/) {
            my $m  = defined $1 ? $1 : "";
            my $re = qr /^RE_${m}.*$/;
            while (my ($sub, $interface) = each %sub_interface) {
                next if $exported {$sub};
                next unless $sub =~ /$re/;
                {
                    no strict 'refs';
                    *{caller() . "::$sub"} = $interface;
                }
                $exported {$sub} ++;
            }
        }
        else {
            next if $exported {$entry};
            _croak "Can't export unknown subroutine &$entry"
                unless $sub_interface {$entry};
            {
                no strict 'refs';
                *{caller() . "::$entry"} = $sub_interface {$entry};
            }
            $exported {$entry} ++;
        }
    }
}

sub AUTOLOAD { _croak "Can't $AUTOLOAD" }

sub DESTROY {}

my %cache;

my $fpat = qr/^(-\w+)/;

sub _decache {
        my @args = @{tied %{$_[0]}};
        my @nonflags = grep {!/$fpat/} @args;
        my $cache = get_cache(@nonflags);
        _croak "Can't create unknown regex: \$RE{"
            . join("}{",@args) . "}"
                unless exists $cache->{__VAL__};
        _croak "Perl $] does not support the pattern "
            . "\$RE{" . join("}{",@args)
            . "}.\nYou need Perl $cache->{__VAL__}{version} or later"
                unless ($cache->{__VAL__}{version}||0) <= $];
        my %flags = ( %{$cache->{__VAL__}{default}},
                      map { /$fpat\Q$;\E(.*)/ ? ($1 => $2)
                          : /$fpat/           ? ($1 => undef)
                          :                     ()
                          } @args);
        $cache->{__VAL__}->_clone_with(\@args, \%flags);
}

use overload q{""} => \&_decache;


sub get_cache {
        my $cache = \%cache;
        foreach (@_) {
                $cache = $cache->{$_}
                      || ($cache->{$_} = {});
        }
        return $cache;
}

sub croak_version {
        my ($entry, @args) = @_;
}

sub pattern {
        my %spec = @_;
        _croak 'pattern() requires argument: name => [ @list ]'
                unless $spec{name} && ref $spec{name} eq 'ARRAY';
        _croak 'pattern() requires argument: create => $sub_ref_or_string'
                unless $spec{create};

        if (ref $spec{create} ne "CODE") {
                my $fixed_str = "$spec{create}";
                $spec{create} = sub { $fixed_str }
        }

        my @nonflags;
        my %default;
        foreach ( @{$spec{name}} ) {
                if (/$fpat=(.*)/) {
                        $default{$1} = $2;
                }
                elsif (/$fpat\s*$/) {
                        $default{$1} = undef;
                }
                else {
                        push @nonflags, $_;
                }
        }

        my $entry = get_cache(@nonflags);

        if ($entry->{__VAL__}) {
                _carp "Overriding \$RE{"
                   . join("}{",@nonflags)
                   . "}";
        }

        $entry->{__VAL__} = bless {
                                create  => $spec{create},
                                match   => $spec{match} || \&generic_match,
                                subs    => $spec{subs}  || \&generic_subs,
                                version => $spec{version},
                                default => \%default,
                            }, 'Regexp::Common::Entry';

        foreach (@nonflags) {s/\W/X/g}
        my $subname = "RE_" . join ("_", @nonflags);
        $sub_interface{$subname} = sub {
                push @_ => undef if @_ % 2;
                my %flags = @_;
                my $pat = $spec{create}->($entry->{__VAL__},
                               {%default, %flags}, \@nonflags);
                if (exists $flags{-keep}) { $pat =~ s/\Q(?k:/(/g; }
                else { $pat =~ s/\Q(?k:/(?:/g; }
                return exists $flags {-i} ? qr /(?i:$pat)/ : qr/$pat/;
        };

        return 1;
}

sub generic_match {$_ [1] =~  /$_[0]/}
sub generic_subs  {$_ [1] =~ s/$_[0]/$_[2]/}

sub matches {
        my ($self, $str) = @_;
        my $entry = $self -> _decache;
        $entry -> {match} -> ($entry, $str);
}

sub subs {
        my ($self, $str, $newstr) = @_;
        my $entry = $self -> _decache;
        $entry -> {subs} -> ($entry, $str, $newstr);
        return $str;
}


package Regexp::Common::Entry;
# use Carp;

use overload
    q{""} => sub {
        my ($self) = @_;
        my $pat = $self->{create}->($self, $self->{flags}, $self->{args});
        if (exists $self->{flags}{-keep}) {
            $pat =~ s/\Q(?k:/(/g;
        }
        else {
            $pat =~ s/\Q(?k:/(?:/g;
        }
        if (exists $self->{flags}{-i})   { $pat = "(?i)$pat" }
        return $pat;
    };

sub _clone_with {
    my ($self, $args, $flags) = @_;
    bless { %$self, args=>$args, flags=>$flags }, ref $self;
}

1;

__END__

=pod

=head1 NAME

Regexp::Common - Provide commonly requested regular expressions

=head1 SYNOPSIS

 # STANDARD USAGE 

 use Regexp::Common;

 while (<>) {
     /$RE{num}{real}/               and print q{a number};
     /$RE{quoted}/                  and print q{a ['"`] quoted string};
    m[$RE{delimited}{-delim=>'/'}]  and print q{a /.../ sequence};
     /$RE{balanced}{-parens=>'()'}/ and print q{balanced parentheses};
     /$RE{profanity}/               and print q{a #*@%-ing word};
 }


 # SUBROUTINE-BASED INTERFACE

 use Regexp::Common 'RE_ALL';

 while (<>) {
     $_ =~ RE_num_real()              and print q{a number};
     $_ =~ RE_quoted()                and print q{a ['"`] quoted string};
     $_ =~ RE_delimited(-delim=>'/')  and print q{a /.../ sequence};
     $_ =~ RE_balanced(-parens=>'()'} and print q{balanced parentheses};
     $_ =~ RE_profanity()             and print q{a #*@%-ing word};
 }


 # IN-LINE MATCHING...

 if ( $RE{num}{int}->matches($text) ) {...}


 # ...AND SUBSTITUTION

 my $cropped = $RE{ws}{crop}->subs($uncropped);


 # ROLL-YOUR-OWN PATTERNS

 use Regexp::Common 'pattern';

 pattern name   => ['name', 'mine'],
         create => '(?i:J[.]?\s+A[.]?\s+Perl-Hacker)',
         ;

 my $name_matcher = $RE{name}{mine};

 pattern name    => [ 'lineof', '-char=_' ],
         create  => sub {
                        my $flags = shift;
                        my $char = quotemeta $flags->{-char};
                        return '(?:^$char+$)';
                    },
         match   => sub {
                        my ($self, $str) = @_;
                        return $str !~ /[^$self->{flags}{-char}]/;
                    },
         subs   => sub {
                        my ($self, $str, $replacement) = @_;
                        $_[1] =~ s/^$self->{flags}{-char}+$//g;
                   },
         ;

 my $asterisks = $RE{lineof}{-char=>'*'};

 # DECIDING WHICH PATTERNS TO LOAD.

 use Regexp::Common qw /comment number/;  # Comment and number patterns.
 use Regexp::Common qw /no_defaults/;     # Don't load any patterns.
 use Regexp::Common qw /!delimited/;      # All, but delimited patterns.


=head1 DESCRIPTION

By default, this module exports a single hash (C<%RE>) that stores or generates
commonly needed regular expressions (see L<"List of available patterns">).

There is an alternative, subroutine-based syntax described in
L<"Subroutine-based interface">.


=head2 General syntax for requesting patterns

To access a particular pattern, C<%RE> is treated as a hierarchical hash of
hashes (of hashes...), with each successive key being an identifier. For
example, to access the pattern that matches real numbers, you 
specify:

        $RE{num}{real}
        
and to access the pattern that matches integers: 

        $RE{num}{int}

Deeper layers of the hash are used to specify I<flags>: arguments that
modify the resulting pattern in some way. The keys used to access these
layers are prefixed with a minus sign and may have a value; if a value
is given, it's done by using a multidimensional key.
For example, to access the pattern that
matches base-2 real numbers with embedded commas separating
groups of three digits (e.g. 10,101,110.110101101):

        $RE{num}{real}{-base => 2}{-sep => ','}{-group => 3}

Through the magic of Perl, these flag layers may be specified in any order
(and even interspersed through the identifier keys!)
so you could get the same pattern with:

        $RE{num}{real}{-sep => ','}{-group => 3}{-base => 2}

or:

        $RE{num}{-base => 2}{real}{-group => 3}{-sep => ','}

or even:

        $RE{-base => 2}{-group => 3}{-sep => ','}{num}{real}

etc.

Note, however, that the relative order of amongst the identifier keys
I<is> significant. That is:

        $RE{list}{set}

would not be the same as:

        $RE{set}{list}

=head2 Flag syntax

In versions prior to 2.113, flags could also be written as
C<{"-flag=value"}>. This no longer works, although C<{"-flag$;value"}>
still does. However, C<< {-flag => 'value'} >> is the preferred syntax.

=head2 Universal flags

Normally, flags are specific to a single pattern.
However, there is two flags that all patterns may specify.

=over 4

=item C<-keep>

By default, the patterns provided by C<%RE> contain no capturing
parentheses. However, if the C<-keep> flag is specified (it requires
no value) then any significant substrings that the pattern matches
are captured. For example:

        if ($str =~ $RE{num}{real}{-keep}) {
                $number   = $1;
                $whole    = $3;
                $decimals = $5;
        }

Special care is needed if a "kept" pattern is interpolated into a
larger regular expression, as the presence of other capturing
parentheses is likely to change the "number variables" into which significant
substrings are saved.

See also L<"Adding new regular expressions">, which describes how to create
new patterns with "optional" capturing brackets that respond to C<-keep>.

=item C<-i>

Some patterns or subpatterns only match lowercase or uppercase letters.
If one wants the do case insensitive matching, one option is to use
the C</i> regexp modifier, or the special sequence C<(?i)>. But if the
functional interface is used, one does not have this option. The 
C<-i> switch solves this problem; by using it, the pattern will do
case insensitive matching.

=back

=head2 OO interface and inline matching/substitution

The patterns returned from C<%RE> are objects, so rather than writing:

        if ($str =~ /$RE{some}{pattern}/ ) {...}

you can write:

        if ( $RE{some}{pattern}->matches($str) ) {...}

For matching this would seem to have no great advantage apart from readability
(but see below).

For substitutions, it has other significant benefits. Frequently you want to
perform a substitution on a string without changing the original. Most people
use this:

        $changed = $original;
        $changed =~ s/$RE{some}{pattern}/$replacement/;

The more adept use:

        ($changed = $original) =~ s/$RE{some}{pattern}/$replacement/;

Regexp::Common allows you do write this:

        $changed = $RE{some}{pattern}->subs($original=>$replacement);

Apart from reducing precedence-angst, this approach has the added
advantages that the substitution behaviour can be optimized from the 
regular expression, and the replacement string can be provided by
default (see L<"Adding new regular expressions">).

For example, in the implementation of this substitution:

        $cropped = $RE{ws}{crop}->subs($uncropped);

the default empty string is provided automatically, and the substitution is
optimized to use:

        $uncropped =~ s/^\s+//;
        $uncropped =~ s/\s+$//;

rather than:

        $uncropped =~ s/^\s+|\s+$//g;


=head2 Subroutine-based interface

The hash-based interface was chosen because it allows regexes to be
effortlessly interpolated, and because it also allows them to be
"curried". For example:

        my $num = $RE{num}{int};

        my $commad     = $num->{-sep=>','}{-group=>3};
        my $duodecimal = $num->{-base=>12};


However, the use of tied hashes does make the access to Regexp::Common
patterns slower than it might otherwise be. In contexts where impatience
overrules laziness, Regexp::Common provides an additional
subroutine-based interface.

For each (sub-)entry in the C<%RE> hash (C<$RE{key1}{key2}{etc}>), there
is a corresponding exportable subroutine: C<RE_key1_key2_etc()>. The name of
each subroutine is the underscore-separated concatenation of the I<non-flag>
keys that locate the same pattern in C<%RE>. Flags are passed to the subroutine
in its argument list. Thus:

        use Regexp::Common qw( RE_ws_crop RE_num_real RE_profanity );

        $str =~ RE_ws_crop() and die "Surrounded by whitespace";

        $str =~ RE_num_real(-base=>8, -sep=>" ") or next;

        $offensive = RE_profanity(-keep);
        $str =~ s/$offensive/$bad{$1}++; "<expletive deleted>"/ge;

Note that, unlike the hash-based interface (which returns objects), these
subroutines return ordinary C<qr>'d regular expressions. Hence they do not
curry, nor do they provide the OO match and substitution inlining described
in the previous section.

It is also possible to export subroutines for all available patterns like so:

        use Regexp::Common 'RE_ALL';

Or you can export all subroutines with a common prefix of keys like so:

        use Regexp::Common 'RE_num_ALL';

which will export C<RE_num_int> and C<RE_num_real> (and if you have
create more patterns who have first key I<num>, those will be exported
as well). In general, I<RE_key1_..._keyn_ALL> will export all subroutines
whose pattern names have first keys I<key1> ... I<keyn>.


=head2 Adding new regular expressions

You can add your own regular expressions to the C<%RE> hash at run-time,
using the exportable C<pattern> subroutine. It expects a hash-like list of 
key/value pairs that specify the behaviour of the pattern. The various
possible argument pairs are:

=over 4

=item C<name =E<gt> [ @list ]>

A required argument that specifies the name of the pattern, and any
flags it may take, via a reference to a list of strings. For example:

         pattern name => [qw( line of -char )],
                 # other args here
                 ;

This specifies an entry C<$RE{line}{of}>, which may take a C<-char> flag.

Flags may also be specified with a default value, which is then used whenever
the flag is specified without an explicit value (but not when the flag is
omitted). For example:

         pattern name => [qw( line of -char=_ )],
                 # default char is '_'
                 # other args here
                 ;


=item C<create =E<gt> $sub_ref_or_string>

A required argument that specifies either a string that is to be returned
as the pattern:

        pattern name    => [qw( line of underscores )],
                create  => q/(?:^_+$)/
                ;

or a reference to a subroutine that will be called to create the pattern:

        pattern name    => [qw( line of -char=_ )],
                create  => sub {
                                my ($self, $flags) = @_;
                                my $char = quotemeta $flags->{-char};
                                return '(?:^$char+$)';
                            },
                ;

If the subroutine version is used, the subroutine will be called with 
three arguments: a reference to the pattern object itself, a reference
to a hash containing the flags and their values,
and a reference to an array containing the non-flag keys. 

Whatever the subroutine returns is stringified as the pattern.

No matter how the pattern is created, it is immediately postprocessed to
include or exclude capturing parentheses (according to the value of the
C<-keep> flag). To specify such "optional" capturing parentheses within
the regular expression associated with C<create>, use the notation
C<(?k:...)>. Any parentheses of this type will be converted to C<(...)>
when the C<-keep> flag is specified, or C<(?:...)> when it is not.
It is a Regexp::Common convention that the outermost capturing parentheses
always capture the entire pattern, but this is not enforced.


=item C<match =E<gt> $sub_ref>

An optional argument that specifies a subroutine that is to be called when
the C<$RE{...}-E<gt>matches(...)> method of this pattern is invoked.

The subroutine should expect two arguments: a reference to the pattern object
itself, and the string to be matched against.

It should return the same types of values as a C<m/.../> does.

     pattern name    => [qw( line of -char )],
             create  => sub {...},
             match   => sub {
                             my ($self, $str) = @_;
                             $str !~ /[^$self->{flags}{-char}]/;
                        },
             ;


=item C<subs =E<gt> $sub_ref>

An optional argument that specifies a subroutine that is to be called when
the C<$RE{...}-E<gt>subs(...)> method of this pattern is invoked.

The subroutine should expect three arguments: a reference to the pattern object
itself, the string to be changed, and the value to be substituted into it.
The third argument may be C<undef>, indicating the default substitution is
required.

The subroutine should return the same types of values as an C<s/.../.../> does.

For example:

     pattern name    => [ 'lineof', '-char=_' ],
             create  => sub {...},
             subs    => sub {
                          my ($self, $str, $ignore_replacement) = @_;
                          $_[1] =~ s/^$self->{flags}{-char}+$//g;
                        },
             ;

Note that such a subroutine will almost always need to modify C<$_[1]> directly.


=item C<version =E<gt> $minimum_perl_version>

If this argument is given, it specifies the minimum version of perl required
to use the new pattern. Attempts to use the pattern with earlier versions of
perl will generate a fatal diagnostic.

=back

=head2 Loading specific sets of patterns.

By default, all the sets of patterns listed below are made available.
However, it is possible to indicate which sets of patterns should
be made available - the wanted sets should be given as arguments to
C<use>. Alternatively, it is also possible to indicate which sets of
patterns should not be made available - those sets will be given as
argument to the C<use> statement, but are preceded with an exclaimation
mark. The argument I<no_defaults> indicates none of the default patterns
should be made available. This is useful for instance if all you want
is the C<pattern()> subroutine.

Examples:

 use Regexp::Common qw /comment number/;  # Comment and number patterns.
 use Regexp::Common qw /no_defaults/;     # Don't load any patterns.
 use Regexp::Common qw /!delimited/;      # All, but delimited patterns.

It's also possible to load your own set of patterns. If you have a
module C<Regexp::Common::my_patterns> that makes patterns available,
you can have it made available with

 use Regexp::Common qw /my_patterns/;

Note that the default patterns will still be made available - only if
you use I<no_defaults>, or mention one of the default sets explicitly,
the non mentioned defaults aren't made available.

=head2 List of available patterns

The patterns listed below are currently available. Each set of patterns
has its own manual page describing the details. For each pattern set
named I<name>, the manual page I<Regexp::Common::name> describes the
details.

Currently available are:

=over 4

=item Regexp::Common::balanced

Provides regexes for strings with balanced parenthesized delimiters.

=item Regexp::Common::comment

Provides regexes for comments of various languages (43 languages
currently).

=item Regexp::Common::delimited

Provides regexes for delimited strings.

=item Regexp::Common::lingua

Provides regexes for palindromes.

=item Regexp::Common::list

Provides regexes for lists.

=item Regexp::Common::net

Provides regexes for IPv4 addresses and MAC addresses.

=item Regexp::Common::number

Provides regexes for numbers (integers and reals).

=item Regexp::Common::profanity

Provides regexes for profanity.

=item Regexp::Common::whitespace

Provides regexes for leading and trailing whitespace.

=item Regexp::Common::zip

Provides regexes for zip codes.

=back

=head2 Forthcoming patterns and features

Future releases of the module will also provide patterns for the following:

        * email addresses 
        * HTML/XML tags
        * more numerical matchers,
        * mail headers (including multiline ones),
        * more URLS
        * telephone numbers of various countries
        * currency (universal 3 letter format, Latin-1, currency names)
        * dates
        * binary formats (e.g. UUencoded, MIMEd)

If you have other patterns or pattern generators that you think would be
generally useful, please send them to the maintainer -- preferably as source
code using the C<pattern> subroutine. Submissions that include a set of
tests will be especially welcome.


=head1 DIAGNOSTICS

=over 4

=item C<Can't export unknown subroutine %s>

The subroutine-based interface didn't recognize the requested subroutine.
Often caused by a spelling mistake or an incompletely specified name.

        
=item C<Can't create unknown regex: $RE{...}>

Regexp::Common doesn't have a generator for the requested pattern.
Often indicates a misspelt or missing parameter.

=item
C<Perl %f does not support the pattern $RE{...}.
You need Perl %f or later>

The requested pattern requires advanced regex features (e.g. recursion)
that not available in your version of Perl. Time to upgrade.

=item C<< pattern() requires argument: name => [ @list ] >>

Every user-defined pattern specification must have a name.

=item C<< pattern() requires argument: create => $sub_ref_or_string >>

Every user-defined pattern specification must provide a pattern creation
mechanism: either a pattern string or a reference to a subroutine that
returns the pattern string.

=item C<Base must be between 1 and 36>

The C<< $RE{num}{real}{-base=>'I<N>'} >> pattern uses the characters [0-9A-Z]
to represent the digits of various bases. Hence it only produces
regular expressions for bases up to hexatricensimal.

=item C<Must specify delimiter in $RE{delimited}>

The pattern has no default delimiter.
You need to write: C<< $RE{delimited}{-delim=>I<X>'} >> for some character I<X>

=back

=head1 ACKNOWLEDGEMENTS

Deepest thanks to the many people who have encouraged and contributed to this
project, especially: Elijah, Jarkko, Tom, Nat, Ed, and Vivek.

Further thanks go to: Alexandr Ciornii, Blair Zajac, Bob Stockdale,
Charles Thomas, Chris Vertonghen, the CPAN Testers, David Hand,
Fany, Geoffrey Leach, Hermann-Marcus Behrens, Jerome Quelin, Jim Cromie,
Lars Wilke, Linda Julien, Mike Arms, Mike Castle, Mikko, Murat Uenalan,
RafaE<235>l Garcia-Suarez, Ron Savage, Sam Vilain, Slaven Rezic, Smylers,
Tim Maher, and all the others I've forgotten.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

There are some POD issues when installing this module using a pre-5.6.0 perl;
some manual pages may not install, or may not install correctly using a perl
that is that old. You might consider upgrading your perl.

=head1 NOT A BUG

=over 4

=item *

The various patterns are not anchored. That is, a pattern like 
C<< $RE {num} {int} >> will match against "abc4def", because a 
substring of the subject matches. This is by design, and not a
bug. If you want the pattern to be anchored, use something like:

 my $integer = $RE {num} {int};
 $subj =~ /^$integer$/ and print "Matches!\n";

=back

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2016, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.
