# $Id: comment.pm,v 2.106 2003/03/12 22:25:42 abigail Exp $

package Regexp::Common::comment;

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;
use vars qw /$VERSION/;

($VERSION) = q $Revision: 2.106 $ =~ /[\d.]+/g;

my @generic = (
    {languages => [qw /Ada Alan Eiffel lua/],
     to_eol    => ['--']},

    {languages => [qw /Advisor/],
     to_eol    => ['#|//']},

    {languages => [qw /Advsys LOGO REBOL Scheme SMITH zonefile/],
     to_eol    => [';']},

    {languages => ['Algol 60'],
     from_to   => [[qw /comment ;/]]},

    {languages => [qw {ALPACA B C LPC PL/I}],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /awk fvwm2 mutt Perl Python Ruby shell Tcl/],
     to_eol    => ['#']},

    {languages => [[BASIC => 'mvEnterprise']],
     to_eol    => ['[*!]|REM']},

    {languages => [qw /Befunge-98 Funge-98 Shelta/],
     id        => [';']},

    {languages => ['beta-Juliet', 'Crystal Report', 'Portia'],
     to_eol    => ['//']},

    {languages => [qw /C++ FPL Java/],
     to_eol    => ['//'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /False/],
     from_to   => [[qw !{ }!]]},

    {languages => [qw /Forth/],
     to_eol    => ['\\\\']},

    {languages => [qw /Fortran/],
     to_eol    => ['!']},

    {languages => [qw /Haifu/],
     id        => [',']},

    {languages => [qw /ILLGOL/],
     to_eol    => ['NB']},

    {languages => [qw /LaTeX slrn TeX/],
     to_eol    => ['%']},

    {languages => [qw /Oberon/],
     from_to   => [[qw /(* *)/]]},
     
    {languages => [[qw /Pascal Delphi/], [qw /Pascal Free/], [qw /Pascal GPC/]],
     to_eol    => ['//'],
     from_to   => [[qw !{ }!], [qw !(* *)!]]},

    {languages => [[qw /Pascal Workshop/]],
     id        => [qw /"/],
     from_to   => [[qw !{ }!], [qw !(* *)!], [qw !/* */!]]},

    {languages => [qw /PEARL/],
     to_eol    => ['!'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw /PHP/],
     to_eol    => ['#', '//'],
     from_to   => [[qw {/* */}]]},

    {languages => [qw !PL/B!],
     to_eol    => ['[.;]']},

    {languages => [qw /Q-BAL/],
     to_eol    => ['`']},

    {languages => [qw /Smalltalk/],
     id        => ['"']},

    {languages => [qw /SQL/],
     to_eol    => ['-{2,}']},

    {languages => [qw /troff/],
     to_eol    => ['\\\"']},

    {languages => [qw /vi/],
     to_eol    => ['"']},

    {languages => [qw /*W/],
     from_to   => [[qw {|| !!}]]},
);

my @plain_or_nested = (
   [Dylan        =>  "//",        "/*"  => "*/"],
   [Haskell      =>  "-{2,}",     "{-"  => "-}"],
   [Hugo         =>  "!(?!\\\\)", "!\\" => "\\!"],
);

#
# Helper subs.
#

sub combine      {
    local $_ = join "|", @_;
    if (@_ > 1) {
        s/\(\?k:/(?:/g if @_ > 1;
        $_ = "(?k:$_)";
    }
    $_
}

sub to_eol  ($)  {"(?k:(?k:$_[0])(?k:[^\\n]*)(?k:\\n))"}
sub id      ($)  {"(?k:(?k:$_[0])(?k:[^$_[0]]*)(?k:$_[0]))"}  # One char only!
sub from_to      {
    local $^W = 1;
    my ($begin, $end) = @_;

    my $qb  = quotemeta $begin;
    my $qe  = quotemeta $end;
    my $fe  = quotemeta substr $end   => 0, 1;
    my $te  = quotemeta substr $end   => 1;

    "(?k:(?k:$qb)(?k:(?:[^$fe]+|$fe(?!$te))*)(?k:$qe))";
}


my $count = 0;
sub nested ($$) {
    local $^W = 1;
    my ($begin, $end) = @_;

    $count ++;
    my $r = '(??{$Regexp::Common::comment ['. $count . ']})';

    my $qb  = quotemeta $begin;
    my $qe  = quotemeta $end;
    my $fb  = quotemeta substr $begin => 0, 1;
    my $fe  = quotemeta substr $end   => 0, 1;

    my $tb  = quotemeta substr $begin => 1;
    my $te  = quotemeta substr $end   => 1;

    use re 'eval';

    my $re;
    if ($fb eq $fe) {
        $re = qr /(?:$qb(?:(?>[^$fb]+)|$fb(?!$tb)(?!$te)|$r)*$qe)/;
    }
    else {
        local $"      =  "|";
        my   @clauses =  "(?>[^$fb$fe]+)";
        push @clauses => "$fb(?!$tb)" if length $tb;
        push @clauses => "$fe(?!$te)" if length $te;
        push @clauses =>  $r;
        $re           =   qr /(?:$qb(?:@clauses)*$qe)/;
    }

    $Regexp::Common::comment [$count] = qr/$re/;
}

#
# Process data.
#

foreach my $info (@plain_or_nested) {
    my ($language, $mark, $begin, $end) = @$info;
    pattern name    => [comment => $language],
            create  =>
                sub {my $re = nested $begin, $end;
                     exists $_ [1] -> {-keep} ? qr /($mark[^\n]*\n|$re)/
                                              : qr  /$mark[^\n]*\n|$re/
                },
            version => 5.006,
            ;
}


foreach my $group (@generic) {
    my $pattern = combine +(map {to_eol   $_} @{$group -> {to_eol}}),
                           (map {from_to @$_} @{$group -> {from_to}}),
                           (map {id       $_} @{$group -> {id}}),
                  ;
    foreach my $language (@{$group -> {languages}}) {
        pattern name   => [comment => ref $language ? @$language : $language],
                create => $pattern
                ;
    }
}
                

    
#
# Other languages.
#

# http://www.pascal-central.com/docs/iso10206.txt
pattern name    => [qw /comment Pascal/],
        create  => '(?k:' . '(?k:[{]|[(][*])'
                          . '(?k:[^}*]*(?:[*][^)][^}*]*)*)'
                          . '(?k:[}]|[*][)])'
                          . ')'
        ;

# http://www.templetons.com/brad/alice/language/
pattern name    =>  [qw /comment Pascal Alice/],
        create  =>  '(?k:(?k:[{])(?k:[^}\n]*)(?k:[}]))'
        ;


# http://westein.arb-phys.uni-dortmund.de/~wb/a68s.txt
pattern name    => [qw (comment), 'Algol 68'],
        create  => q {(?k:(?:#[^#]*#)|}                           .
                   q {(?:\bco\b(?:[^c]+|\Bc|\bc(?!o\b))*\bco\b)|} .
                   q {(?:\bcomment\b(?:[^c]+|\Bc|\bc(?!omment\b))*\bcomment\b))}
        ;


# See rules 91 and 92 of ISO 8879 (SGML).
# Charles F. Goldfarb: "The SGML Handbook".
# Oxford: Oxford University Press. 1990. ISBN 0-19-853737-9.
# Ch. 10.3, pp 390.
pattern name    => [qw (comment HTML)],
        create  => q {(?k:(?k:<!)(?k:(?:--(?k:[^-]*(?:-[^-]+)*)--\s*)*)(?k:>))},
        ;


pattern name    => [qw /comment SQL MySQL/],
        create  => q {(?k:(?:#|-- )[^\n]*\n|} .
                   q {/\*(?:(?>[^*;"']+)|"[^"]*"|'[^']*'|\*(?!/))*(?:;|\*/))},
        ;

# Anything that isn't <>[]+-.,
# http://home.wxs.nl/~faase009/Ha_BF.html
pattern name    => [qw /comment Brainfuck/],
        create  => '(?k:[^<>\[\]+\-.,]+)'
        ;

# Squeak is a variant of Smalltalk-80.
# http://www.squeak.
# http://mucow.com/squeak-qref.html
pattern name    => [qw /comment Squeak/],
        create  => '(?k:(?k:")(?k:[^"]*(?:""[^"]*)*)(?k:"))'
        ;

#
# Scores of less than 5 or above 17....
# http://www.cliff.biffle.org/esoterica/beatnik.html
@Regexp::Common::comment::scores = (1,  3,  3,  2,  1,  4,  2,  4,  1,  8,
                                    5,  1,  3,  1,  1,  3, 10,  1,  1,  1,
                                    1,  4,  4,  8,  4, 10);
pattern name    =>  [qw /comment Beatnik/],
        create  =>  sub {
            use re 'eval';
            my ($s, $x);
            my $re = qr {\b([A-Za-z]+)\b
                         (?(?{($s, $x) = (0, lc $^N);
                              $s += $Regexp::Common::comment::scores
                                    [ord (chop $x) - ord ('a')] while length $x;
                              $s  >= 5 && $s < 18})XXX|)}x;
            $re;
        },
        version  => 5.008,
        ;


# http://www.cray.com/craydoc/manuals/007-3692-005/html-007-3692-005/
#  (Goto table of contents/3.3 Source Form)
# Fortran, in fixed format. Comments start with a C, c or * in the first
# column, or a ! anywhere, but the sixth column. Then end with a newline.
pattern name    =>  [qw /comment Fortran fixed/],
        create  =>  '(?k:(?k:(?:^[Cc*]|(?<!^.....)!))(?k:[^\n]*)(?k:\n))'
        ;

1;

# Todo:
#   Modula
#

__END__

=pod

=head1 NAME

Regexp::Common::comment -- provide regexes for comments.

=head1 SYNOPSIS

    use Regexp::Common qw /comment/;

    while (<>) {
        /$RE{comment}{C}/       and  print "Contains a C comment\n";
        /$RE{comment}{C++}/     and  print "Contains a C++ comment\n";
        /$RE{comment}{PHP}/     and  print "Contains a PHP comment\n";
        /$RE{comment}{Java}/    and  print "Contains a Java comment\n";
        /$RE{comment}{Perl}/    and  print "Contains a Perl comment\n";
        /$RE{comment}{awk}/     and  print "Contains an awk comment\n";
        /$RE{comment}{HTML}/    and  print "Contains an HTML comment\n";
    }

    use Regexp::Common qw /comment RE_comment_HTML/;

    while (<>) {
        $_ =~ RE_comment_HTML() and  print "Contains an HTML comment\n";
    }

=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

This modules gives you regular expressions for comments in various
languages.

=head2 THE LANGUAGES

Below, the comments of each of the languages are described.
The patterns are available as C<$RE{comment}{I<LANG>}>, foreach
language I<LANG>. Some languages have variants; it's described
at the individual languages how to get the patterns for the variants.
Unless mentioned otherwise,
C<{-keep}> sets C<$1>, C<$2>, C<$3> and C<$4> to the entire comment,
the opening marker, the content of the comment, and the closing marker
(for many languages, the latter is a newline) respectively.

=over 4

=item Ada

Comments in I<Ada> start with C<-->, and last till the end of the line.

=item Advisor

I<Advisor> is a language used by the HP product I<glance>. Comments for
this language start with either C<#> or C<//>, and last till the
end of the line.

=item Advsys

Comments for the I<Advsys> language start with C<;> and last till
the end of the line. See also L<http://www.wurb.com/if/devsys/12>.

=item Alan

I<Alan> comments start with C<-->, and last till the end of the line.
See also L<http://w1.132.telia.com/~u13207378/alan/manual/alanTOC.html>.

=item Algol 60

Comments in the I<Algol 60> language start with the keyword C<comment>,
and end with a C<;>. See L<http://www.masswerk.at/algol60/report.htm>.

=item Algol 68

In I<Algol 68>, comments are either delimited by C<#>, or by one of the
keywords C<co> or C<comment>. The keywords should not be part of another
word. See L<http://westein.arb-phys.uni-dortmund.de/~wb/a68s.txt>.
With C<{-keep}>, only C<$1> will be set, returning the entire comment.

=item ALPACA

The I<ALPACA> language has comments starting with C</*> and ending with C<*/>.

=item awk

The I<awk> programming language uses comments that start with C<#>
and end at the end of the line.

=item B

The I<B> language has comments starting with C</*> and ending with C<*/>.

=item BASIC

There are various forms of BASIC around. Currently, we only support the
variant supported by I<mvEnterprise>, whose pattern is available as
C<$RE{comment}{BASIC}{mvEnterprise}>. Comments in this language start with a
C<!>, a C<*> or the keyword C<REM>, and end till the end of the line. See
L<http://www.rainingdata.com/products/beta/docs/mve/50/ReferenceManual/Basic.pdf>.

=item Beatnik

The estoric language I<Beatnik> only uses words consisting of letters.
Words are scored according to the rules of Scrabble. Words scoring less
than 5 points, or 18 points or more are considered comments (although
the compiler might mock at you if you score less than 5 points).
Regardless whether C<{-keep}>, C<$1> will be set, and set to the
entire comment. This pattern requires I<perl 5.8.0> or newer.

=item beta-Juliet

The I<beta-Juliet> programming language has comments that start with
C<//> and that continue till the end of the line. See also
L<http://www.catseye.mb.ca/esoteric/b-juliet/index.html>.

=item Befunge-98

The estoric language I<Befunge-98> uses comments that start and end
with a C<;>. See L<http://www.catseye.mb.ca/esoteric/befunge/98/spec98.html>.

=item Brainfuck

The minimal language I<Brainfuck> uses only eight characters, 
C<E<lt>>, C<E<gt>>, C<[>, C<]>, C<+>, C<->, C<.> and C<,>.
Any other characters are considered comments. With C<{-keep}>,
C<$1> is set to the entire comment.

=item C

The I<C> language has comments starting with C</*> and ending with C<*/>.

=item C++

The I<C++> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.

=item Crystal Report

The formula editor in I<Crystal Reports> uses comments that start
with C<//>, and end with the end of the line.

=item Dylan

There are two types of comments in I<Dylan>. They either start with
C<//>, or are nested comments, delimited with C</*> and C<*/>.
Under C<{-keep}>, only C<$1> will be set, returning the entire comment.
This pattern requires I<perl 5.6.0> or newer.

=item Eiffel

I<Eiffel> comments start with C<-->, and last till the end of the line.

=item False

In I<False>, comments start with C<{> and end with C<}>.
See L<http://wouter.fov120.com/false/false.txt>

=item FPL

The I<FPL> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.

=item Forth

Comments in Forth start with C<\>, and end with the end of the line.
See also L<http://docs.sun.com/sb/doc/806-1377-10>.

=item Fortran

There are two forms of I<Fortran>. There's free form I<Fortran>, which
has comments that start with C<!>, and end at the end of the line.
The pattern for this is given by C<$RE{Fortran}>. Fixed form I<Fortran>,
which has been obsoleted, has comments that start with C<C>, C<c> or
C<*> in the first column, or with C<!> anywhere, but the sixth column.
The pattern for this are given by C<$RE{Fortran}{fixed}>.

See also L<http://www.cray.com/craydoc/manuals/007-3692-005/html-007-3692-005/>.

=item Funge-98

The estoric language I<Funge-98> uses comments that start and end with
a C<;>.

=item fvwm2

Configuration files for I<fvwm2> have comments starting with a
C<#> and lasting the rest of the line.

=item Haifu

I<Haifu>, an estoric language using haikus, has comments starting and
ending with a C<,>.
See L<http://www.dangermouse.net/esoteric/haifu.html>.

=item Haskell

There are two types of comments in I<Haskell>. They either start with
at least two dashes, or are nested comments, delimited with C<{-> and C<-}>.
Under C<{-keep}>, only C<$1> will be set, returning the entire comment.
This pattern requires I<perl 5.6.0> or newer.

=item HTML

In I<HTML>, comments only appear inside a I<comment declaration>.
A comment declaration starts with a C<E<lt>!>, and ends with a
C<E<gt>>. Inside this declaration, we have zero or more comments.
Comments starts with C<--> and end with C<-->, and are optionally
followed by whitespace. The pattern C<$RE{comment}{HTML}> recognizes
those comment declarations (and hence more than a comment).
Note that this is not the same as something that starts with
C<E<lt>!--> and ends with C<--E<gt>>, because the following will
be matched completely:

    <!--  First  Comment   --
      --> Second Comment <!--
      --  Third  Comment   -->

Do not be fooled by what your favourite browser thinks is an HTML
comment.

If C<{-keep}> is used, the following are returned:

=over 4

=item $1

captures the entire comment declaration.

=item $2

captures the MDO (markup declaration open), C<E<lt>!>.

=item $3

captures the content between the MDO and the MDC.

=item $4

captures the (last) comment, without the surrounding dashes.

=item $5

captures the MDC (markup declaration close), C<E<lt>>.

=back

=item Hugo

There are two types of comments in I<Hugo>. They either start with
C<!> (which cannot be followed by a C<\>), or are nested comments,
delimited with C<!\> and C<\!>.
Under C<{-keep}>, only C<$1> will be set, returning the entire comment.
This pattern requires I<perl 5.6.0> or newer.

=item ILLGOL

The estoric language I<ILLGOL> uses comments starting with I<NB> and lasting
till the end of the line.
See L<http://www.catseye.mb.ca/esoteric/illgol/index.html>.

=item Java

The I<Java> language has two forms of comments. Comments that start with
C<//> and last till the end of the line, and comments that start with
C</*>, and end with C<*/>. If C<{-keep}> is used, only C<$1> will be
set, and set to the entire comment.
=item LaTeX

The documentation language I<LaTeX> uses comments starting with C<%>
and ending at the end of the line.

=item LPC

The I<LPC> language has comments starting with C</*> and ending with C<*/>.

=item LOGO

Comments for the language I<LOGO> start with C<;>, and last till the end
of the line.

=item lua

Comments for the I<lua> language start with C<-->, and last till the end
of the line. See also L<http://www.lua.org/manual/manual.html>.

=item mutt

Configuration files for I<mutt> have comments starting with a
C<#> and lasting the rest of the line.

=item Oberon

Comments in I<Oberon> start with C<(*> and end with C<*)>.
See L<http://www.oberon.ethz.ch/oreport.html>.

=item Pascal

There are many implementations of Pascal. Some of them are implemented
by this module.

=over 4

=item C<$RE{comment}{Pascal}>

This is the pattern that recognizes comments according to the Pascal ISO 
standard. This standard says that comments start with either C<{>, or
C<(*>, and end with C<}> or C<*)>. This means that C<{*)> and C<(*}>
are considered to be comments. Many Pascal applications don't allow this.
See L<http://www.pascal-central.com/docs/iso10206.txt>

=item C<$RE{comment}{Alice}>

The I<Alice Pascal> compiler accepts comments that start with C<{>
and end with C<}>. Comments are not allowed to contain newlines.
See L<http://www.templetons.com/brad/alice/language/>.

=item C<$RE{comment}{Pascal}{Delphi}>, C<$RE{comment}{Pascal}{Free}>
and C<$RE{comment}{Pascal}{GPC}>

The I<Delphi Pascal>, I<Free Pascal> and the I<Gnu Pascal Compiler>
implementations of Pascal all have comments that either start with
C<//> and last till the end of the line, are delimited with C<{>
and C<}> or are delimited with C<(*> and C<*)>. Patterns for those
comments are given by C<$RE{comment}{Pascal}{Delphi}>, 
C<$RE{comment}{Pascal}{Free}> and C<$RE{comment}{Pascal}{GPC}>
respectively. These patterns only set C<$1> when C<{-keep}> is used,
which will then include the entire comment.

See L<http://info.borland.com/techpubs/delphi5/oplg/>, 
L<http://www.freepascal.org/docs-html/ref/ref.html> and
L<http://www.gnu-pascal.de/gpc/>.

=item C<$RE{comment}{Pascal}{Workshop}>

The I<Workshop Pascal> compiler, from SUN Microsystems, allows comments
that are delimited with either C<{> and C<}>, delimited with
C<(*)> and C<*>), delimited with C</*>, and C<*/>, or starting
and ending with a double quote (C<">). When C<{-keep}> is used,
only C<$1> is set, and returns the entire comment.

See L<http://docs.sun.com/db/doc/802-5762>.

=back

=item PEARL

Comments in I<PEARL> start with a C<!> and last till the end of the
line, or start with C</*> and end with C<*/>. With C<{-keep}>, 
C<$1> will be set to the entire comment.

=item PHP

Comments in I<PHP> start with either C<#> or C<//> and last till the
end of the line, or are delimited by C</*> and C<*/>. With C<{-keep}>,
C<$1> will be set to the entire comment.

=item PL/B

In I<PL/B>, comments start with either C<.> or C<;>, and end with the 
next newline. See L<http://www.mmcctech.com/pl-b/plb-0010.htm>.

=item PL/I

The I<PL/I> language has comments starting with C</*> and ending with C<*/>.

=item Perl

I<Perl> uses comments that start with a C<#>, and continue till the end
of the line.

=item Portia

The I<Portia> programming language has comments that start with C<//>,
and last till the end of the line.

=item Python

I<Python> uses comments that start with a C<#>, and continue till the end
of the line.

=item Q-BAL

Comments in the I<Q-BAL> language start with C<`> (a backtick), and
contine till the end of the line.

=item REBOL

Comments for the I<REBOL> language start with C<;> and last till the
end of the line.

=item Ruby

Comments in I<Ruby> start with C<#> and last till the end of the time.

=item Scheme

I<Scheme> comments start with C<;>, and last till the end of the line.
See L<http://schemers.org/>.

=item shell

Comments in various I<shell>s start with a C<#> and end at the end of
the line.

=item Shelta

The estoric language I<Shelta> uses comments that start and end with
a C<;>. See L<http://www.catseye.mb.ca/esoteric/shelta/index.html>.

=item slrn

Configuration files for I<slrn> have comments starting with a
C<%> and lasting the rest of the line.

=item Smalltalk

I<Smalltalk> uses comments that start and end with a double quote, C<">.

=item SMITH

Comments in the I<SMITH> language start with C<;>, and last till the
end of the line.

=item Squeak

In the Smalltalk variant I<Squeak>, comments start and end with
C<">. Double quotes can appear inside comments by doubling them.

=item SQL

Standard I<SQL> uses comments starting with two or more dashes, and
ending at the end of the line. 

I<MySQL> does not follow the standard. Instead, it allows comments
that start with a C<#> or C<-- > (that's two dashes and a space)
ending with the following newline, and comments starting with 
C</*>, and ending with the next C<;> or C<*/> that isn't inside
single or double quotes. A pattern for this is returned by
C<$RE{comment}{SQL}{MySQL}>. With C<{-keep}>, only C<$1> will
be set, and it returns the entire comment.

=item Tcl

In I<Tcl>, comments start with C<#> and continue till the end of the line.

=item TeX

The documentation language I<TeX> uses comments starting with C<%>
and ending at the end of the line.

=item troff

The document formatting language I<troff> uses comments starting
with C<\">, and continuing till the end of the line.

=item vi

In configuration files for the editor I<vi>, one can use comments
starting with C<">, and ending at the end of the line.

=item *W

In the language I<*W>, comments start with C<||>, and end with C<!!>.

=item zonefile

Comments in DNS I<zonefile>s start with C<;>, and continue till the
end of the line.

=back

=head1 REFERENCES

=over 4

=item B<[Go 90]>

Charles F. Goldfarb: I<The SGML Handbook>. Oxford: Oxford University
Press. B<1990>. ISBN 0-19-853737-9. Ch. 10.3, pp 390-391.

=back

=head1 HISTORY

 $Log: comment.pm,v $
 Revision 2.106  2003/03/12 22:25:42  abigail
 - More generic setup to define comments for various languages.
 - Expanded and redid the documentation for comment.pm.
 - Comments for Advisor, Advsys, Alan, Algol 60, Algol 68, B,
   BASIC (mvEnterprise), Forth, Fortran (both fixed and free form),
   fvwm2, mutt, Oberon, 6 versions of Pascal,
   PEARL (one of the at least four...), PL/B, PL/I, slrn, Squeak.

 Revision 2.105  2003/03/09 19:04:42  abigail
 - More generic setup to define comments for various languages.
 - Expanded and redid the documentation for comment.pm.
   Now every language has its own paragraph, describing its comment,
   and pointers to webpages.
 - Comments for Advisor, Advsys, Alan, Algol 60, Algol 68, B, BASIC
   (mvEnterprise), Forth, Fortran (both fixed and free form), fvwm2, mutt,
   Oberon, 6 versions of Pascal, PEARL (one of the at least four...), PL/B,
   PL/I, slrn, Squeak.

 Revision 2.104  2003/02/21 14:48:06  abigail
 Crystal Reports

 Revision 2.103  2003/02/11 09:39:08  abigail
 Added

 Revision 2.102  2003/02/07 15:23:54  abigail
 Lua and FPL

 Revision 2.101  2003/02/01 22:55:31  abigail
 Changed Copyright years

 Revision 2.100  2003/01/21 23:19:40  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.19  2002/11/06 13:51:34  abigail
 Minor POD changes.

 Revision 1.18  2002/09/18 18:13:01  abigail
 Fixes for 5.005

 Revision 1.17  2002/09/04 17:04:24  abigail
 Q-BAL

 Revision 1.16  2002/08/27 16:50:50  abigail
 Patterns for Beatnik, Befunge-98, Funge-98 and W*.

 Revision 1.15  2002/08/22 17:04:03  abigail
 SMITH added

 Revision 1.14  2002/08/22 16:41:25  abigail
 + Added function 'id' and 'from_to' with associated data.
 + Added function 'combine' for languages having multiple syntaxes.
 + Added 'Shelta'

 Revision 1.13  2002/08/21 16:00:32  abigail
 beta-Juliet, Portia, ILLGOL and Brainfuck.

 Revision 1.12  2002/08/20 17:40:37  abigail
 - Created a 'nested' function (simplified version from
   Regexp::Common::balanced).
 - Comments that use 'from' to eol or balanced (nested) delimiters
   are now generated from a data array.
 - Added Hugo and Haifu.

 Revision 1.11  2002/08/05 12:16:58  abigail
 Fixed 'Regex::' and 'Rexexp::' typos to 'Regexp::'
 (Found my Mike Castle).

 Revision 1.10  2002/07/31 23:33:16  abigail
 Documented that Haskell and Dylan comments need at least 5.6.0.

 Revision 1.9  2002/07/31 23:12:29  abigail
 Dylan and Haskell comments can be nested, hence version 5.6.0 of Perl
 is needed to be able to make a regex matching them.

 Revision 1.8  2002/07/31 14:48:16  abigail
 Added LOGO (to please petdance)

 Revision 1.7  2002/07/31 13:06:41  abigail
 Dealt with -keep for Haskell and Dylan.

 Revision 1.6  2002/07/31 00:54:00  abigail
 Added comments for Haskell, Dylan, Smalltalk and MySQL.

 Revision 1.5  2002/07/30 16:38:23  abigail
 Added support for the languages: LaTeX, Tcl, TeX and troff.

 Revision 1.4  2002/07/26 16:48:12  abigail
 Simplied datastructure for the languages that use single line comments.

 Revision 1.3  2002/07/26 16:37:20  abigail
 Added new languages: Ada, awk, Eiffel, Java, LPC, PHP, Python,
 REBOL, Ruby, vi and zonefile.

 Revision 1.2  2002/07/25 22:37:44  abigail
 Added 'use strict'.
 Added 'no_defaults' to 'use Regex::Common' to prevent loaded of all
 defaults.

 Revision 1.1  2002/07/25 19:56:07  abigail
 Modularizing Regexp::Common.

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.nl>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.nl>.

=head1 COPYRIGHT

     Copyright (c) 2001 - 2003, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)

=cut
