# $Id: URI.pm,v 2.102 2003/02/07 15:24:17 abigail Exp $

package Regexp::Common::URI; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;

use vars qw /$VERSION/;

($VERSION) = q $Revision: 2.102 $ =~ /[\d.]+/g;

# RFC 2396, base definitions.
my $digit             =  '[0-9]';
my $upalpha           =  '[A-Z]';
my $lowalpha          =  '[a-z]';
my $alpha             =  '[a-zA-Z]';                # lowalpha | upalpha
my $alphanum          =  '[a-zA-Z0-9]';             # alpha    | digit
my $hex               =  '[a-fA-F0-9]';
my $escaped           =  "(?:%$hex$hex)";
my $mark              =  "[\\-_.!~*'()]";
my $unreserved        =  "[a-zA-Z0-9\\-_.!~*'()]";  # alphanum | mark
                         # %61-%7A, %41-%5A, %30-%39
                         #  a - z    A - Z    0 - 9
                         # %21, %27, %28, %29, %2A, %2D, %2E, %5F, %7E
                         #  !    '    (    )    *    -    .    _    ~
my $reserved          =  "[;/?:@&=+\$,]";
my $pchar             =  "(?:[a-zA-Z0-9\\-_.!~*'():\@&=+\$,]|$escaped)";
                                         # unreserved | escaped | [:@&=+$,]
my $uric              =  "(?:[;/?:\@&=+\$,a-zA-Z0-9\\-_.!~*'()]|$escaped)";
                                         # reserved | unreserved | escaped
my $urics             =  "(?:(?:[;/?:\@&=+\$,a-zA-Z0-9\\-_.!~*'()]+|"     .
                         "$escaped)*)";

my $query             =  $urics;
my $fragment          =  $urics;
my $param             =  "(?:(?:[a-zA-Z0-9\\-_.!~*'():\@&=+\$,]+|$escaped)*)";
my $segment           =  "(?:$param(?:;$param)*)";
my $path_segments     =  "(?:$segment(?:/$segment)*)";
my $ftp_segments      =  "(?:$param(?:/$param)*)";   # NOT from RFC 2396.
my $rel_segment       =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();\@&=+\$,]*|$escaped)+)";
my $abs_path          =  "(?:/$path_segments)";
my $rel_path          =  "(?:$rel_segment(?:$abs_path)?)";
my $path              =  "(?:(?:$abs_path|$rel_path)?)";

my $port              =  "(?:$digit*)";
my $IPv4address       =  "(?:$digit+[.]$digit+[.]$digit+[.]$digit+)";
my $toplabel          =  "(?:$alpha"."[-a-zA-Z0-9]*$alphanum|$alpha)";
my $domainlabel       =  "(?:(?:$alphanum"."[-a-zA-Z0-9]*)?$alphanum)";
my $hostname          =  "(?:(?:$domainlabel\[.])*$toplabel\[.]?)";
my $host              =  "(?:$hostname|$IPv4address)";
my $hostport          =  "(?:$host(?::$port)?)";

my $userinfo          =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();:&=+\$,]+|$escaped)*)";
my $userinfo_no_colon =  "(?:(?:[a-zA-Z0-9\\-_.!~*'();&=+\$,]+|$escaped)*)";
my $server            =  "(?:(?:$userinfo\@)?$hostport)";

my $reg_name          =  "(?:(?:[a-zA-Z0-9\\-_.!~*'()\$,;:\@&=+]*|$escaped)+)";
my $authority         =  "(?:$server|$reg_name)";

my $scheme            =  "(?:$alpha"."[a-zA-Z0-9+\\-.]*)";

my $net_path          =  "(?://$authority$abs_path?)";
my $uric_no_slash     =  "(?:[a-zA-Z0-9\\-_.!~*'();?:\@&=+\$,]|$escaped)";
my $opaque_part       =  "(?:$uric_no_slash$urics)";
my $hier_part         =  "(?:(?:$net_path|$abs_path)(?:[?]$query)?)";

