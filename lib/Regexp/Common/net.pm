package Regexp::Common::net; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;

my %IPunit = (
    dec => q{(?k:25[0-5]|2[0-4]\d|[0-1]??\d{1,2})},
    oct => q{(?k:[0-3]??[0-7]{1,2})},
    hex => q{(?k:[0-9A-F]{1,2})},
    bin => q{(?k:[0-1]{1,8})},
);

my $defsep = '[.]';

pattern name   => [qw (net IPv4)],
        create => "(?k:$IPunit{dec}$defsep$IPunit{dec}$defsep" .
                      "$IPunit{dec}$defsep$IPunit{dec})",
        ;

pattern name   => [qw (net IPv4 dec), "-sep=$defsep"],
        create => sub {my $sep = $_[1]->{-sep};
                       "(?k:$IPunit{dec}$sep$IPunit{dec}$sep" .
                           "$IPunit{dec}$sep$IPunit{dec})",
                      },
        ;

pattern name   => [qw (net IPv4 oct), "-sep=$defsep"],
        create => sub {my $sep = $_[1]->{-sep};
                       "(?k:$IPunit{oct}$sep$IPunit{oct}$sep" .
                           "$IPunit{oct}$sep$IPunit{oct})",
                      },
        ;
use Carp;
pattern name   => [qw (net IPv4 hex), "-sep=$defsep"],
        create => sub {my $sep = $_[1]->{-sep};
                       confess unless defined $sep;
                       "(?k:$IPunit{hex}$sep$IPunit{hex}$sep" .
                           "$IPunit{hex}$sep$IPunit{hex})",
                      },
        ;
pattern name   => [qw (net IPv4 bin), "-sep=$defsep"],
        create => sub {my $sep = $_[1]->{-sep};
                       "(?k:$IPunit{bin}$sep$IPunit{bin}$sep" .
                           "$IPunit{bin}$sep$IPunit{bin})",
                      },
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
    }

=head1 DESCRIPTION

Please consult the manual of L<Regex::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regex::Common>.

This modules gives you regular expressions for various style IPv4 addresses.

=over 4

=item C<$RE{net}{IPv4}>

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

=item C<$RE{net}{IPv4}{dec}{-sep}>

Returns a pattern that matches a valid IP address in "dotted decimal"

If C<< -sep=>I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>. 

=item C<$RE{net}{IPv4}{hex}{-sep}>

Returns a pattern that matches a valid IP address in "dotted hexadecimal"

If C<< -sep=>I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>. C<< -sep=>"" >> and
C<< -sep=>" " >> are useful alternatives.

=item C<$RE{net}{IPv4}{oct}{-sep}>

Returns a pattern that matches a valid IP address in "dotted octal"

If C<< -sep=>I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>.

=item C<$RE{net}{IPv4}{bin}{-sep}>

Returns a pattern that matches a valid IP address in "dotted binary"

If C<< -sep=>I<P> >> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>.

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
