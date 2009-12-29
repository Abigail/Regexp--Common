# $Id: whitespace.pm,v 2.105 2008/05/23 21:30:09 abigail Exp $

package Regexp::Common::whitespace;

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;
use vars qw /$VERSION/;

($VERSION) = q $Revision: 2.105 $ =~ /[\d.]+/g;

pattern name   => [qw (ws crop)],
        create => '(?:^\s+|\s+$)',
        subs   => sub {$_[1] =~ s/^\s+//; $_[1] =~ s/\s+$//;}
        ;


1;

__END__

=pod

=head1 NAME

Regexp::Common::whitespace -- provides a regex for leading or
trailing whitescape

=head1 SYNOPSIS

    use Regexp::Common qw /whitespace/;

    while (<>) {
        s/$RE{ws}{crop}//g;           # Delete surrounding whitespace
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.


=head2 C<$RE{ws}{crop}>

Returns a pattern that identifies leading or trailing whitespace.

For example:

        $str =~ s/$RE{ws}{crop}//g;     # Delete surrounding whitespace

The call:

        $RE{ws}{crop}->subs($str);

is optimized (but probably still slower than doing the s///g explicitly).

This pattern does not capture under C<-keep>.

=head1 HISTORY

 $Log: whitespace.pm,v $
 Revision 2.105  2008/05/23 21:30:09  abigail
 Changed email address

 Revision 2.104  2008/05/23 21:28:01  abigail
 Changed license

 Revision 2.103  2003/07/04 13:34:05  abigail
 Fixed assignment to

 Revision 2.102  2003/02/11 09:48:54  abigail
 Added

 Revision 2.101  2003/02/01 22:55:31  abigail
 Changed Copyright years

 Revision 2.100  2003/01/21 23:19:40  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.2  2002/08/27 16:59:39  abigail
 Fix POD

 Revision 1.1  2002/08/27 16:58:59  abigail
 Initial checkin.


=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

=head1 COPYRIGHT

This software is Copyright (c) 2001 - 2008, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD Licence.               See the file COPYRIGHT.BSD.
 4) The MIT Licence.               See the file COPYRIGHT.MIT.

=cut