my $relativeURI       =  "(?:(?:$net_path|$abs_path|$rel_path)(?:[?]$query)?";
my $absoluteURI       =  "(?:$scheme:(?:$hier_part|$opaque_part))";
my $URI_reference     =  "(?:(?:$absoluteURI|$relativeURI)?(?:#$fragment)?)";

# Base definitions from 1738 which are not defined above.
# Definitions from 1738 who have been redefined differently in 
# RFC 2396 will have _1738 tagged to the name.
my $safe_1738         =  "(?:[-\$_.+])";
my $extra_1738        =  "(?:[!*'(),])";
my $unreserved_1738   =  "(?:[a-zA-Z0-9\\-\$_.+!*'(),])";  # alpha | digit |
                                                           # safe | extra
my $uchar_1738        =  "(?:$unreserved|$escaped)";
my $uchars_1738       =  "(?:(?:$unreserved+|$escaped)*)";

                         # *[ uchar | ";" | "?" | "&" | "=" ]
my $user              =  "(?:(?:[;?&=a-zA-Z0-9\\-\$_.+!*'(),]+|$escaped)*)";
my $password          =  "(?:(?:[;?&=a-zA-Z0-9\\-\$_.+!*'(),]+|$escaped)*)";
my $login             =  "(?:(?:$user(?::$password)\@)?$hostport)";


# The defined schemes, collect them in a hash.
my %uri;

# HTTP: See RFC 2396 for generic syntax, and RFC 2616 for HTTP.
# RFC 2616:
#       http_URI = "http:" "//" host [ ":" port ] [ abs_path [ "?" query ]]
$uri {HTTP}           =  "(?k:(?k:http)://(?k:$host)(?::(?k:$port))?"     .
                         "(?k:/(?k:(?k:$path_segments)(?:[?](?k:$query))?))?)";
$uri {FTP}            =  "(?k:(?k:ftp)://"                                .
                           "(?:(?k:$userinfo)(?k:)\@)?(?k:$host)"         .
                           "(?::(?k:$port))?"                             .
                           "(?k:/(?k:(?k:$ftp_segments)"                  .
                           "(?:;type=(?k:[AIai]))?))?)";


