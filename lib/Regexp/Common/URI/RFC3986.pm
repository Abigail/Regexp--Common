package Regexp::Common::URI::RFC3986;

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
    $vars { }       = [ ];
}

use vars map {@$_} values %vars;

@EXPORT      = ();
@EXPORT_OK   = map {@$_} values %vars;
%EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC 3968, base definitions.
$gen_delims  = '[]:/?#@[]';
$sub_delims  = '[!$&\'()*+,;=]';
$reserved    = '[]:/?#@[!$&\'()*+,;=]';     # gen_delims / sub_delims

1;

__END__

=pod

=head1 NAME

Regexp::Common::URI::RFC3968 -- Definitions from RFC3968;

=head1 SYNOPSIS

    use Regexp::Common::URI::RFC3968 qw /:ALL/;

=head1 DESCRIPTION

This package exports definitions from I<RFC 3968>. It's intended
usage is for Regexp::Common::URI submodules only. Its interface
might change without notice.

I<RFC 3968> obsoletes I<RFC 2396>.

=head1 REFERENCES

=over 4

=item B<[RFC 2396]>

Berners-Lee, Tim, Fielding, R., and Masinter, L.: I<Uniform Resource
Identifiers (URI): Generic Syntax>. August 1998.

=item B<[RFC 3968]>

Berners-Lee, T., Fielding, R., and Masinter, L.: I<Uniform Resource
Identifiers (URI): Generic Syntax>. January 2005.

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
