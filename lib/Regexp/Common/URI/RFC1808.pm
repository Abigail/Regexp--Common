package Regexp::Common::URI::RFC1808;

BEGIN {
    # This makes sure 'use warnings' doesn't bomb out on 5.005_*;
    # warnings won't be enabled on those old versions though.
    if ($] < 5.006 && !exists $INC {"warnings.pm"}) {
        $INC {"warnings.pm"} = 1;
        no strict 'refs';
        *{"warnings::unimport"} = sub {0};
    }
}

use strict;
use warnings;

our $VERSION = '2024080801';

use Exporter ();
our @ISA = qw /Exporter/;


my %vars;

BEGIN {
    $vars {low}     = [qw /$punctuation $reserved_range $reserved $national
                           $extra $safe $digit $digits $hialpha $lowalpha
                           $alpha $alphadigit $hex $escape $unreserved_range
                           $unreserved $uchar $uchars $pchar_range $pchar
                           $pchars/],

    $vars {parts}   = [qw /$fragment $query $param $params $segment
                           $fsegment $path $net_loc $scheme $rel_path
                           $abs_path $net_path $relativeURL $generic_RL
                           $absoluteURL $URL/],
}

our @EXPORT      = qw /$host/;
our @EXPORT_OK   = map {@$_} values %vars;
our %EXPORT_TAGS = (%vars, ALL => [@EXPORT_OK]);

# RFC 1808, base definitions.

# Lowlevel definitions.
our $punctuation       =  '[<>#%"]';
our $reserved_range    = q [;/?:@&=];
our $reserved          =  "[$reserved_range]";
our $national          =  '[][{}|\\^~`]';
our $extra             =  "[!*'(),]";
our $safe              =  '[-$_.+]';

our $digit             =  '[0-9]';
our $digits            =  '[0-9]+';
our $hialpha           =  '[A-Z]';
our $lowalpha          =  '[a-z]';
our $alpha             =  '[a-zA-Z]';                 # lowalpha | hialpha
our $alphadigit        =  '[a-zA-Z0-9]';              # alpha    | digit

our $hex               =  '[a-fA-F0-9]';
our $escape            =  "(?:%$hex$hex)";

our $unreserved_range  = q [-a-zA-Z0-9$_.+!*'(),];  # alphadigit | safe | extra
our $unreserved        =  "[$unreserved_range]";
our $uchar             =  "(?:$unreserved|$escape)";
our $uchars            =  "(?:(?:$unreserved+|$escape)*)";

our $pchar_range       = qq [$unreserved_range:\@&=];
our $pchar             =  "(?:[$pchar_range]|$escape)";
our $pchars            =  "(?:(?:[$pchar_range]+|$escape)*)";


# Parts
our $fragment          =  "(?:(?:[$unreserved_range$reserved_range]+|" .
                                 "$escape)*)";
our $query             =  "(?:(?:[$unreserved_range$reserved_range]+|" .
                                 "$escape)*)";

our $param             =  "(?:(?:[$pchar_range/]+|$escape)*)";
our $params            =  "(?:$param(?:;$param)*)";

our $segment           =  "(?:(?:[$pchar_range]+|$escape)*)";
our $fsegment          =  "(?:(?:[$pchar_range]+|$escape)+)";
our $path              =  "(?:$fsegment(?:/$segment)*)";

our $net_loc           =  "(?:(?:[$pchar_range;?]+|$escape)*)";
our $scheme            =  "(?:(?:[-a-zA-Z0-9+.]+|$escape)+)";

our $rel_path          =  "(?:$path?(?:;$params)?(?:?$query)?)";
our $abs_path          =  "(?:/$rel_path)";
our $net_path          =  "(?://$net_loc$abs_path?)";

our $relativeURL       =  "(?:$net_path|$abs_path|$rel_path)";
our $generic_RL        =  "(?:$scheme:$relativeURL)";
our $absoluteURL       =  "(?:$generic_RL|" .
                          "(?:$scheme:(?:[$unreserved_range$reserved_range]+|" .
                                         "$escape)*))";
our $URL               =  "(?:(?:$absoluteURL|$relativeURL)(?:#$fragment)?)";


1;

__END__

=pod

=head1 NAME

Regexp::Common::URI::RFC1808 -- Definitions from RFC1808;

=head1 SYNOPSIS

    use Regexp::Common::URI::RFC1808 qw /:ALL/;

=head1 DESCRIPTION

This package exports definitions from RFC1808. It's intended
usage is for Regexp::Common::URI submodules only. Its interface
might change without notice.

=head1 REFERENCES

=over 4

=item B<[RFC 1808]>

Fielding, R.: I<Relative Uniform Resource Locators (URL)>. June 1995.

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
