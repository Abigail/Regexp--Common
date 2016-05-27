package Regexp::Common::delimited;

use Regexp::Common qw /pattern clean no_defaults/;

use strict;
use warnings;

use vars qw /$VERSION/;
$VERSION = '2016020301';

sub gen_delimited {

    my ($dels, $escs, $cdels) = @_;
    # return '(?:\S*)' unless $dels =~ /\S/;
    if (length $escs) {
        $escs  .= substr  ($escs, -1) x (length ($dels) - length  ($escs));
    }
    if (length $cdels) {
        $cdels .= substr ($cdels, -1) x (length ($dels) - length ($cdels));
    }
    else {
        $cdels = $dels;
    }

    my @pat = ();
    for (my $i = 0; $i < length $dels; $i ++) {
        my $del  = quotemeta substr  ($dels, $i, 1);
        my $cdel = quotemeta substr ($cdels, $i, 1);
        my $esc = length($escs) ? quotemeta substr ($escs, $i, 1) : "";
        if ($cdel eq $esc) {
            push @pat =>
                "(?k:$del)(?k:[^$cdel]*(?:(?:$cdel$cdel)[^$cdel]*)*)(?k:$cdel)";
        }
        elsif (length $esc) {
            push @pat =>
                "(?k:$del)(?k:[^$esc$cdel]*(?:$esc.[^$esc$cdel]*)*)(?k:$cdel)";
        }
        else {
            push @pat => "(?k:$del)(?k:[^$cdel]*)(?k:$cdel)";
        }
    }
    my $pat = join '|', @pat;
    return "(?k:(?|$pat))";
}

sub _croak {
    require Carp;
    goto &Carp::croak;
}

pattern name    => [qw( delimited -delim= -esc=\\ -cdelim= )],
        create  => sub {my $flags = $_[1];
                        _croak 'Must specify delimiter in $RE{delimited}'
                              unless length $flags->{-delim};
                        return gen_delimited (@{$flags}{-delim, -esc, -cdelim});
                   },
        version => 5.010,
        ;

pattern name    => [qw( quoted -esc=\\ )],
        create  => sub {my $flags = $_[1];
                        return gen_delimited (q{"'`}, $flags -> {-esc});
                   },
        version => 5.010,
        ;


1;

__END__

=pod

=head1 NAME

Regexp::Common::delimited -- provides a regex for delimited strings

=head1 SYNOPSIS

    use Regexp::Common qw /delimited/;

    while (<>) {
        /$RE{delimited}{-delim=>'"'}/  and print 'a \" delimited string';
        /$RE{delimited}{-delim=>'/'}/  and print 'a \/ delimited string';
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

=head2 C<$RE{delimited}{-delim}{-cdelim}{-esc}>

Returns a pattern that matches a single-character-delimited substring,
with optional internal escaping of the delimiter.

When C<-delim => I<S>> is specified, each character in the sequence I<S> is
a possible delimiter. There is no default delimiter, so this flag must always
be specified.

By default, the closing delimiter is the same character as the opening
delimiter. If this is not wanted, for instance, if you want to match
a string with symmetric delimeters, you can specify the closing delimiter(s)
with C<-cdelim => I<S>>. Each character in I<S> is matched with the
corresponding character supplied with the C<-delim> option. If the C<-cdelim>
option has less characters than the C<-delim> option, the last character
is repeated as often as necessary. If the C<-cdelim> option has more 
characters than the C<-delim> option, the extra characters are ignored.

If C<-esc => I<S>> is specified, each character in the sequence I<S> is
the delimiter for the corresponding character in the C<-delim=I<S>> list.
The default escape is backslash.

For example:

   $RE{delimited}{-delim=>'"'}               # match "a \" delimited string"
   $RE{delimited}{-delim=>'"'}{-esc=>'"'}    # match "a "" delimited string"
   $RE{delimited}{-delim=>'/'}               # match /a \/ delimited string/
   $RE{delimited}{-delim=>q{'"}}             # match "string" or 'string'
   $RE{delimited}{-delim=>"("}{-cdelim=>")"} # match (string)

Under C<-keep> (See L<Regexp::Common>):

=over 4

=item $1

captures the entire match

=item $2

captures the opening delimiter

=item $3

captures delimited portion of the string

=item $4

captures the closing delimiter

=back

You must use at least version 5.10.0 to use these patterns.

=head2 $RE{quoted}{-esc}

A synonym for C<$RE{delimited}{q{-delim='"`}{...}}>

You must use at least version 5.10.0 to use these patterns.

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in to I<regexp-common@abigail.be>.

=head1 LICENSE and COPYRIGHT

This software is Copyright (c) 2001 - 2016, Damian Conway and Abigail.

This module is free software, and maybe used under any of the following
licenses:

 1) The Perl Artistic License.     See the file COPYRIGHT.AL.
 2) The Perl Artistic License 2.0. See the file COPYRIGHT.AL2.
 3) The BSD Licence.               See the file COPYRIGHT.BSD.
 4) The MIT Licence.               See the file COPYRIGHT.MIT.

=cut
