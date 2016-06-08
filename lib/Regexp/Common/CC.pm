package Regexp::Common::CC;

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common qw /pattern clean no_defaults/;
use Regexp::Common::_support qw /luhn/;

our $VERSION = '2016060801';

my @cards = (
    # Name           Prefix                    Length           mod 10
    [Mastercard   =>   '5[1-5]',                16,                1],
    [Visa         =>   '4',                     [13, 16],          1],
    [Amex         =>   '3[47]',                 15,                1],
   # Carte Blanche
   ['Diners Club' =>   '3(?:0[0-5]|[68])',      14,                1],
    [Discover     =>   '6011',                  16,                1],
    [enRoute      =>   '2(?:014|149)',          15,                0],
    [JCB          => [['3',                     16,                1],
                      ['2131|1800',             15,                1]]],
);


foreach my $card (@cards) {
    my ($name, $prefix, $length, $mod) = @$card;

    # Skip the harder ones for now.
    next if ref $prefix || ref $length;
    next unless $mod;

    my $times = $length + $mod;
    pattern name    => [CC => $name],
            create  => sub {
                use re 'eval';
                qr <((?=($prefix))[0-9]{$length})
                    (?(?{Regexp::Common::_support::luhn $1})|(?!))>x
            }
    ;
}




1;

__END__

=pod

=head1 NAME

Regexp::Common::CC -- provide patterns for credit card numbers.

=head1 SYNOPSIS

    use Regexp::Common qw /CC/;

    while (<>) {
        /^$RE{CC}{Mastercard}$/   and  print "Mastercard card number\n";
    }

=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

This module offers patterns for credit card numbers of several major
credit card types. Currently, the supported cards are: I<Mastercard>,
I<Amex>, I<Diners Club>, and I<Discover>.


=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=over 4

=item L<http://www.beachnet.com/~hstiles/cardtype.html>

Credit Card Validation - Check Digits 

=item L<http://euro.ecom.cmu.edu/resources/elibrary/everycc.htm>

Everything you ever wanted to know about CC's

=item L<http://www.webopedia.com/TERM/L/Luhn_formula.html>

Luhn formula

=back

=head1 AUTHORS

Damian Conway S<(I<damian@conway.org>)> and
Abigail S<(I<regexp-common@abigail.be>)>.

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty. Send them in to S<I<regexp-common@abigail.be>>.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2016, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
