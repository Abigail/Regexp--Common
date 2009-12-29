package Regexp::Common::lingua; {

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;
use Carp;

use vars qw /$VERSION/;

($VERSION) = q $Revision: 1.2 $ =~ /[\d.]+/;

pattern name    => [qw /lingua palindrome -chars=[A-Za-z]/],
        create  => sub {
            use re 'eval';
            local $^W = 1;
            my $keep  = exists $_ [1] -> {-keep};
            my $ch  = $_ [1] -> {-chars};
            my $idx = $keep ? "1:$ch" : "0:$ch";
            my $r   = "(??{\$Regexp::Common::lingua::pd{'" . $idx . "'}})";
            $Regexp::Common::lingua::pd {$idx} = 
                    $keep ? qr /($ch|($ch)($r)?\2)/ : qr  /$ch|($ch)($r)?\1/;
        #   print "[$ch]: ", $Regexp::Common::lingua::pd {$idx}, "\n";
        #   $Regexp::Common::lingua::pd {$idx};
        },
        version => 5.006
        ;




}

1;

__END__

=pod

=head1 NAME

Regexp::Common::zip -- provide regexes for zip codes.

=head1 SYNOPSIS

    use Regexp::Common qw /zip/;

    while (<>) {
        /^$RE{zip}{Dutch}$/        and  print "Dutch zip code\n";
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{zip}{Dutch}{-lax}{-strict}>

Return a pattern that recognizes Dutch zip codes. Dutch zip codes
consists of 4 digits, followed by 4 uppercase letters. Officially,
a single space should be used between the digits and the letters,
but this isn't always done in practise. If C<-strict> is given,
a single space is mandatory, else any whitespace (including no
whitespace at all) is allowed. Uppercase letters are required,
unless the C<{-lax}> option is used, then lowercase letters
may be used.

If C<{-keep}> is used, the zipcode is returned in C<$1>.

=head2 C<< $RE{zip}{US}{-extended => 'allow'} >>

Returns a pattern that recognizes US zip codes. US zip codes are 5 digits,
with a possible 4 digit extention. By default, the extention is optional.
If the option C<< {-extended => 'yes'} >> is given, the pattern only
matches zip codes with the extention. If the option C<< {-extended => 'no'} >>
is given, the pattern will not recognize an extention.

If C<{-keep}> is being used, the following will be returned:

=over 4

=item $1

The entire zip code.

=item $2

The first 5 digits of the zip code.

=item $3

The 4 digit extention (if any).

=back

=head1 HISTORY

 $Log: lingua.pm,v $
 Revision 1.2  2003/01/01 19:11:29  abigail
 Fixed problem with having different palindrome patterns in same program

 Revision 1.1  2003/01/01 17:05:56  abigail
 First version

 Revision 1.2  2003/01/01 15:09:47  abigail
 Added US zip codes.

 Revision 1.1  2002/12/31 02:01:33  abigail
 First version


=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.nl>)>.

=head1 BUGS AND IRRITATIONS

Zip codes for most countries are missing.
Send them in to I<regexp-common@abigail.nl>.

Do Dutch zip code actually allow all letters? Or are I and O omitted?
What about the Q?

=head1 COPYRIGHT

     Copyright (c) 2001 - 2002, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)

=cut
