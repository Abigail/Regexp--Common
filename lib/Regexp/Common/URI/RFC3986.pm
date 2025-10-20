package Regexp::Common::URI::RFC3986;

use Regexp::Common qw /pattern clean no_defaults/;

use strict;
use warnings;

our $VERSION = '2025102001';

use Exporter ();
our @ISA = qw /Exporter/;


my %vars;

BEGIN {
    $vars {low}     = [qw /$digit $upalpha $lowalpha $alpha $alphanum $hex $hexdig
                           $escaped $pct_encoded $mark $unreserved $sub_delims $reserved
                           $pchar $uric $urics $userinfo $userinfo_no_colon $uric_no_slash/];
    $vars {parts}   = [qw /$query $fragment $param $segment $segment_nz $segment_nz_nc
                           $path_abempty $path_absolute $path_noscheme $path_rootless
                           $path_empty $path_segments $ftp_segments $rel_segment
                           $abs_path $rel_path $path/];
    $vars {connect} = [qw /$port $dec_octet $IPv4address $hextet $ls32 $IPv6address
                           $IPvFuture $IP_literal $toplabel $domainlabel $hostname
                           $host $hostport $server $reg_name $authority/];
    $vars {URI}     = [qw /$scheme $net_path $opaque_part $hier_part $relative_part
                           $relativeURI $absoluteURI $relative_ref $URI_reference/];
    $vars {IDN}     = [qw /$IDN_DOT $ACE $IDN_U_LABEL $IDN_HOST/];
}

our @EXPORT      = ();
our @EXPORT_OK   = map {@$_} values %vars;
our %EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC3986, base definitions.
our $digit             =  '[0-9]';
our $upalpha           =  '[A-Z]';
our $lowalpha          =  '[a-z]';
our $alpha             =  '[a-zA-Z]';                # lowalpha | upalpha
our $alphanum          =  '[a-zA-Z0-9]';             # alpha    | digit
our $hexdig            =  '[a-fA-F0-9]';
our $hex               =  $hexdig;                   # RFC2396 compatibility alias
our $pct_encoded       =  "(?:\%$hexdig$hexdig)";     # pct-encoded
our $escaped           =  $pct_encoded;              # RFC2396 compatibility alias
# RFC3986 unreserved + sub-delims (ASCII)
our $unreserved        =  "[a-zA-Z0-9\\-_.~]";       # alphanum | mark
                          # %61-%7A, %41-%5A, %30-%39
                          #  a - z    A - Z    0 - 9
                          # %2D, %5F, %2E, %7E
                          #  -    _    .    ~
our $sub_delims        =  "[!\\\$&'\\(\\)\\*\\+,;=]";
our $reserved          =  "[;/?:@&=+\$,]";
our $pchar             =  "(?:$unreserved|$pct_encoded|$sub_delims|[:\@])";
                          # unreserved | pct-encoded / sub-delims / ":" / "@"
# Compatibility aliases to RFC2396’s uric/urics/uric_no_slash
our $mark              =  "[\\-_.!~*'()]";           # RFC2396 legacy
our $uric              =  "(?:[/?]|$pchar)";         # RFC2396 legacy superset
our $urics             =  "(?:(?:$uric)*)";          # RFC2396 legacy
our $uric_no_slash     =  "(?:$pchar|[?])";          # RFC2396 legacy

# query / fragment = *( pchar / "/" / "?" )
our $query             =  "(?:(?:$pchar|[/?])*)";
our $fragment          =  "(?:(?:$pchar|[/?])*)";
our $param             =  "(?:(?:[a-zA-Z0-9\\-_.!~*'():\@&=+\$,]+|$escaped)*)";
# Path productions (RFC3986 §3.3)
our $segment           =  "(?:$pchar*)";
our $segment_nz        =  "(?:$pchar+)";
our $segment_nz_nc     =  "(?:(?:$unreserved|$pct_encoded|$sub_delims|@)+)";

# RFC2396 names kept for compatibility
our $path_segments     =  "(?:$segment(?:/$segment)*)"; # RFC2396 legacy name
our $abs_path          =  "(?:/$path_segments)";        # RFC2396 legacy
our $ftp_segments      =  "(?:$param(?:/$param)*)";     # NOT from RFC 2396.
our $rel_segment       =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();\@&=+\$,]*|$escaped)+)"; # RFC2396 legacy
our $rel_path          =  "(?:$rel_segment(?:$abs_path)?)"; # RFC2396 legacy
our $path              =  "(?:(?:$abs_path|$rel_path)?)";   # RFC2396 legacy

