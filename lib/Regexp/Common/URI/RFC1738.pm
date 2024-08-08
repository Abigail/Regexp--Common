package Regexp::Common::URI::RFC1738;

use Regexp::Common qw /pattern clean no_defaults/;

use strict;
use warnings;

our $VERSION = '2024080801';

use Exporter ();
our @ISA = qw /Exporter/;

my %vars;

BEGIN {
    $vars {low}     = [qw /$digit $digits $hialpha $lowalpha $alpha $alphadigit
                           $safe $extra $national $punctuation $unreserved
                           $unreserved_range $reserved $uchar $uchars $xchar
                           $xchars $hex $escape/];

    $vars {connect} = [qw /$port $hostnumber $toplabel $domainlabel $hostname
                           $host $hostport $user $password $login/];

    $vars {parts}   = [qw /$fsegment $fpath $group $article $grouppart
                           $search $database $wtype $wpath $psegment
                           $fieldname $fieldvalue $fieldspec $ppath/];
}


our @EXPORT      = qw /$host/;
our @EXPORT_OK   = map {@$_} values %vars;
our %EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC 1738, base definitions.

# Lowlevel definitions.
our $digit             =  '[0-9]';
our $digits            =  '[0-9]+';
our $hialpha           =  '[A-Z]';
our $lowalpha          =  '[a-z]';
our $alpha             =  '[a-zA-Z]';                 # lowalpha | hialpha
our $alphadigit        =  '[a-zA-Z0-9]';              # alpha    | digit
our $safe              =  '[-$_.+]';
our $extra             =  "[!*'(),]";
our $national          =  '[][{}|\\^~`]';
our $punctuation       =  '[<>#%"]';
our $unreserved_range  = q [-a-zA-Z0-9$_.+!*'(),];  # alphadigit | safe | extra
our $unreserved        =  "[$unreserved_range]";
our $reserved          =  '[;/?:@&=]';
our $hex               =  '[a-fA-F0-9]';
our $escape            =  "(?:%$hex$hex)";
our $uchar             =  "(?:$unreserved|$escape)";
our $uchars            =  "(?:(?:$unreserved|$escape)*)";
our $xchar             =  "(?:[$unreserved_range;/?:\@&=]|$escape)";
our $xchars            =  "(?:(?:[$unreserved_range;/?:\@&=]|$escape)*)";

# Connection related stuff.
our $port              =  "(?:$digits)";
our $hostnumber        =  "(?:$digits\[.]$digits\[.]$digits\[.]$digits)";
our $toplabel          =  "(?:$alpha\[-a-zA-Z0-9]*$alphadigit|$alpha)";
our $domainlabel       =  "(?:(?:$alphadigit\[-a-zA-Z0-9]*)?$alphadigit)";
our $hostname          =  "(?:(?:$domainlabel\[.])*$toplabel)";
our $host              =  "(?:$hostname|$hostnumber)";
our $hostport          =  "(?:$host(?::$port)?)";

our $user              =  "(?:(?:[$unreserved_range;?&=]|$escape)*)";
our $password          =  "(?:(?:[$unreserved_range;?&=]|$escape)*)";
our $login             =  "(?:(?:$user(?::$password)?\@)?$hostport)";

# Parts (might require more if we add more URIs).

# FTP/file
our $fsegment          =  "(?:(?:[$unreserved_range:\@&=]|$escape)*)";
our $fpath             =  "(?:$fsegment(?:/$fsegment)*)";

# NNTP/news.
our $group             =  "(?:$alpha\[-A-Za-z0-9.+_]*)";
our $article           =  "(?:(?:[$unreserved_range;/?:&=]|$escape)+" .
                          '@' . "$host)";
our $grouppart         =  "(?:[*]|$article|$group)"; # It's important that
                                                     # $article goes before
                                                     # $group.

# WAIS.
our $search            =  "(?:(?:[$unreserved_range;:\@&=]|$escape)*)";
our $database          =  $uchars;
our $wtype             =  $uchars;
our $wpath             =  $uchars;

# prospero
our $psegment          =  "(?:(?:[$unreserved_range?:\@&=]|$escape)*)";
our $fieldname         =  "(?:(?:[$unreserved_range?:\@&]|$escape)*)";
our $fieldvalue        =  "(?:(?:[$unreserved_range?:\@&]|$escape)*)";
our $fieldspec         =  "(?:;$fieldname=$fieldvalue)";
our $ppath             =  "(?:$psegment(?:/$psegment)*)";

#
# The various '(?:(?:[$unreserved_range ...]|$escape)*)' above need
# some loop unrolling to speed up the match.
#

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

=head1 AUTHOR

Abigail S<(I<regexp-common@abigail.freedom.nl>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2024, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
