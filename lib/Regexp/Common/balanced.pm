package Regexp::Common::balanced; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;
use re 'eval';

my %closer = ( '{'=>'}', '('=>')', '['=>']', '<'=>'>' );
sub balanced {
   my ($r,$p,$ap,$k) = @_;
   $r = "(??{\$Regexp::Common::$r})";
   return if $] < 5.006;
   return $k
        ? qr/(?:[$p]((?:(?>[^$ap]+)|$r)*)[$closer{$p}])/
        : qr/(?:[$p](?:(?>[^$ap]+)|$r)*[$closer{$p}])/
}


pattern name    => [qw( balanced -parens=() )],
        create  => sub {my $flag = $_[1];
                        my @parens = grep {index ($flag->{-parens}, $_) >= 0}
                                     ('[','(','{','<');
                        my $parens = join "", map "$closer{$_}$_", @parens;
                        my $sig = "SIG" . join "", @parens;
                        $sig =~ tr/[({</1234/;
                        my $pat = qr/(?!)/;
                        my $keep = exists $flag->{-keep};
                        foreach (@parens) {
                            my $add = balanced("parens{$sig}", $_,
                                               $parens, $keep);
                            $pat = qr/$add|$pat/;
                        }
                        $pat = $keep ? qr/($pat)/ : $pat;
                        $Regexp::Common::parens{$sig} = $pat;
                   },
        version => 5.006,
        ;


}

1;

__END__

=pod

=head1 NAME

Regexp::Common::balanced -- provide regexes for strings with balanced
parenthesized delimiters.

=head1 SYNOPSIS

    use Regexp::Common qw /balanced/;

    while (<>) {
        /$RE{balanced}{-parens=>'()'}/
                                   and print q{balanced parentheses\n};
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{balanced}{-parens}>

Returns a pattern that matches a string that starts with the nominated
opening parenthesis or bracket, contains characters and properly nested
parenthesized subsequences, and ends in the matching parenthesis.

More than one type of parenthesis can be specified:

        $RE{balanced}{-parens=>'(){}'}

in which case all specified parenthesis types must be correctly balanced within
the string.

If we are using C{-keep} (See L<Regexp::Common>):

=over 4

=item $1

captures the entire expression

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