# 3986 canonical forms
our $path_abempty      =  "(?:/$segment)*";
our $path_absolute     =  "(?:/(?:$segment_nz(?:/$segment)*)?)";
our $path_noscheme     =  "(?:$segment_nz_nc(?:/$segment)*)";
our $path_rootless     =  "(?:$segment_nz(?:/$segment)*)";
our $path_empty        =  "(?:)";

# RFC3986 §3.2.2 Host / Authority
# IPv4
our $dec_octet         =  "(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])";
our $IPv4address       =  "(?:$dec_octet\\.$dec_octet\\.$dec_octet\\.$dec_octet)";

# IPv6 (RFC3986 Appendix A)
our $hextet            =  "(?:(?:$hexdig){1,4})";
our $ls32              =  "(?:$hextet:$hextet|$IPv4address)";

# A faithful (and readable) IPv6address alternation set:
our $IPv6address = "(?:" .
    "(?:$hextet:){6}$ls32"                                  . '|' .
    "::(?:$hextet:){5}$ls32"                                . '|' .
    "(?:$hextet)?::(?:$hextet:){4}$ls32"                    . '|' .
    "(?:(?:$hextet:){0,2}$hextet)?::(?:$hextet:){3}$ls32"   . '|' .
    "(?:(?:$hextet:){0,3}$hextet)?::(?:$hextet:){2}$ls32"   . '|' .
    "(?:(?:$hextet:){0,4}$hextet)?::(?:$hextet:)$ls32"      . '|' .
    "(?:(?:$hextet:){0,5}$hextet)?::$ls32"                  . '|' .
    "(?:(?:$hextet:){0,7}$hextet)?::"                       .
")";

# IPvFuture = 'v' 1*HEXDIG '.' 1*( unreserved / sub-delims / ":" )
our $IPvFuture         =  "(?:v(?:$hexdig)+\\.(?:$unreserved|$sub_delims|:)+)";

# IP-literal = "[" ( IPv6address / IPvFuture ) "]"
our $IP_literal        =  "(?:\\[(?:$IPv6address|$IPvFuture)\\])";

# reg-name = *( unreserved / pct-encoded / sub-delims )
our $reg_name          =  "(?:(?:$unreserved|$pct_encoded|$sub_delims)*)";

# host = IP-literal / IPv4address / reg-name
our $host              =  "(?:$IP_literal|$IPv4address|$reg_name)";
our $port              =  "(?:$digit*)";

# userinfo = *( unreserved / pct-encoded / sub-delims / ":" )
our $userinfo          =  "(?:(?:$unreserved|$pct_encoded|$sub_delims|:)*)";
our $userinfo_no_colon =  "(?:(?:$unreserved|$pct_encoded|$sub_delims)*)";

# authority   = [ userinfo "@" ] host [ ":" port ]
our $authority         =  "(?:(?:$userinfo\@)?$host(?::$port)?)";

# legacy 2396 names kept (not used by 3986, but exported for compat)
our $toplabel          =  "(?:$alpha"."[-a-zA-Z0-9]*$alphanum|$alpha)";
our $domainlabel       =  "(?:(?:$alphanum"."[-a-zA-Z0-9]*)?$alphanum)";
our $hostname          =  "(?:(?:$domainlabel\[.])*$toplabel\[.]?)";    # RFC2396 legacy ASCII hostname
our $hostport          =  "(?:$host(?::$port)?)";                       # RFC2396 legacy
our $server            =  "(?:(?:$userinfo\@)?$hostport)";              # RFC2396 legacy

our $scheme            =  "(?:$alpha"."[a-zA-Z0-9+\\-.]*)";