pattern name    => [qw (URI)],
        create  => sub {my $uri =  join '|' => values %uri;
                           $uri =~ s/\(\?k:/(?:/g;
                      "(?k:$uri)";
        },
        ;

pattern name    => [qw (URI HTTP), "-scheme=http"],
        create  => sub {
            my $scheme =  $_ [1] -> {-scheme};
            my $uri    =  $uri {HTTP};
            $uri       =~ s/http/$scheme/;
            $uri;
        }
        ;

pattern name    => [qw (URI FTP), "-type=[AIai]", "-password="],
        create  => sub {
            my $uri    =  $uri {FTP};
            if (exists $_ [1] -> {-password} &&
                !defined $_ [1] -> {-password}) {
                $uri =  "(?k:(?k:ftp)://"                                  .
                          "(?:(?k:$userinfo_no_colon)"                     .
                          "(?::(?k:$userinfo_no_colon))?\@)?"              .
                          "(?k:$host)(?::(?k:$port))?"                     .
                          "(?k:/(?k:(?k:$ftp_segments)"                    .
                          "(?:;type=(?k:[AIai]))?))?)";
            }
            my $type   =  $_ [1] -> {-type};
            $uri       =~ s/\[AIai\]/$type/;
            $uri;
        }
        ;

# Telnet URIs are defined in RFC 1738.
$uri {telnet}         =   "(?k:(?k:telnet)://"                            .
                          "(?:(?k:(?k:$user)(?::(?k:$password))?)\@)?"     .
                          "(?k:(?k:$host)(?::(?k:$port))?)(?k:/)?)";

pattern name    => [qw (URI telnet)],
        create  => $uri {telnet}
        ;

# From RFC 1035, domain names.
my $alphanum_hyp      = "[-A-Za-z0-9]";
my $domain            = "(?: |(?:$alpha(?:(?:$alphanum_hyp){0,61}$alphanum)?" .
                          "(?:[.]$alpha(?:(?:$alphanum_hyp){0,61}$alphanum)?" .
                        ")*))";

# RFC 2806, URIs for tel, fax & modem.
my $dtmf_digit        =  "(?:[*#ABCD])";
my $wait_for_dial_tone=  "(?:w)";
my $one_second_pause  =  "(?:p)";
my $pause_character   =  "(?:[wp])";   # wait_for_dial_tone | one_second_pause.
my $visual_separator  =  "(?:[\\-.()])";
my $phonedigit        =  "(?:[0-9\\-.()])";  # DIGIT | visual_separator
my $escaped_no_dquote =  "(?:%(?:[01]$hex)|2[013-9A-Fa-f]|[3-9A-Fa-f]$hex)";
my $quoted_string     =  "(?:%22(?:(?:%5C(?:$unreserved|$escaped))|" .
                                 "$unreserved+|$escaped_no_dquote)*%22)";
                         # It is unclear wether we can allow only unreserved
                         # characters to unescaped, or can we also use uric
                         # characters that are unescaped? Or pchars?
my $token_char        =  "(?:[!'*\\-.0-9A-Z_a-z~]|" .
                             "%(?:2[13-7ABDEabde]|3[0-9]|4[1-9A-Fa-f]|" .
                                 "5[AEFaef]|6[0-9A-Fa-f]|7[0-9ACEace]))";
                         # Only allowing unreserved chars to be unescaped.
my $token_chars       =  "(?:(?:[!'*\\-.0-9A-Z_a-z~]+|"                   .
                               "%(?:2[13-7ABDEabde]|3[0-9]|4[1-9A-Fa-f]|" .
                                   "5[AEFaef]|6[0-9A-Fa-f]|7[0-9ACEace]))*)";
my $future_extension  =  "(?:;$token_chars"                       .
                         "(?:=(?:(?:$token_chars(?:[?]$token_chars)?)|" .
                         "$quoted_string))?)";
my $provider_hostname =  $domain;
my $provider_tag      =  "(?:tsp)";
my $service_provider  =  "(?:;$provider_tag=$provider_hostname)";
my $private_prefix    =  "(?:(?:[!'E-OQ-VX-Z_e-oq-vx-z~]|"                   .
                            "(?:%(?:2[124-7CFcf]|3[AC-Fac-f]|4[05-9A-Fa-f]|" .
                                   "5[1-689A-Fa-f]|6[05-9A-Fa-f]|"           .
                                   "7[1-689A-Ea-e])))"                       .
                            "(?:[!'()*\\-.0-9A-Z_a-z~]+|"                    .
                            "(?:%(?:2[1-9A-Fa-f]|3[AC-Fac-f]|"               .
                               "[4-6][0-9A-Fa-f]|7[0-9A-Ea-e])))*)";
my $local_network_prefix
                      =  "(?:[0-9\\-.()*#ABCDwp]+)";
my $global_network_prefix
                      =  "(?:[+][0-9\\-.()]+)";
my $network_prefix    =  "(?:$global_network_prefix|$local_network_prefix)";
my $phone_context_ident
                      =  "(?:$network_prefix|$private_prefix)";
my $phone_context_tag =  "(?:phone-context)";
my $area_specifier    =  "(?:;$phone_context_tag=$phone_context_ident)";
my $post_dial         =  "(?:;postd=[0-9\\-.()*#ABCDwp]+)";
my $isdn_subaddress   =  "(?:;isub=[0-9\\-.()]+)";
my $t33_subaddress    =  "(?:;tsub=[0-9\\-.()]+)";

my $local_phone_number=  "(?:[0-9\\-.()*#ABCDwp]+$isdn_subaddress?"      .
                            "$post_dial?$area_specifier"                 .
                            "(?:$area_specifier|$service_provider|"      .
                               "$future_extension)*)";
my $local_phone_number_no_future
                      =  "(?:[0-9\\-.()*#ABCDwp]+$isdn_subaddress?"      .
                            "$post_dial?$area_specifier"                 .
                            "(?:$area_specifier|$service_provider)*)";
my $fax_local_phone   =  "(?:[0-9\\-.()*#ABCDwp]+$isdn_subaddress?"      .
                            "$t33_subaddress?$post_dial?$area_specifier" .
                            "(?:$area_specifier|$service_provider|"      .
                               "$future_extension)*)";
my $fax_local_phone_no_future
                      =  "(?:[0-9\\-.()*#ABCDwp]+$isdn_subaddress?"      .
                            "$t33_subaddress?$post_dial?$area_specifier" .
                            "(?:$area_specifier|$service_provider)*)";
my $base_phone_number =  "(?:[0-9\\-.()]+)";
my $global_phone_number
                      =  "(?:[+]$base_phone_number$isdn_subaddress?"     .
                                                 "$post_dial?"           .
                            "(?:$area_specifier|$service_provider|"      .
                               "$future_extension)*)";
my $global_phone_number_no_future
                      =  "(?:[+]$base_phone_number$isdn_subaddress?"     .
                                                 "$post_dial?"           .
                            "(?:$area_specifier|$service_provider)*)";
my $fax_global_phone  =  "(?:[+]$base_phone_number$isdn_subaddress?"     .
                                 "$t33_subaddress?$post_dial?"           .
                            "(?:$area_specifier|$service_provider|"      .
                               "$future_extension)*)";
my $fax_global_phone_no_future
                      =  "(?:[+]$base_phone_number$isdn_subaddress?"     .
                                 "$t33_subaddress?$post_dial?"           .
                            "(?:$area_specifier|$service_provider)*)";
my $telephone_subscriber
                      =  "(?:$global_phone_number|$local_phone_number)";
my $telephone_subscriber_no_future
                      =  "(?:$global_phone_number_no_future|" .
                            "$local_phone_number_no_future)";
my $fax_subscriber    =  "(?:$fax_global_phone|$fax_local_phone)";
my $fax_subscriber_no_future
                      =  "(?:$fax_global_phone_no_future|"    .
                            "$fax_local_phone_no_future)";

my $telephone_scheme  =  "(?:tel)";
my $fax_scheme        =  "(?:fax)";
my $telephone_url     =  "(?:$telephone_scheme:$telephone_subscriber)";
my $telephone_url_no_future
                      =  "(?:$telephone_scheme:" .
                            "$telephone_subscriber_no_future)";
my $fax_url           =  "(?:$fax_scheme:$fax_subscriber)";
my $fax_url_no_future =  "(?:$fax_scheme:$fax_subscriber_no_future)";

$uri {tel}            =  $telephone_url;
$uri {fax}            =  $fax_url;

pattern name    => [qw (URI tel)],
        create  => "(?k:(?k:$telephone_scheme):(?k:$telephone_subscriber))",
        ;

pattern name    => [qw (URI tel nofuture)],
        create  => "(?k:(?k:$telephone_scheme):" .
                       "(?k:$telephone_subscriber_no_future))"
        ;

pattern name    => [qw (URI fax)],
        create  => "(?k:(?k:$fax_scheme):(?k:$fax_subscriber))",
        ;

pattern name    => [qw (URI fax nofuture)],
        create  => "(?k:(?k:$fax_scheme):(?k:$fax_subscriber_no_future))",
        ;


# TV URLs. 
# Internet draft: draft-zigmond-tv-url-03.txt
my $tv_scheme         = 'tv';
my $tv_url            = "$tv_scheme:$hostname?";

$uri {tv}             =  $tv_url;

pattern name    => [qw (URI tv)],
        create  => "(?k:(?k:$tv_scheme):(?k:$hostname)?)",
        ;

}

1;

__END__

=pod

=head1 NAME

Regexp::Common::URI -- provide regexes for URIs.

=head1 SYNOPSIS

    use Regexp::Common qw /URI/;

    while (<>) {
        /$RE{URI}{HTTP}/       and  print "Contains an HTTP URI.\n";
    }

=head1 DESCRIPTION

Regexes are available for the following URI types:

=head2 $RE{URI}{HTTP}{-scheme}

Provides a regex for an HTTP URI as defined by RFC 2396 (generic syntax)
and RFC 2616 (HTTP).

If C<< -scheme=I<P> >> is specified the pattern I<P> is used as the scheme.
By default I<P> is C<qr/http/>. C<https> and C<https?> are reasonable
alternatives.

The syntax for an HTTP URI is:

    "http:" "//" host [ ":" port ] [ "/" path [ "?" query ]]

Under C<{-keep}>, the following are returned:

=over 4

=item $1

The entire URI.

=item $2

The scheme.

=item $3

The host (name or address).

=item $4

The port (if any).

=item $5

The absolute path, including the query and leading slash.

=item $6

The absolute path, including the query, without the leading slash.

=item $7

The absolute path, without the query or leading slash.

=item $8

The query, without the question mark.

=back

=head2 $RE{URI}{FTP}{-type}{-password};

Returns a regex for FTP URIs. Note: FTP URIs are not formally defined.
RFC 1738 defines FTP URLs, but parts of that RFC have been obsoleted
by RFC 2396. However, the differences between RFC 1738 and RFC 2396 
are such that they aren't applicable straightforwardly to FTP URIs.

There are two main problems:

=over 4

=item Passwords.

RFC 1738 allowed an optional username and an optional password (separated
by a colon) in the FTP URL. Hence, colons were not allowed in either the
username or the password. RFC 2396 strongly recommends passwords should
not be used in URIs. It does allow for I<userinfo> instead. This userinfo
part may contain colons, and hence contain more than one colon. The regexp
returned follows the RFC 2396 specification, unless the I<{-password}>
option is given; then the regex allows for an optional username and
password, separated by a colon.

=item The ;type specifier.

RFC 1738 does not allow semi-colons in FTP path names, because a semi-colon
is a reserved character for FTP URIs. The semi-colon is used to separate
the path from the option I<type> specifier. However, in RFC 2396, paths
consist of slash separated segments, and each segment is a semi-colon 
separated group of parameters. Straigthforward application of RFC 2396
would mean that a trailing I<type> specifier couldn't be distinguished
from the last segment of the path having a two parameters, the last one
starting with I<type=>. Therefore we have opted to disallow a semi-colon
in the path part of an FTP URI.

Furthermore, RFC 1738 allows three values for the type specifier, I<A>,
I<I> and I<D> (either upper case or lower case). However, the internet
draft about FTP URIs B<[DRAFT-FTP-URL]> (which expired in May 1997) notes
the lack of consistent implementation of the I<D> parameter and drops I<D>
from the set of possible values. We follow this practise; however, RFC 1738
behaviour can be archieved by using the I<"-type=[ADIadi]"> parameter.

=back

FTP URIs have the following syntax:

    "ftp:" "//" [ userinfo "@" ] host [ ":" port ]
                [ "/" path [ ";type=" value ]]

When using I<{-password}>, we have the syntax:

    "ftp:" "//" [ user [ ":" password ] "@" ] host [ ":" port ]
                [ "/" path [ ";type=" value ]]

Under C<{-keep}>, the following are returned:

=over 4

=item $1

The complete URI.

=item $2

The scheme.

=item $3

The userinfo, or if I<{-password}> is used, the username.

=item $4

If I<{-password}> is used, the password, else C<undef>.

=item $5

The hostname or IP address.

=item $6

The port number.

=item $7

The full path and type specification, including the leading slash.

=item $8

The full path and type specification, without the leading slash.

=item $9

The full path, without the type specification nor the leading slash.

=item $10

The value of the type specification.

=back

=head2 $RE{URI}{telnet}

Returns a pattern that matches I<telnet> URIs, as defined by RFC 1738.
Telnet URIs have the form:

    "telnet:" "//" [ user [ ":" password ] "@" ] host [ ":" port ] [ "/" ]

Under C<{-keep}>, the following are returned:

=over 4

=item $1

The complete URI.

=item $2

The scheme.

=item $3

The username:password combo, or just the username if there is no password.

=item $4

The username, if given.

=item $5

The password, if given.

=item $6

The host:port combo, or just the host if there's no port.

=item $7

The host.

=item $8

The port, if given.

=item $9

The trailing slash, if any.

=back

=head2 $RE{URI}{tel}

Returns a pattern that matches I<tel> URIs, as defined by RFC 2806.
Under C<{-keep}>, the following are returned:

=over 4

=item $1

The complete URI.

=item $2

The scheme.

=item $3

The phone number, including any possible add-ons like ISDN subaddress,
a post dial part, area specifier, service provider, etc.

=back

=head2 C<$RE{URI}{tel}{nofuture}>

As above (including what's returned by C<{-keep}>), with the exception
that I<future extensions> are not allowed. Without allowing 
those I<future extensions>, it becomes much easier to check a URI if
the correct syntax for post dial, service provider, phone context,
etc has been used - otherwise the regex could always classify them
as a I<future extension>.

=head2 C<$RE{URI}{fax}> and C<$RE{URI}{fax}{nofuture}>

Similar to C<$RE{URI}{tel}> and C<$RE{URI}{tel}{nofuture}>, except that
it will return patterns matching fax URIs, as defined in RFC 2806.
C<{-keep}> will return the same fragments as for tel URIs.

=head2 C<$RE{URI}{tv}>

Returns a pattern that recognizes TV uris as per an Internet draft
[DRAFT-URI-TV].

=head1 REFERENCES

=over 4

=item B<[DRAFT-URI-TV]>

Zigmond, D. and Vickers, M: I<Uniform Resource Identifiers for
Television Broadcasts>. December 2000.

=item B<[DRAFT-URL-FTP]>

Casey, James: I<A FTP URL Format>. November 1996.

=item B<[RFC 1035]>

Mockapetris, P.: I<DOMAIN NAMES - IMPLEMENTATION AND SPECIFICATION>.
November 1987.

=item B<[RFC 1738]>

Berners-Lee, Tim, Masinter, L., McCahill, M.: I<Uniform Resource
Locators (URL)>. December 1994.

=item B<[RFC 2396]>

Berners-Lee, Tim, Fielding, R., and Masinter, L.: I<Uniform Resource
Identifiers (URI): Generic Syntax>. August 1998.

=item B<[RFC 2616]>

Fielding, R., Gettys, J., Mogul, J., Frystyk, H., Masinter, L., 
Leach, P. and Berners-Lee, Tim: I<Hypertext Transfer Protocol -- HTTP/1.1>.
June 1999.

=item B<[RFC 2806]>

Vaha-Sipila, A.: I<URLs for Telephone Calls>. April 2000.

=back

=head1 HISTORY

 $Log: URI.pm,v $
 Revision 2.102  2003/02/07 15:24:17  abigail
 telnet URIs

 Revision 2.101  2003/02/01 22:55:31  abigail
 Changed Copyright years

 Revision 2.100  2003/01/21 23:19:40  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.11  2003/01/21 22:59:33  abigail
 Fixed small errors with  and

 Revision 1.10  2003/01/17 13:17:15  abigail
 Fixed '$toplabel' and '$domainlabel'; they were both subexpressions
 of the form: A|AB. Which passed the tests because most tests anchor
 the regex at the beginning and end.

 Revision 1.9  2003/01/01 23:00:54  abigail
 TV URIs

 Revision 1.8  2002/08/27 16:56:27  abigail
 Support for fax URIs.

 Revision 1.7  2002/08/06 14:44:07  abigail
 Local phone numbers can have future extensions as well.

 Revision 1.6  2002/08/06 13:18:03  abigail
 Cosmetic changes

 Revision 1.5  2002/08/06 13:16:27  abigail
 Added $RE{URI}{tel}{nofuture}

 Revision 1.4  2002/08/06 00:03:30  abigail
 Added $RE{URI}{tel}

 Revision 1.3  2002/08/04 22:51:35  abigail
 Added FTP URIs.

 Revision 1.2  2002/07/25 22:37:44  abigail
 Added 'use strict'.
 Added 'no_defaults' to 'use Regex::Common' to prevent loading of all
 defaults.

 Revision 1.1  2002/07/25 19:56:07  abigail
 Modularizing Regexp::Common.

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

     Copyright (c) 2001 - 2003, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)

=cut
