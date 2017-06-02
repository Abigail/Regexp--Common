package Regexp::Common::delimited;

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common qw /pattern clean no_defaults/;

use charnames ':full';

our $VERSION = '2017060201';

sub gen_delimited {

    my ($dels, $escs, $cdels) = @_;
    # return '(?:\S*)' unless $dels =~ /\S/;
    if (defined $escs && length $escs) {
        $escs  .= substr  ($escs, -1) x (length ($dels) - length  ($escs));
    }
    if (defined $cdels && length $cdels) {
        $cdels .= substr ($cdels, -1) x (length ($dels) - length ($cdels));
    }
    else {
        $cdels = $dels;
    }

    my @pat = ();
    for (my $i = 0; $i < length $dels; $i ++) {
        my $del  = quotemeta substr  ($dels, $i, 1);
        my $cdel = quotemeta substr ($cdels, $i, 1);
        my $esc  = defined $escs && length ($escs)
                           ? quotemeta substr ($escs, $i, 1) : "";
        if ($cdel eq $esc) {
            push @pat =>
                "(?k:$del)(?k:[^$cdel]*(?:(?:$cdel$cdel)[^$cdel]*)*)(?k:$cdel)";
        }
        elsif (length $esc) {
            push @pat =>
                "(?k:$del)(?k:[^$esc$cdel]*(?:$esc.[^$esc$cdel]*)*)(?k:$cdel)";
        }
        else {
            push @pat => "(?k:$del)(?k:[^$cdel]*)(?k:$cdel)";
        }
    }
    my $pat = join '|', @pat;
    return "(?k:(?|$pat))";
}

sub _croak {
    require Carp;
    goto &Carp::croak;
}

pattern name    => [qw( delimited -delim= -esc=\\ -cdelim= )],
        create  => sub {my $flags = $_[1];
                        _croak 'Must specify delimiter in $RE{delimited}'
                              unless length $flags->{-delim};
                        return gen_delimited (@{$flags}{-delim, -esc, -cdelim});
                   },
        ;

