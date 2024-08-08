package Regexp::Common::URI::RFC2396;

use Regexp::Common qw /pattern clean no_defaults/;

use strict;
use warnings;

our $VERSION = '2024080801';

use Exporter ();
our @ISA = qw /Exporter/;


my %vars;

BEGIN {
    $vars {low}     = [qw /$digit $upalpha $lowalpha $alpha $alphanum $hex
                           $escaped $mark $unreserved $reserved $pchar $uric
                           $urics $userinfo $userinfo_no_colon $uric_no_slash/];
    $vars {parts}   = [qw /$query $fragment $param $segment $path_segments
                           $ftp_segments $rel_segment $abs_path $rel_path
                           $path/];
    $vars {connect} = [qw /$port $IPv4address $toplabel $domainlabel $hostname
                           $host $hostport $server $reg_name $authority/];
    $vars {URI}     = [qw /$scheme $net_path $opaque_part $hier_part
                           $relativeURI $absoluteURI $URI_reference/];
}

our @EXPORT      = ();
our @EXPORT_OK   = map {@$_} values %vars;
our %EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC 2396, base definitions.
our $digit             =  '[0-9]';
our $upalpha           =  '[A-Z]';
our $lowalpha          =  '[a-z]';
our $alpha             =  '[a-zA-Z]';                # lowalpha | upalpha
our $alphanum          =  '[a-zA-Z0-9]';             # alpha    | digit
our $hex               =  '[a-fA-F0-9]';
our $escaped           =  "(?:%$hex$hex)";
our $mark              =  "[\\-_.!~*'()]";
our $unreserved        =  "[a-zA-Z0-9\\-_.!~*'()]";  # alphanum | mark
                          # %61-%7A, %41-%5A, %30-%39
                          #  a - z    A - Z    0 - 9
                          # %21, %27, %28, %29, %2A, %2D, %2E, %5F, %7E
                          #  !    '    (    )    *    -    .    _    ~
our $reserved          =  "[;/?:@&=+\$,]";
our $pchar             =  "(?:[a-zA-Z0-9\\-_.!~*'():\@&=+\$,]|$escaped)";
                                          # unreserved | escaped | [:@&=+$,]
our $uric              =  "(?:[;/?:\@&=+\$,a-zA-Z0-9\\-_.!~*'()]|$escaped)";
                                          # reserved | unreserved | escaped
our $urics             =  "(?:(?:[;/?:\@&=+\$,a-zA-Z0-9\\-_.!~*'()]+|"     .
                          "$escaped)*)";

our $query             =  $urics;
our $fragment          =  $urics;
our $param             =  "(?:(?:[a-zA-Z0-9\\-_.!~*'():\@&=+\$,]+|$escaped)*)";
our $segment           =  "(?:$param(?:;$param)*)";
our $path_segments     =  "(?:$segment(?:/$segment)*)";
our $ftp_segments      =  "(?:$param(?:/$param)*)";   # NOT from RFC 2396.
our $rel_segment       =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();\@&=+\$,]*|$escaped)+)";
our $abs_path          =  "(?:/$path_segments)";
our $rel_path          =  "(?:$rel_segment(?:$abs_path)?)";
our $path              =  "(?:(?:$abs_path|$rel_path)?)";

our $port              =  "(?:$digit*)";
our $IPv4address       =  "(?:$digit+[.]$digit+[.]$digit+[.]$digit+)";
our $toplabel          =  "(?:$alpha"."[-a-zA-Z0-9]*$alphanum|$alpha)";
our $domainlabel       =  "(?:(?:$alphanum"."[-a-zA-Z0-9]*)?$alphanum)";
our $hostname          =  "(?:(?:$domainlabel\[.])*$toplabel\[.]?)";
our $host              =  "(?:$hostname|$IPv4address)";
our $hostport          =  "(?:$host(?::$port)?)";

our $userinfo          =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();:&=+\$,]+|$escaped)*)";
our $userinfo_no_colon =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();&=+\$,]+|$escaped)*)";
our $server            =  "(?:(?:$userinfo\@)?$hostport)";

our $reg_name          =  "(?:(?:[a-zA-Z0-9\\-_.!~*'()\$,;:\@&=+]*|$escaped)+)";
our $authority         =  "(?:$server|$reg_name)";

our $scheme            =  "(?:$alpha"."[a-zA-Z0-9+\\-.]*)";

our $net_path          =  "(?://$authority$abs_path?)";
our $uric_no_slash     =  "(?:[a-zA-Z0-9\\-_.!~*'();?:\@&=+\$,]|$escaped)";
our $opaque_part       =  "(?:$uric_no_slash$urics)";
our $hier_part         =  "(?:(?:$net_path|$abs_path)(?:[?]$query)?)";

our $relativeURI       =  "(?:(?:$net_path|$abs_path|$rel_path)(?:[?]$query)?";
our $absoluteURI       =  "(?:$scheme:(?:$hier_part|$opaque_part))";
our $URI_reference     =  "(?:(?:$absoluteURI|$relativeURI)?(?:#$fragment)?)";

1;

__END__

=pod

=head1 NAME

Regexp::Common::URI::RFC2396 -- Definitions from RFC2396;

=head1 SYNOPSIS

    use Regexp::Common::URI::RFC2396 qw /:ALL/;

=head1 DESCRIPTION

This package exports definitions from RFC2396. It's intended
usage is for Regexp::Common::URI submodules only. Its interface
might change without notice.

=head1 REFERENCES

=over 4

=item B<[RFC 2396]>

Berners-Lee, Tim, Fielding, R., and Masinter, L.: I<Uniform Resource
Identifiers (URI): Generic Syntax>. August 1998.

=back

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.freedom.nl>)>.

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
