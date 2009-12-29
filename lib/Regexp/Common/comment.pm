package Regexp::Common::comment; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;

sub to_eol {"(?k:(?k:$_[0])(?k:[^\\n]*)(?k:\\n))"}

my @markers  =   (
    '--'     =>  [qw /Ada Eiffel/],
    '#'      =>  [qw /awk Perl Python Ruby shell Tcl/],
    '%'      =>  [qw /TeX LaTeX/],
    ';'      =>  [qw /LOGO REBOL zonefile/],
    '-{2,}'  =>  [qw /SQL/],
    '"'      =>  [qw /vi/],
    '\\\"'   =>  [qw /troff/],
);

foreach my $language (qw /C LPC/) {
    pattern name    => [qw (comment), $language],
            create  => q {(?k:(?k:\/\*)(?k:(?:(?!\*\/)[\s\S])*)(?k:\*\/))},
}

foreach my $language (qw /C++ Java/) {
    pattern name    => [qw (comment), $language],
            create  => q {(?k:\/\*(?:(?!\*\/)[\s\S])*\*\/|\/\/[^\n]*\n)},
}

pattern name    => [qw (comment PHP)],
        create  => q {(?k:\/\*(?:(?!\*\/)[\s\S])*\*\/|\/\/[^\n]*\n|#[^\n]*\n)},
        ;

pattern name    => [qw (comment Smalltalk)],
        create  => q {(?k:(?k:")(?k:[^"]*)(?k:"))},
        ;

while (@markers) {
    my ($marker, $languages) = splice @markers => 0, 2;
    foreach my $language (@$languages) {
        pattern name    => [qw (comment), $language],
                create  => to_eol $marker,
    }
}

# See rules 91 and 92 of ISO 8879 (SGML).
# Charles F. Goldfarb: "The SGML Handbook".
# Oxford: Oxford University Press. 1990. ISBN 0-19-853737-9.
# Ch. 10.3, pp 390.
pattern name    => [qw (comment HTML)],
        create  => q {(?k:(?k:<!)(?k:(?:--(?k:[^-]*(?:-[^-]+)*)--\s*)*)(?k:>))},
        ;

};


pattern name    => [qw /comment Haskell/],
        create  =>
            sub {use re 'eval';
                 use vars qw /$Haskell/;
                 my $r = '(??{$Regexp::Common::comment::Haskell})';
                 $Haskell =
                 qr /-{2,}[^\n]*\n|\{-(?:(?>[^-{]+)|\{(?!-)|-(?!\})|$r)*-\}/;
                 exists $_ [1] -> {-keep} ? qr /($Haskell)/ : $Haskell;
            },
        version => 5.006,
        ;

pattern name    => [qw /comment Dylan/],
        create  =>
            sub {use re 'eval';
                 use vars qw /$Dylan/;
                 my $r = '(??{$Regexp::Common::comment::Dylan})';
                 $Dylan =
                 qr "//[^\n]*\n|/\*(?:(?>[^*/]+)|/(?!\*)|\*(?!/)|$r)*\*/";
                 exists $_ [1] -> {-keep} ? qr /($Dylan)/ : $Dylan;
            },
        version => 5.006,
        ;


pattern name    => [qw /comment SQL MySQL/],
        create  => q {(?k:(?:#|-- )[^\n]*\n|} .
                   q {/\*(?:(?>[^*;"']+)|"[^"]*"|'[^']*'|\*(?!/))*(?:;|\*/))},
        ;


1;

# Todo:
#   MySQL:    # to eol, --<SPACE> to eol, /* ... */, but ; terminates,
#                  and "" and '' remain string literals.
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
        $RE{comment}{awk}
        $RE{comment}{C}
        $RE{comment}{C++}
        $RE{comment}{Dylan}        # Require at least Perl 5.6.0.
        $RE{comment}{Eiffel}
        $RE{comment}{Haskell}      # Require at least Perl 5.6.0.
        $RE{comment}{HTML}
        $RE{comment}{Java}
        $RE{comment}{LaTeX}
        $RE{comment}{LOGO}
        $RE{comment}{LPC}
        $RE{comment}{Perl}
        $RE{comment}{PHP}
        $RE{comment}{Python}
        $RE{comment}{REBOL}
        $RE{comment}{Ruby}
        $RE{comment}{shell}
        $RE{comment}{Smalltalk}
        $RE{comment}{SQL}
        $RE{comment}{SQL}{MySQL}
        $RE{comment}{Tcl}
        $RE{comment}{TeX}
        $RE{comment}{troff}
        $RE{comment}{vi}
        $RE{comment}{zonefile}

C<$RE{comment}{vi}> is a regular expression matching comments used in
vi's startup file F<.exrc>, while C<$RE{comment}{zonefile}> is a regular
expression matching comments in zonefiles for I<bind>.

For HTML, the regular expression captures what's known in SGML as a
I<comment declaration>. It starts with a C<< <! >>, ends with a C<< > >>
and contains zero or more comments. Each comment starts and end with
C<< -- >>. See also S<B<[Go 90]>>.

If we are using C{-keep} (See L<Regexp::Common>):

=over 4

=item For Ada, awk, C, Eiffel, LaTeX, LOGO, LPC, Perl, Python,
          REBOL, Ruby, shell, Smalltalk, SQL, TeX, Tcl, troff, vi
          and zonefile:

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

=item For C++, Dylan, Haskell, Java, PHP and SQL_MySQL:

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
