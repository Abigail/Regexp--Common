package Regexp::Common::net; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;

use vars qw /$VERSION/;

($VERSION) = q $Revision: 1.7 $ =~ /[\d.]+/g;

my %IPunit = (
    dec => q{(?k:25[0-5]|2[0-4]\d|[0-1]??\d{1,2})},
    oct => q{(?k:[0-3]??[0-7]{1,2})},
    hex => q{(?k:[0-9A-F]{1,2})},
    bin => q{(?k:[0-1]{1,8})},
);
my %MACunit = (
    %IPunit,
    hex => q{(?k:[0-9a-f]{1,2})},
);

sub dec {$_};
sub bin {oct "0b$_"}

my $IPdefsep  = '[.]';
my $MACdefsep =  ':';

pattern name   => [qw (net IPv4)],
        create => "(?k:$IPunit{dec}$IPdefsep$IPunit{dec}$IPdefsep" .
                      "$IPunit{dec}$IPdefsep$IPunit{dec})",
        ;

pattern name   => [qw (net MAC)],
        create => "(?k:" . join ($MACdefsep => ($MACunit{hex}) x 6) . ")",
        subs   => sub {
            $_ [1] = join ":" => map {sprintf "%02x" => hex}
                                 split /$MACdefsep/ => $_ [1]
                     if $_ [1] =~ /$_[0]/
        },
        ;

foreach my $type (qw /dec oct hex bin/) {
    pattern name   => [qw (net IPv4), $type, "-sep=$IPdefsep"],
            create => sub {my $sep = $_ [1] -> {-sep};
                           "(?k:$IPunit{$type}$sep$IPunit{$type}$sep" .
                               "$IPunit{$type}$sep$IPunit{$type})"
                      },
            ;

    pattern name   => [qw (net MAC), $type, "-sep=$MACdefsep"],
            create => sub {my $sep = $_ [1] -> {-sep};
                           "(?k:" . join ($sep => ($MACunit{$type}) x 6) . ")",
                      },
            subs   => sub {
                return if $] < 5.006 and $type eq 'bin';
                $_ [1] = join ":" => map {sprintf "%02x" => eval $type}
                                     $2, $3, $4, $5, $6, $7
                         if $_ [1] =~ $RE {net} {MAC} {$type}
                                          {-sep => $_ [0] -> {flags} {-sep}}
                                          {-keep};
            },
            ;

}

my $letter      =  "[A-Za-z]";
my $let_dig     =  "[A-Za-z0-9]";
my $let_dig_hyp = "[-A-Za-z0-9]";

# Domain names, from RFC 1035.
pattern name   => [qw (net domain)],
        create => "(?k: |(?:$letter(?:(?:$let_dig_hyp){0,61}$let_dig)?" .
                     "(?:\\.$letter(?:(?:$let_dig_hyp){0,61}$let_dig)?)*))",
        ;


}

1;

__END__

=head1 NAME

Regexp::Common::net -- provide regexes for IPv4 addresses.

=head1 SYNOPSIS

    use Regexp::Common qw /net/;

    while (<>) {
        /$RE{net}{IPv4}/       and print "Dotted decimal IP address";
        /$RE{net}{IPv4}{hex}/  and print "Dotted hexadecimal IP address";
        /$RE{net}{IPv4}{oct}{-sep => ':'}/ and
                               print "Colon separated octal IP address";
        /$RE{net}{IPv4}{bin}/  and print "Dotted binary IP address";
        /$RE{net}{MAC}/        and print "MAC address";
        /$RE{net}{MAC}{oct}{-sep => " "}/ and
                               print "Space separated octal MAC address";
    }

=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

This modules gives you regular expressions for various style IPv4 
and MAC (or ethernet) addresses.

=head2 C<$RE{net}{IPv4}>

Returns a pattern that matches a valid IP address in "dotted decimal"

For this pattern and the next four, under C<-keep> (See L<Regexp::Common>):

=over 4

=item $1

captures the entire match

=item $2

captures the first component of the address

=item $3

captures the second component of the address

=item $4

captures the third component of the address

=item $5

captures the final component of the address

=back

=head2 C<$RE{net}{IPv4}{dec}{-sep}>

Returns a pattern that matches a valid IP address in "dotted decimal"

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>. 

=head2 C<$RE{net}{IPv4}{hex}{-sep}>

Returns a pattern that matches a valid IP address in "dotted hexadecimal",
with the letters C<A> to C<F> capitalized.

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>. C<< -sep="" >> and
C<< -sep=" " >> are useful alternatives.

=head2 C<$RE{net}{IPv4}{oct}{-sep}>

Returns a pattern that matches a valid IP address in "dotted octal"

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>.

=head2 C<$RE{net}{IPv4}{bin}{-sep}>

Returns a pattern that matches a valid IP address in "dotted binary"

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>.

=head2 C<$RE{net}{MAC}>

Returns a pattern that matches a valid MAC or ethernet address as
colon separated hexadecimals.

For this pattern, and the next four, under C<-keep> (See L<Regexp::Common>):

=over 4

=item $1

captures the entire match

=item $2

captures the first component of the address

=item $3

captures the second component of the address

=item $4

captures the third component of the address

=item $5

captures the fourth component of the address

=item $6

captures the fifth component of the address

=item $7

captures the sixth and final component of the address

=back

This pattern, and the next four, have a C<subs> method as well, which
will transform a matching MAC address into so called canonical format.
Canonical format means that every component of the address will be
exactly two hexadecimals (with a leading zero if necessary), and the
components will be separated by a colon.

The C<subs> method will not work for binary MAC addresses if the
Perl version predates 5.6.0.

=head2 C<$RE{net}{MAC}{dec}{-sep}>

Returns a pattern that matches a valid MAC address as colon separated
decimals.

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/:/>. 

=head2 C<$RE{net}{MAC}{hex}{-sep}>

Returns a pattern that matches a valid MAC address as colon separated
hexadecimals, with the letters C<a> to C<f> in lower case.

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/:/>.

=head2 C<$RE{net}{MAC}{oct}{-sep}>

Returns a pattern that matches a valid MAC address as colon separated
octals.

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/:/>.

=head2 C<$RE{net}{MAC}{bin}{-sep}>

Returns a pattern that matches a valid MAC address as colon separated
binary numbers.

If C<< -sep=I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/:/>.

=head2 $RE{net}{domain}

Returns a pattern to match domains (and hosts) as defined in RFC 1035.
Under I{-keep} only the entire domain name is returned.

=head1 REFERENCES

=over 4

=item B<RFC 1035>

Mockapetris, P.: I<DOMAIN NAMES - IMPLEMENTATION AND SPECIFICATION>.
November 1987.

=back

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 HISTORY

    $Log: net.pm,v $
    Revision 1.7  2002/08/05 22:02:06  abigail
    Typo fix.

    Revision 1.6  2002/08/05 20:36:10  abigail
    Added $RE{net}{domain}


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
