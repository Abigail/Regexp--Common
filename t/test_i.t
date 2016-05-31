#!/usr/bin/perl

# Eventually, this should be tested from the individual test files.

use strict;
use lib  qw {blib/lib};

use Regexp::Common qw /RE_ALL/;

use warnings;


my @data = (
    [[qw /num hex/]             => ["abcdef", "123.456", "1a2B.3c"]],
    [[qw /comment ILLGOL/]      => ["NB foo bar\n", "nb foo bar\n"]],
    [[qw /net domain/]          => ["www.perl.com", "WWW.PERL.COM"]],
    [[qw /net MAC/]             => ["a0:b0:c0:d0:e0:f0", "A0:B0:C0:D0:E0:F0"]],
    [[qw /zip Dutch/]           => ["1234 ab", "1234 AB", "nl-1234 AB"]],
    [[qw /URI HTTP/]            => ["HTTP://WWW.PERL.COM"]],
    [[qw /profanity/]           => [map {local $_ = $_;
                                         y/a-zA-Z/n-za-mN-ZA-M/; $_} qw /
                                    pbpx-fhpxre srygpuvat zhgure-shpxre 
                                    zhgun-shpxvat fuvgf fuvgre penccvat
                                    nefr-ubyr cvff-gnxr jnaxf/]],
    [[qw /num roman/]           => [qw /I i II ii XvIiI CXxxVIiI MmclXXviI/]],
);

push @data => (
    [[qw /balanced/] => ["()", "(a( )b)"]],
);

my $total  = 1;
   $total += 2 * @{$_ -> [1]} for @data;

print "1..$total\n";

print defined $Regexp::Common::VERSION ? "ok 1\n" : "not ok 1\n";

my $count = 1;
sub pass {
    my @a = @_;
    $a [0] =~ y/a-zA-Z/n-za-mN-ZA-M/ if $a [1] =~ /profanity/;
    $a [0] =~ s/\n/\\n/g;
    printf     "ok %d - '%s' =~ %s\n", ++ $count, @a
}
sub fail {
    my @a = @_;
    $a [0] =~ y/a-zA-Z/n-za-mN-ZA-M/ if $a [1] =~ /profanity/;
    $a [0] =~ s/\n/\\n/g;
    printf "not ok %d - '%s' =~ %s\n", ++ $count, @a
}

foreach my $data (@data) {
    my ($name, $queries) = @$data;

    foreach my $str (@$queries) {
        local $" = "}{";
        eval "\$str =~ /^\$RE{@$name}{-i}\$/
                    ? pass \$str, '\$RE{@$name}{-i}'
                    : fail \$str, '\$RE{@$name}{-i}'";
        die $@ if $@;
        local $" = "_";
        eval "\$str =~ RE_@$name (-i => 1)
                    ? pass \$str, 'RE_@$name (-i => 1)',
                    : fail \$str, 'RE_@$name (-i => 1)'";
        die $@ if $@;
    }
}
    



__END__