pattern name    => [qw( quoted -esc=\\ )],
        create  => sub {my $flags = $_[1];
                        return gen_delimited (q{"'`}, $flags -> {-esc});
                   },
        ;


my @bracket_pairs;
if ($] >= 5.014) {
    #
    # List from http://xahlee.info/comp/unicode_matching_brackets.html
    #
    @bracket_pairs =
        map {ref $_ ? $_ :
                /!/ ? [(do {my $x = $_; $x =~ s/!/TOP/;    $x},
                        do {my $x = $_; $x =~ s/!/BOTTOM/; $x})]
                    : [(do {my $x = $_; $x =~ s/\?/LEFT/;  $x},
                        do {my $x = $_; $x =~ s/\?/RIGHT/; $x})]}
            "? PARENTHESIS",
            "? SQUARE BRACKET",
            "? CURLY BRACKET",
            "? DOUBLE QUOTATION MARK",
            "? SINGLE QUOTATION MARK",
            "SINGLE ?-POINTING ANGLE QUOTATION MARK",
            "?-POINTING DOUBLE ANGLE QUOTATION MARK",
            "FULLWIDTH ? PARENTHESIS",
            "FULLWIDTH ? SQUARE BRACKET",
            "FULLWIDTH ? CURLY BRACKET",
            "FULLWIDTH ? WHITE PARENTHESIS",
            "? WHITE PARENTHESIS",
            "? WHITE SQUARE BRACKET",
            "? WHITE CURLY BRACKET",
            "? CORNER BRACKET",
            "? ANGLE BRACKET",
            "? DOUBLE ANGLE BRACKET",
            "? BLACK LENTICULAR BRACKET",
            "? TORTOISE SHELL BRACKET",
            "? BLACK TORTOISE SHELL BRACKET",
            "? WHITE CORNER BRACKET",
            "? WHITE LENTICULAR BRACKET",
            "? WHITE TORTOISE SHELL BRACKET",
            "HALFWIDTH ? CORNER BRACKET",
            "MATHEMATICAL ? WHITE SQUARE BRACKET",
            "MATHEMATICAL ? ANGLE BRACKET",
            "MATHEMATICAL ? DOUBLE ANGLE BRACKET",
            "MATHEMATICAL ? FLATTENED PARENTHESIS",
            "MATHEMATICAL ? WHITE TORTOISE SHELL BRACKET",
            "? CEILING",
            "? FLOOR",
            "Z NOTATION ? IMAGE BRACKET",
            "Z NOTATION ? BINDING BRACKET",
            [   "HEAVY SINGLE TURNED COMMA QUOTATION MARK ORNAMENT",
                "HEAVY SINGLE " .   "COMMA QUOTATION MARK ORNAMENT", ],
            [   "HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT",
                "HEAVY DOUBLE " .   "COMMA QUOTATION MARK ORNAMENT", ],
            "MEDIUM ? PARENTHESIS ORNAMENT",
            "MEDIUM FLATTENED ? PARENTHESIS ORNAMENT",
            "MEDIUM ? CURLY BRACKET ORNAMENT",
            "MEDIUM ?-POINTING ANGLE BRACKET ORNAMENT",
            "HEAVY ?-POINTING ANGLE QUOTATION MARK ORNAMENT",
            "HEAVY ?-POINTING ANGLE BRACKET ORNAMENT",
            "LIGHT ? TORTOISE SHELL BRACKET ORNAMENT",
            "ORNATE ? PARENTHESIS",
            "! PARENTHESIS",
            "! SQUARE BRACKET",
            "! CURLY BRACKET",
            "! TORTOISE SHELL BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? CORNER BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? WHITE CORNER BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? TORTOISE SHELL BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? BLACK LENTICULAR BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? WHITE LENTICULAR BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? ANGLE BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? DOUBLE ANGLE BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? SQUARE BRACKET",
            "PRESENTATION FORM FOR VERTICAL ? CURLY BRACKET",
            "?-POINTING ANGLE BRACKET",
            "? ANGLE BRACKET WITH DOT",
            "?-POINTING CURVED ANGLE BRACKET",
            "SMALL ? PARENTHESIS",
            "SMALL ? CURLY BRACKET",
            "SMALL ? TORTOISE SHELL BRACKET",
            "SUPERSCRIPT ? PARENTHESIS",
            "SUBSCRIPT ? PARENTHESIS",
            "? SQUARE BRACKET WITH UNDERBAR",
            [    "LEFT SQUARE BRACKET WITH TICK IN TOP CORNER",
                "RIGHT SQUARE BRACKET WITH TICK IN BOTTOM CORNER", ],
            [    "LEFT SQUARE BRACKET WITH TICK IN BOTTOM CORNER",
                "RIGHT SQUARE BRACKET WITH TICK IN TOP CORNER", ],
            "? SQUARE BRACKET WITH QUILL",
            "TOP ? HALF BRACKET",
            "BOTTOM ? HALF BRACKET",
            "? S-SHAPED BAG DELIMITER",
            [    "LEFT ARC LESS-THAN BRACKET",
                "RIGHT ARC GREATER-THAN BRACKET",  ],
            [    "DOUBLE LEFT ARC GREATER-THAN BRACKET",
                "DOUBLE RIGHT ARC LESS-THAN BRACKET",  ],
            "? SIDEWAYS U BRACKET",
            "? DOUBLE PARENTHESIS",
            "? WIGGLY FENCE",
            "? DOUBLE WIGGLY FENCE",
            "? LOW PARAPHRASE BRACKET",
            "? RAISED OMISSION BRACKET",
            "? SUBSTITUTION BRACKET",
            "? DOTTED SUBSTITUTION BRACKET",
            "? TRANSPOSITION BRACKET",
            [   "OGHAM FEATHER MARK",
                "OGHAM REVERSED FEATHER MARK",  ],
            [   "TIBETAN MARK GUG RTAGS GYON",
                "TIBETAN MARK GUG RTAGS GYAS",  ],
            [   "TIBETAN MARK ANG KHANG GYON",
                "TIBETAN MARK ANG KHANG GYAS",  ],
    ;

    #
    # Filter out unknown characters; this may run on an older version
    # of Perl with an old version of Unicode.
    #
    @bracket_pairs = grep {defined charnames::string_vianame ($$_ [0]) &&
                           defined charnames::string_vianame ($$_ [1])}
                     @bracket_pairs;

    if (@bracket_pairs) {
        my  $delims = join "" => map {charnames::string_vianame ($$_ [0])}
                                     @bracket_pairs;
        my $cdelims = join "" => map {charnames::string_vianame ($$_ [1])}
                                     @bracket_pairs;

        pattern name   => [qw (bquoted -esc=\\)],
                create => sub {my $flags = $_ [1];
                               return gen_delimited ($delims, $flags -> {-esc},
                                                    $cdelims);
                          },
                version => 5.014,
                ;
    }
}


#
# Return the Unicode names of the pairs of matching delimiters.
#
sub bracket_pairs {@bracket_pairs}

1;

__END__

=pod

=head1 NAME

Regexp::Common::delimited -- provides a regex for delimited strings

=head1 SYNOPSIS

    use Regexp::Common qw /delimited/;

    while (<>) {
        /$RE{delimited}{-delim=>'"'}/  and print 'a \" delimited string';
        /$RE{delimited}{-delim=>'/'}/  and print 'a \/ delimited string';
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{delimited}{-delim}{-cdelim}{-esc}>

Returns a pattern that matches a single-character-delimited substring,
with optional internal escaping of the delimiter.

When C<-delim => I<S>> is specified, each character in the sequence I<S> is
a possible delimiter. There is no default delimiter, so this flag must always
be specified.

By default, the closing delimiter is the same character as the opening
delimiter. If this is not wanted, for instance, if you want to match
a string with symmetric delimiters, you can specify the closing delimiter(s)
with C<-cdelim => I<S>>. Each character in I<S> is matched with the
corresponding character supplied with the C<-delim> option. If the C<-cdelim>
option has less characters than the C<-delim> option, the last character
is repeated as often as necessary. If the C<-cdelim> option has more 
characters than the C<-delim> option, the extra characters are ignored.

If C<-esc => I<S>> is specified, each character in the sequence I<S> is
the delimiter for the corresponding character in the C<-delim=I<S>> list.
The default escape is backslash.

For example:

   $RE{delimited}{-delim=>'"'}               # match "a \" delimited string"
   $RE{delimited}{-delim=>'"'}{-esc=>'"'}    # match "a "" delimited string"
   $RE{delimited}{-delim=>'/'}               # match /a \/ delimited string/
   $RE{delimited}{-delim=>q{'"}}             # match "string" or 'string'
   $RE{delimited}{-delim=>"("}{-cdelim=>")"} # match (string)

Under C<-keep> (See L<Regexp::Common>):

=over 4

=item $1

captures the entire match

=item $2

captures the opening delimiter

=item $3

captures delimited portion of the string

=item $4

captures the closing delimiter

=back

=head2 $RE{quoted}{-esc}

A synonym for C<< $RE {delimited} {-delim => q {'"`}} {...} >>.

=head2 $RE {bquoted} {-esc}

This is a pattern which matches delimited strings, where the delimiters
are a set of matching brackets. Currently, this comes 85 pairs. This
includes the 60 pairs of bidirection paired brackets, as listed
in L<< http://www.unicode.org/Public/UNIDATA/BidiBrackets.txt >>.

The other 25 pairs are the quotation marks, the double quotation
marks, the single and double pointing quoation marks, the heavy
single and double commas, 4 pairs of top-bottom parenthesis and
brackets, 9 pairs of presentation form for vertical brackets,
and the low paraphrase, raised omission, substitution, double
substitution, and transposition brackets.

In a future update, pairs may be added (or deleted).

This pattern requires perl 5.14.0 or higher.

For a full list of bracket pairs, inspect the output of 
C<< Regexp::Common::delimited::bracket_pair () >>, which returns
a list of two element arrays, each holding the Unicode names of
matching pair of delimiters.

The C<< {-esc => I<S> } >> works as in the C<< $RE {delimited} >> pattern.

If C<< {-keep} >> is given, the following things will be captured:

=over 4

=item $1

captures the entire match

=item $2

captures the opening delimiter

=item $3

captures delimited portion of the string

=item $4

captures the closing delimiter

=back

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2017, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
