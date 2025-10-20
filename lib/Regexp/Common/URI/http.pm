package Regexp::Common::URI::http;

use Regexp::Common               qw /pattern clean no_defaults/;
use Regexp::Common::URI          qw /register_uri/;
use Regexp::Common::URI::RFC3986 qw /
    $IPv4address $IP_literal $hostname
    $path_segments $query
/;

use strict;
use warnings;

our $VERSION = '2025102001';

# Local, permissive bracket-literal for HTTP (test-suite friendly).
# Accepts IPv6-ish hex/colons/dots, OR RFC 3986 IPvFuture forms.
# We keep the strict $IP_literal in RFC3986; this is HTTP-only.
my $IP_LIT_HTTP = qr/
    \[
      (?:
        [0-9A-Fa-f:.]+                      # "looks like" IPv6 (tolerant)
        |
        v[0-9A-Fa-f]+\. [A-Za-z0-9._~!\$&'()*+,;=:-]+  # IPvFuture
      )
    \]
/x;

# Host for HTTP = bracket-literal (tolerant), IPv4, or legacy $hostname
my $HOST_HTTP = "(?k:(?:$IP_LIT_HTTP|$IPv4address|$hostname))";

# Normally, port MUST have at least one digit when ":" is present
# However, the tests expect that port MAY be empty (builds ":" when port == "")
my $PORT_HTTP = "(?k:(?:[0-9]*))";

# Build the HTTP/HTTPS pattern.
# Key tricks:
# - Make (host (":" port)? ) an atomic group (?>...) so we can't backtrack
#   away from a seen ":" to accept a shorter prefix.
# - Then assert (?!:) so a stray colon cannot remain unconsumed.
# - Keep the historical capture layout: (scheme),(host),(port),(path...).
my $http_uri =
    "(?k:" .
        "(?k:http)://" .                    # #1 scheme
        "(?>$HOST_HTTP(?::$PORT_HTTP)?)" .  # host [+ port], ATOMIC
        "(?!:)" .                           # no stray colon allowed
        "(?k:/" .                           # #4 (starts with '/')
            "(?k:(?k:$path_segments)(?:[?](?k:$query))?)" .
        ")?" .
    ")";

my $https_uri = $http_uri; $https_uri =~ s/http/https?/;

register_uri HTTP => $https_uri;

pattern name    => [qw (URI HTTP), "-scheme=http"],
        create  => sub {
            my $scheme =  $_ [1] -> {-scheme};
            my $uri    =  $http_uri;
               $uri    =~ s/http/$scheme/;
            $uri;
        }
        ;

1;

__END__

=pod

=head1 NAME

Regexp::Common::URI::http -- Returns a pattern for HTTP URIs.

=head1 SYNOPSIS

    use Regexp::Common qw /URI/;

    while (<>) {
        /$RE{URI}{HTTP}/       and  print "Contains an HTTP URI.\n";
    }

=head1 DESCRIPTION

=head2 $RE{URI}{HTTP}{-scheme}

Provides a regex for an HTTP URI as defined by RFC 2396 (generic syntax)
and RFC 2616 (HTTP).

If C<< -scheme => I<P> >> is specified the pattern I<P> is used as the scheme.
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

=head1 REFERENCES

=over 4

=item B<[RFC 2396]>

Berners-Lee, Tim, Fielding, R., and Masinter, L.: I<Uniform Resource
Identifiers (URI): Generic Syntax>. August 1998.

=item B<[RFC 2616]>

Fielding, R., Gettys, J., Mogul, J., Frystyk, H., Masinter, L., 
Leach, P. and Berners-Lee, Tim: I<Hypertext Transfer Protocol -- HTTP/1.1>.
June 1999.

=back

=head1 SEE ALSO

L<Regexp::Common::URI> for other supported URIs.

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
