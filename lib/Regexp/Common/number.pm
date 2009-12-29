package Regexp::Common::number; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;
use Carp;

pattern name   => [qw (num int -sep=  -group=3)],
        create => sub {my $flag = $_[1];
                       my ($sep, $group) = @{$flag}{-sep, -group};
                       $sep = ',' if exists $flag->{-sep}
                                    && !defined $flag->{-sep};
                       return $sep 
                              ? qq {(?k:(?k:[+-]?)(?k:\\d{1,$group}} .
                                qq {(?:$sep\\d{$group})*))}
                              : qq {(?k:(?k:[+-]?)(?k:\\d+))}
                      }
        ;

sub real_creator { 
    my ($base, $places, $radix, $sep, $group, $expon) =
            @{$_[1]}{-base, -places, -radix, -sep, -group, -expon};
    croak "Base must be between 1 and 36"
           unless $base >= 1 && $base <= 36;
    $sep = ',' if exists $_[1]->{-sep}
               && !defined $_[1]->{-sep};
    if ($base > 14 && $expon =~ /^[Ee]$/) {$expon = 'G'}
    foreach ($radix, $sep, $expon) {$_ = "[$_]" if 1 == length}
    my $digits = substr (join ("", 0..9, "A".."Z"), 0, $base);
    return $sep
           ? qq {(?k:(?i)(?k:[+-]?)(?k:(?=[$digits]|$radix)}              .
             qq {(?k:[$digits]{1,$group}(?:(?:$sep)[$digits]{$group})*)}  .
             qq {(?:(?k:$radix)(?k:[$digits]{$places}))?)}                .
             qq {(?:(?k:$expon)(?k:(?k:[+-]?)(?k:[$digits]+))|))}
           : qq {(?k:(?i)(?k:[+-]?)(?k:(?=[$digits]|$radix)}              .
             qq {(?k:[$digits]*)(?:(?k:$radix)(?k:[$digits]{$places}))?)} .
             qq {(?:(?k:$expon)(?k:(?k:[+-]?)(?k:[$digits]+))|))};
}


pattern name   => [qw (num real -base=10), '-places=0,',
                   qw (-radix=[.] -sep= -group=3 -expon=E)],
        create => \&real_creator,
        ;

sub real_synonym {
    my ($name, $base) = @_;
    pattern name   => ['num', $name, '-places=0,', '-radix=[.]',
                       '-sep=', '-group=3', '-expon=E'],
            create => sub {my %flags = (%{$_[1]}, -base => $base);
                           real_creator (undef, \%flags);
                      }
            ;
}


real_synonym (hex => 16);
real_synonym (dec => 10);
real_synonym (oct =>  8);
real_synonym (bin =>  2);


pattern name    => [qw (num square)],
        create  => sub {
            use re 'eval';
            qr {(\d+)(?(?{sqrt ($^N) == int sqrt ($^N)})|(?!X)X)}
        },
        version => 5.008;
        ;

pattern name    => [qw (num roman)],
        create  => '(?xi)(?=[MDCLXVI])
                         (?k:M{0,3}
                            (D?C{0,3}|CD|CM)?
                            (L?X{0,3}|XL|XC)?
                            (V?I{0,3}|IV|IX)?)'
        ;

}

1;

__END__

=pod

=head1 NAME

Regexp::Common::number -- provide regexes for numbers