our $net_path          =  "(?://$authority$abs_path?)";
our $opaque_part       =  "(?:$uric_no_slash$urics)";
# hier-part = ("//" authority path-abempty) / path-absolute / path-rootless / path-empty
our $hier_part         =  "(?:(?://$authority$path_abempty)|$path_absolute|$path_rootless|$path_empty)";
# relative-part = ("//" authority path-abempty) / path-absolute / path-noscheme / path-empty
our $relative_part     =  "(?:(?://$authority$path_abempty)|$path_absolute|$path_noscheme|$path_empty)";
# absolute-URI  = scheme ":" hier-part [ "?" query ]
our $absoluteURI       =  "(?:$scheme:$hier_part(?:\\?$query)?)";
# relative-ref  = relative-part [ "?" query ] [ "#" fragment ]
our $relative_ref      =  "(?:$relative_part(?:\\?$query)?(?:\\#$fragment)?)";
# URI-reference = URI / relative-ref
# (where URI      = scheme ":" hier-part [ "?" query ] [ "#" fragment ])
our $URI_reference     =  "(?:(?:$absoluteURI(?:\\#$fragment)?|$relative_ref))";
# legacy RFC2396 “relativeURI” (without fragment)
our $relativeURI       =  "(?:$relative_part(?:\\?$query)?)";

# Optional Unicode/IDN helpers (non-normative)
# Accept "." and the IDNA dot equivalents
our $IDN_DOT           = '[\.\x{3002}\x{FF0E}\x{FF61}]';

# ACE punycode prefix (case-insensitive)
our $ACE               = '(?i:xn--)';

# Unicode IDN label with ACE hyphen rule (≤63 chars)
our $IDN_U_LABEL       = join '',
    '(?:',
        '(?:', $ACE, '[\\p{L}\\p{N}\\p{M}\\p{Pc}-]{1,59})',
        '|',
        '(?![\\p{L}\\p{N}]{2}--)',   # forbid “--” at pos 3–4 unless ACE
        '[\\p{L}\\p{N}]',
        '[\\p{L}\\p{N}\\p{M}\\p{Pc}-]{0,61}',
        '(?<!-)',
    ')';

# Unicode IDN hostname: label *( DOT-equivalent label )
our $IDN_HOST          = "(?:$IDN_U_LABEL(?:$IDN_DOT$IDN_U_LABEL)*)";

1;

__END__

=pod

=encoding utf8

=head1 NAME

Regexp::Common::URI::RFC3986 -- Definitions from RFC3986;

=head1 SYNOPSIS

    use Regexp::Common::URI::RFC3986 qw /:ALL/;

=head1 DESCRIPTION

This package exports definitions from RFC 3986 (I<Uniform Resource
Identifier (URI): Generic Syntax>, Jan 2005). It supersedes the
older RFC 2396 forms. The exported variables mirror the structure
and naming of C<Regexp::Common::URI::RFC2396>, updated to the
RFC 3986 grammar (e.g. C<$unreserved>, C<$sub_delims>,
C<$pct_encoded>, C<$pchar>, the C<path_*> productions, and
C<$host> rules including C<IP-literal> with IPv6/IPvFuture).

For convenience and backwards compatibility, a few RFC 2396 names
(e.g. C<$mark>, C<$uric>, C<$urics>, C<$uric_no_slash>) remain
exported and are mapped to sensible RFC 3986 equivalents.

=head2 Optional Unicode/IDN

RFC 3986 is ASCII-only at the syntax level; internationalized host
names are to be represented as A-labels (punycode). For callers who
want to pre-validate Unicode host names before ACE conversion, we
also export the optional C<:IDN> helpers:

=over 4

=item * C<$IDN_DOT> - Recognizes C<.> and IDNA dot-equivalents.

=item * C<$ACE> - Case-insensitive C<xn--> prefix.

=item * C<$IDN_U_LABEL> - A single Unicode label (≤63 chars) with the ACE hyphen rule.

=item * C<$IDN_HOST> - One or more Unicode labels separated by C<$IDN_DOT>.

=back

These are I<non-normative> conveniences and are not used by the
RFC 3986 C<$host> production (which remains ASCII per the spec).

=head1 REFERENCES

=over 4

=item B<[RFC 3986]>

Berners-Lee, Tim, Fielding, R., and Masinter, L.: I<Uniform Resource
Identifiers (URI): Generic Syntax>. January 2005.

Superseding RFC2732, L<RFC2396|Regexp::Common::URI::RFC2396>, and L<RFC1808|Regexp::Common::URI::RFC1808>  

L<http://tools.ietf.org/html/rfc3986>

=back

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTENANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.freedom.nl>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2025, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD License.               See the file COPYRIGHT.BSD.
 4) The MIT License.               See the file COPYRIGHT.MIT.

=cut
