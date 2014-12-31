# LOAD
BEGIN {print "1..4\n";}

package RC::SubClass;

use Regexp::Common;
sub import {
    my $self = shift;

    my $parent = ref tied %Regexp::Common::RE;
    $parent ||= 'Regexp::Common';
    push @ISA, $parent unless $self->isa($parent);

    tie %Regexp::Common::RE, __PACKAGE__
        if !defined tied %Regexp::Common::RE
        || !tied( %Regexp::Common::RE )->isa(__PACKAGE__);

    {
        no strict 'refs';
        *{caller() . "::RE"} = \%Regexp::Common::RE;
    }
}

sub method { return "foo" }

package main;

# in some code we load subclass
# in some code later we load original
# make sure subclass stays
RC::SubClass->import('delimited');
Regexp::Common->import('delimited');

print "ok 1\n";

print "not " unless ref(tied(%RE)) eq "RC::SubClass";
print "ok 2\n";

print "not " unless tied(%RE)->method eq "foo";
print "ok 3\n";

print "not " unless $RE{'quoted'}->method() eq "foo";
print "ok 4\n";
