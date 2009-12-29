# $Id: RFC1738.pm,v 2.100 2003/02/10 21:03:54 abigail Exp $

package Regexp::Common::URI::RFC1738;

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;

use vars qw /$VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS @ISA/;

use Exporter ();
@ISA = qw /Exporter/;

($VERSION) = q $Revision: 2.100 $ =~ /[\d.]+/g;

my %vars;

BEGIN {
    $vars {low}     = [qw /$digit $digits $hialpha $lowalpha $alpha $alphadigit
                           $safe $extra $national $punctuation $unreserved
                           $reserved $uchar $uchars $xchar $xchars $hex
                           $escaped/];
    $vars {connect} = [qw /$port $hostnumber $toplabel $domainlabel $hostname
                           $host $hostport $user $password $login/];
    $vars {parts}   = [qw /$fsegment $fpath/];
}

use vars map {@$_} values %vars;

@EXPORT      = qw /$host/;
@EXPORT_OK   = map {@$_} values %vars;
%EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC 1738, base definitions.

# Lowlevel definitions.
$digit             =  '[0-9]';
$digits            =  '[0-9]+';
$hialpha           =  '[A-Z]';
$lowalpha          =  '[a-z]';
$alpha             =  '[a-zA-Z]';                 # lowalpha | hialpha
$alphadigit        =  '[a-zA-Z0-9]';              # alpha    | digit
$safe              =  '[-$_.+]';
$extra             =  "[!*'(),]";
$national          =  '[][{}|\\^~`]';
$punctuation       =  '[<>#%"]';
$unreserved        =  "[a-zA-Z0-9\\-\$_.+!*'(),]"; # alphadigit | safe | extra
$reserved          =  '[;/?:@&=]';
$hex               =  '[a-fA-F0-9]';
$escaped           =  "(?:%$hex$hex)";
$uchar             =  "(?:$unreserved|$escaped)";
$uchars            =  "(?:(?:$unreserved+|$escaped)*)";
$xchar             =  "(?:[a-zA-Z0-9\\-\$_.+!*'(),;/?:\@&=]|$escaped)";
$xchars            =  "(?:(?:[a-zA-Z0-9\\-\$_.+!*'(),;/?:\@&=]+|$escaped)*)";

# Connection related stuff.
$port              =  "(?:$digits)";
$hostnumber        =  "(?:$digits\[.]$digits\[.]$digits\[.]$digits)";
$toplabel          =  "(?:$alpha\[-a-zA-Z0-9]*$alphadigit|$alpha)";
$domainlabel       =  "(?:(?:$alphadigit\[-a-zA-Z0-9]*)?$alphadigit)";
$hostname          =  "(?:(?:$domainlabel\[.])*$toplabel)";
$host              =  "(?:$hostname|$hostnumber)";
$hostport          =  "(?:$host(?::$port)?)";

$user              =  "(?:(?:[a-zA-Z0-9\\-\$_.+!*'(),;?&=]+|$escaped)*)";
$password          =  "(?:(?:[a-zA-Z0-9\\-\$_.+!*'(),;?&=]+|$escaped)*)";
$login             =  "(?:(?:$user(?::$password)?\@)?$hostport)";

# Parts (might require more if we add more URIs).
$fsegment          =  "(?:(?:[a-zA-Z0-9\\-\$_.+!*'(),:\@&=]+|$escaped)*)";
$fpath             =  "(?:$fsegment(?:/$fsegment)*)";


1;

__END__

=pod

=head1 NAME

Regexp::Common::URI::RFC1738 -- Definitions from RFC1738;

=head1 SYNOPSIS

    use Regexp::Common::URI::RFC1738 qw /:ALL/;

=head1 DESCRIPTION

This package exports definitions from RFC1738. It's intended
usage is for Regexp::Common::URI submodules only. Its interface
might change without notice.

=head1 REFERENCES

=over 4

=item B<[RFC 1738]>

Berners-Lee, Tim, Masinter, L., McCahill, M.: I<Uniform Resource
Locators (URL)>. December 1994.

=back

=head1 HISTORY

 $Log: RFC1738.pm,v $
 Revision 2.100  2003/02/10 21:03:54  abigail
 Definitions of RFC 1738


=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.nl>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

=head1 COPYRIGHT

     Copyright (c) 2001 - 2003, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)

=cut