=head1 SYNOPSIS

    use Regexp::Common qw /number/;

    while (<>) {
        /^$RE{num}{int}$/                and  print "Integer\n";
        /^$RE{num}{real}$/               and  print "Real\n";
        /^$RE{num}{real}{-base => 16}$/  and  print "Hexadecimal real\n";
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{num}{int}{-sep}{-group}>

Returns a pattern that matches a decimal integer.

If C<-sep=I<P>> is specified, the pattern I<P> is required as a grouping marker
within the number.

If C<-group=I<N>> is specified, digits between grouping markers must be
grouped in sequences of exactly I<N> characters. The default value of I<N> is 3.

For example:

 $RE{num}{int}                          # match 1234567
 $RE{num}{int}{-sep=>','}               # match 1,234,567
 $RE{num}{int}{-sep=>',?'}              # match 1234567 or 1,234,567
 $RE{num}{int}{-sep=>'.'}{-group=>4}    # match 1.2345.6789

Under C<-keep> (see L<Regexp::Common>):

=over 4

=item $1

captures the entire number

=item $2

captures the optional sign of the number

=item $3

captures the complete set of digits

=back

=head2 C<$RE{num}{real}{-base}{-radix}{-places}{-sep}{-group}{-expon}>

Returns a pattern that matches a floating-point number.

If C<-base=I<N>> is specified, the number is assumed to be in that base
(with A..Z representing the digits for 11..36). By default, the base is 10.

If C<-radix=I<P>> is specified, the pattern I<P> is used as the radix point for
the number (i.e. the "decimal point" in base 10). The default is C<qr/[.]/>.

If C<-places=I<N>> is specified, the number is assumed to have exactly
I<N> places after the radix point.
If C<-places=I<M,N>> is specified, the number is assumed to have between
I<M> and I<N> places after the radix point.
By default, the number of places is unrestricted.

If C<-sep=I<P>> specified, the pattern I<P> is required as a grouping marker
within the pre-radix section of the number. By default, no separator is
allowed.

If C<-group=I<N>> is specified, digits between grouping separators
must be grouped in sequences of exactly I<N> characters. The default value of
I<N> is 3.

If C<-expon=I<P>> is specified, the pattern I<P> is used as the exponential
marker.  The default value of I<P> is C<qr/[Ee]/>.

For example:

 $RE{num}{real}                  # matches 123.456 or -0.1234567
 $RE{num}{real}{-places=>2}      # matches 123.45 or -0.12
 $RE{num}{real}{-places=>'0,3'}  # matches 123.456 or 0 or 9.8
 $RE{num}{real}{-sep=>'[,.]?'}   # matches 123,456 or 123.456
 $RE{num}{real}{-base=>3'}       # matches 121.102

Under C<-keep>:

=over 4

=item $1

captures the entire match

=item $2

captures the optional sign of the number

=item $3

captures the complete mantissa

=item $4

captures the whole number portion of the mantissa

=item $5

captures the radix point

=item $6

captures the fractional portion of the mantissa

=item $7

captures the optional exponent marker

=item $8

captures the entire exponent value

=item $9

captures the optional sign of the exponent

=item $10

captures the digits of the exponent

=back

=head2 C<$RE{num}{dec}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<< $RE{num}{real}{-base=>10}{...} >>

=head2 C<$RE{num}{oct}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<< $RE{num}{real}{-base=>8}{...} >>

=head2 C<$RE{num}{bin}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<< $RE{num}{real}{-base=>2}{...} >>

=head2 C<$RE{num}{hex}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<< $RE{num}{real}{-base=>16}{...} >>

=head2 C<$RE{num}{square}>

Returns a pattern that matches a (decimal) square. Regardless whether
C<-keep> was set, the matched number will be returned in C<$1>.

This pattern is available for version 5.008 and up.

=head2 C<$RE{num}{roman}>

Returns a pattern that matches an integer written in Roman numbers.
Case doesn't matter. Only the more modern style, that is, no more
than three repetitions of a letter, is recognized. The largest number
matched is I<MMMCMXCIX>, or 3999. Larger numbers cannot be expressed
using ASCII characters. A future version will be able to deal with 
the Unicode symbols to match larger Roman numbers.

Under C<-keep>, the number will be captured in $1.

=head1 HISTORY

 $Log: number.pm,v $
 Revision 1.6  2002/12/27 23:33:15  abigail
 Roman numbers.

 Revision 1.5  2002/08/23 13:09:13  abigail
 Cosmetic POD changes.

 Revision 1.4  2002/08/23 12:51:26  abigail
 + Several occurances of 'numbers' changed to 'number'.
 + Fixed bugs in documentation.
 + Made example use anchors to make it more clear.
  (All due to Christopher Baker)

 Revision 1.3  2002/08/05 12:16:59  abigail
 Fixed 'Regex::' and 'Rexexp::' typos to 'Regexp::'
 (Found by Mike Castle).

 Revision 1.2  2002/07/30 16:37:59  abigail
 Removed outcommented code.

 Revision 1.1  2002/07/28 21:41:07  abigail
 Split off from Regexp::Common.

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
