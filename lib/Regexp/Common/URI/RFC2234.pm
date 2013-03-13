package Regexp::Common::URI::RFC2234;

use Regexp::Common qw /pattern clean no_defaults/;

use strict;
use warnings;

use vars qw /$VERSION/;
$VERSION = '2013031302';

use vars qw /@EXPORT @EXPORT_OK %EXPORT_TAGS @ISA/;

use Exporter ();
@ISA = qw /Exporter/;


my %vars;

BEGIN {
    $vars {core}    = [qw /$ALPHA $BIT $CHAR $CR $CRLF $CTL $DIGIT
                           $DQUOTE $HEXDIG $HTAB $LF $LWSP $OCTET
                           $SP $VCHAR $WSP/];
}

use vars map {@$_} values %vars;

@EXPORT      = ();
@EXPORT_OK   = map {@$_} values %vars;
%EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC 2234, core definitions.
$ALPHA       = '[A-Za-z]';
$BIT         = '[01]';
$CHAR        = "[\x01-\x7F]";       # All ASCII chars, except NUL
$CR          = "\x0D";              # Carriage Return
$LF          = "\x0A";              # Linefeed
$CRLF        = "(?:$CR$LF)";        # Carriage Return Line Feed
$CTL         = "[\x00-\x1F\x7F]";   # Controls
$DIGIT       = '[0-9]';
$DQUOTE      = '"';
$HEXDIG      = '[0-9A-F]';          # Hexadecimal digit
$HTAB        = "\x09";              # Vertical tab
$SP          = ' ';                 # Space
$WSP         = "[$SP$HTAB]";        # White space
$LWSP        = "(?:$CRLF?$WSP)*"    # Linear white space
$OCTET       = "[\x00-\xFF]";       # 8 Bits of data
$VCHAR       = "[\x21-\x7E]";       # Visible characters

1;

__END__

=pod

=head1 NAME

Regexp::Common::URI::RFC2234 -- Definitions from RFC2234;

=head1 SYNOPSIS

    use Regexp::Common::URI::RFC2234 qw /:ALL/;

=head1 DESCRIPTION

This package exports definitions from I<RFC 2234>. It's intended
usage is for Regexp::Common::URI submodules only. Its interface
might change without notice.

I<RFC 2234> was obsoleted by I<RFC 4234>, which in turn was
obsoleted by I<RFC 5234>, but they did not change the rules exported
by this module.

=head1 REFERENCES

=over 4

=item B<[RFC 2234]>

D. Crocker (Ed.), P. Overell:
I<Augmented BNF for Syntax Specifications: ABNF>, November 1997.

=item B<[RFC 4234]>

D. Crocker (Ed.), P. Overell:
I<Augmented BNF for Syntax Specifications: ABNF>, October 2005.

=item B<[RFC 5234]>

D. Crocker (Ed.), P. Overell:
I<Augmented BNF for Syntax Specifications: ABNF>, January 2008.

=back

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2013, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD Licence.               See the file COPYRIGHT.BSD.
 4) The MIT Licence.               See the file COPYRIGHT.MIT.

=cut
