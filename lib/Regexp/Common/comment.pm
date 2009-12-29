package Regexp::Common::comment; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;

#
# Data.
#

my @markers  =   (
   ['--'     =>  [qw /Ada Eiffel/]],
   ['#'      =>  [qw /awk Perl Python Ruby shell Tcl/]],
                 # http://www.catseye.mb.ca/esoteric/b-juliet/index.html
   ['//'     =>  ['beta-Juliet', 'Portia']],
                 # http://www.catseye.mb.ca/esoteric/illgol/index.html
   ['NB'     =>  [qw /ILLGOL/]],
                 # http://www.catseye.mb.ca/esoteric/smith/index.html
   [';'      =>  [qw /LOGO REBOL SMITH zonefile/]],
   ['`'      =>  [qw /Q-BAL/]],
   ['-{2,}'  =>  [qw /SQL/]],
   ['%'      =>  [qw /TeX LaTeX/]],
   ['\\\"'   =>  [qw /troff/]],
   ['"'      =>  [qw /vi/]],
);

my @ids = (
                 # http://www.catseye.mb.ca/esoteric/befunge/98/spec98.html
                 # http://www.catseye.mb.ca/esoteric/shelta/index.html
   [';'      =>  [qw /Befunge-98 Funge-98 Shelta/]],
                 # http://www.dangermouse.net/esoteric/haifu.html
   [","      =>  [qw /Haifu/]],
   ['"'      =>  [qw /Smalltalk/]],
);

my @from_to = (
   [[qw /ALPACA C LPC/]   =>  "/*", "*/"],
   # http://wouter.fov120.com/false/false.txt
   [[qw /False/]          =>  "{",  "}"],
   [[qw /*W/]             =>  "||", "!!"],
);

my @plain_or_nested = (
   [Haskell      =>  "-{2,}",     "{-"  => "-}"],
   [Dylan        =>  "//",        "/*"  => "*/"],
   [Hugo         =>  "!(?!\\\\)", "!\\" => "\\!"],
);

#
# Helper subs.
#

sub combine      {local $_ = join "|" => @_; s/\(\?k:/(?:/g; "(?k:$_)"}

sub to_eol  ($)  {"(?k:(?k:$_[0])(?k:[^\\n]*)(?k:\\n))"}
sub id      ($)  {"(?k:(?k:$_[0])(?k:[^$_[0]]*)(?k:$_[0]))"}  # One char only!
sub from_to ($$) {
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

foreach my $info (@markers) {
    my ($marker, $languages) = @$info;
    foreach my $language (@$languages) {
        pattern name    => [qw (comment), $language],
                create  => to_eol $marker,
    }
}

foreach my $info (@ids) {
    my ($marker, $languages) = @$info;
    foreach my $language (@$languages) {
        pattern name    => [qw (comment), $language],
                create  => id $marker,
    }
}

foreach my $info (@from_to) {
    my ($languages, $from, $to) = @$info;
    foreach my $language (@$languages) {
        pattern name    => [qw (comment), $language],
                create  => from_to $from, $to,
        ;
    }
}

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
    
#
# Other languages.
#

foreach my $language (qw /C++ Java/) {
    pattern name    => [qw (comment), $language],
            create  => combine to_eol "//", from_to "/*", "*/";
    ;
}

pattern name    => [qw (comment PHP)],
        create  => combine to_eol "#", to_eol "//", from_to "/*", "*/";
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


};
1;

# Todo:
#   Pascal:   (* ... *), and { ... }.  Can they be nested?
#   Modula/Oberon

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

Available languages are:

        $RE{comment}{Ada}
        $RE{comment}{ALPACA}
        $RE{comment}{awk}
        $RE{comment}{'beta-Juliet'}
        $RE{comment}{Beatnik}        # Require at least Perl 5.8.0
        $RE{comment}{'Befunge-98'}
        $RE{comment}{Brainfuck}
        $RE{comment}{C}
        $RE{comment}{'C++'}
        $RE{comment}{Dylan}          # Require at least Perl 5.6.0.
        $RE{comment}{Eiffel}
        $RE{comment}{'Funge-98'}
        $RE{comment}{Haifu}
        $RE{comment}{Haskell}        # Require at least Perl 5.6.0.
        $RE{comment}{HTML}
        $RE{comment}{Hugo}           # Require at least Perl 5.6.0.
        $RE{comment}{ILLGOL}
        $RE{comment}{Java}
        $RE{comment}{LaTeX}
        $RE{comment}{LOGO}
        $RE{comment}{LPC}
        $RE{comment}{Perl}
        $RE{comment}{PHP}
        $RE{comment}{Portia}
        $RE{comment}{Python}
        $RE{comment}{'Q-BAL'}
        $RE{comment}{REBOL}
        $RE{comment}{Ruby}
        $RE{comment}{shell}
        $RE{comment}{Shelta}
        $RE{comment}{Smalltalk}
        $RE{comment}{SMITH}
        $RE{comment}{SQL}
        $RE{comment}{SQL}{MySQL}
        $RE{comment}{Tcl}
        $RE{comment}{TeX}
        $RE{comment}{troff}
        $RE{comment}{vi}
        $RE{comment}{'*W'}
        $RE{comment}{zonefile}

C<$RE{comment}{vi}> is a regular expression matching comments used in
vi's startup file F<.exrc>, while C<$RE{comment}{zonefile}> is a regular
expression matching comments in zonefiles for I<bind>.

For HTML, the regular expression captures what's known in SGML as a
I<comment declaration>. It starts with a C<< <! >>, ends with a C<< > >>
and contains zero or more comments. Each comment starts and end with
C<< -- >>. See also S<B<[Go 90]>>.

Note that Beatnik uses capturing parenthesis, even if C<{-keep}> is
not used.

If we are using C{-keep} (See L<Regexp::Common>):

=over 4

=item For Ada, ALPACA, awk, beta-Juliet, Befunge-98, C, Eiffel, Funge-98,
          Haifu, ILLGOL, LaTeX, LOGO, LPC, Perl, Portia, Python, Q-BAL,
          REBOL, Ruby, shell, Shelta, Smalltalk, SMITH, SQL, TeX, Tcl,
          troff, vi, *W, and zonefile:

=over 4

=item $1

captures the entire match

=item $2

captures the opening comment marker

=item $3

captures the contents of the comment

=item $4

captures the closing comment marker

=back

=item For Beatnik, Brainfuck, C++, Dylan, Haskell, Hugo, Java, PHP,
      and SQL_MySQL:

=over 4

=item $1

captures the entire match

=back

=item For HTML

=over 4

=item $1

captures the entire match

=item $2

captures the MDO (C<< <! >>).

=item $3

captures the content between the MDO and the MDC.

=item $4

captures the (last) comment, without the COMs (C<< -- >>).

=item $5

captures the MDC (C<< > >>).

=back

=back

=head1 REFERENCES

=over 4

=item B<[Go 90]>

Charles F. Goldfarb: I<The SGML Handbook>. Oxford: Oxford University
Press. B<1990>. ISBN 0-19-853737-9. Ch. 10.3, pp 390-391.

=back

=head1 HISTORY

 $Log: comment.pm,v $
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

     Copyright (c) 2001 - 2002, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)

=cut
