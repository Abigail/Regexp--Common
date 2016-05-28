#!/opt/perl/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common;
use Test::More;

my $r = eval "require Test::Regexp; 1";

unless ($r) {
    print "1..0 # SKIP Test::Regexp not found\n";
    exit;
}

unless ($] >= 5.014) {
    print "1..0 # SKIP Pattern not available on this version of Perl\n";
    exit;
}

sub make_test {
    my ($name, $pat) = @_;
    my $keep = $$pat {-keep};
    Test::Regexp::   -> new -> init (
        pattern      => $pat,
        keep_pattern => $keep,
        name         => $name,
    );
}

#
# Pairs of brackets
#
my @pairs = map {[chr $$_ [1], chr ($$_ [2] // ($$_ [1] + 1)), $$_ [0]]} 
   ["parenthesis"                                             =>  0x0028,
                                                                  0x0029],
   ["square bracket"                                          =>  0x005B,
                                                                  0x005D],
   ["curly brackets"                                          =>  0x007B,
                                                                  0x007D],
   ["double quotation marks"                                  =>  0x201C],
   ["quotation marks"                                         =>  0x2018],
   ["single pointing angle quotation marks"                   =>  0x2039],
   ["pointing double angle quotation marks"                   =>  0x00AB,
                                                                  0x00BB],
   ["fullwidth parenthesis"                                   =>  0xFF08],
   ["fullwidth square brackets"                               =>  0xFF3B,
                                                                  0xFF3D],
   ["fullwidth curly brackets"                                =>  0xFF5B,
                                                                  0xFF5D],
   ["fullwidth white parenthesis"                             =>  0xFF5F],
   ["white parenthesis"                                       =>  0x2985],
   ["white square brackets"                                   =>  0x301A],
   ["white curly brackets"                                    =>  0x2983],
   ["corner brackets"                                         =>  0x300C],
   ["angle brackets"                                          =>  0x3008],
   ["double angle brackets"                                   =>  0x300A],
   ["black lenticular brackets"                               =>  0x3010],
   ["tortoise shell brackets"                                 =>  0x3014],
   ["black tortoise shell brackets"                           =>  0x2997],
   ["white corner brackets"                                   =>  0x300E],
   ["white lenticular brackets",                              =>  0x3016],
   ["white tortoise shell brackets"                           =>  0x3018],
   ["halfwidth corner brackets"                               =>  0xFF62],
   ["mathematical white square brackets"                      =>  0x27E6],
   ["mathematical angle brackets"                             =>  0x27E8],
   ["mathematical double angle brackets"                      =>  0x27EA],
   ["mathematical flattened parenthesis"                      =>  0x27EE],
   ["mathematical white tortoise shell brackets"              =>  0x27EC],
   ["ceiling"                                                 =>  0x2308],
   ["floor"                                                   =>  0x230A],
   ["Z notation image brackets"                               =>  0x2987],
   ["Z notation binding brackets"                             =>  0x2989],
   ["heavy single commas"                                     =>  0x275B],
   ["heavy double commas"                                     =>  0x275D],
   ["medium parenthesis ornaments"                            =>  0x2768],
   ["medium flattened parenthesis ornaments"                  =>  0x276A],
   ["medium curly bracket ornaments"                          =>  0x2774],
   ["medium pointing angle bracket ornaments"                 =>  0x276C],
   ["heavy pointing angle quotation mark ornaments"           =>  0x276E],
   ["heavy pointing angle bracket ornaments"                  =>  0x2770],
   ["light tortoise shell bracket ornaments"                  =>  0x2772],
   ["ornate parenthesis"                                      =>  0xFD3E],
   ["top-bottom parenthesis"                                  =>  0x23DC],
   ["top-bottom square brackets"                              =>  0x23B4],
   ["top-bottom curly brackets"                               =>  0x23DE],
   ["top-bottom tortoise shell brackets"                      =>  0x23E0],
   ["presentation form for vertical corner brackets"          =>  0xFE41],
   ["presentation form for vertical white corner brackets"    =>  0xFE43],
   ["presentation form for vertical tortoise shell brackets"  =>  0xFE39],
   ["presentation form for vertical black lenticul brackets"  =>  0xFE3B],
   ["presentation form for vertical white lenticul brackets"  =>  0xFE17],
   ["presentation form for vertical angle brackets"           =>  0xFE3F],
   ["presentation form for vertical double angle brackets"    =>  0xFE3D],
   ["presentation form for vertical square brackets"          =>  0xFE47],
   ["presentation form for vertical curly brackets"           =>  0xFE37],
   ["pointing angle brackets"                                 =>  0x2329],
   ["angle brackets with dots"                                =>  0x2991],
   ["pointing curved angle brackets"                          =>  0x29FC],
   ["small parenthesis"                                       =>  0xFE59],
   ["small curly brackets"                                    =>  0xFE5B],
   ["small tortoise shell brackets"                           =>  0xFE5D],
   ["superscript parenthesis"                                 =>  0x207D],
   ["subscript parenthesis"                                   =>  0x208D],
   ["square brackets with underbars"                          =>  0x298B],
   ["square brackets with top-bottom ticks"                   =>  0x298D],
   ["square brackets with bottom-top ticks"                   =>  0x298F],
   ["square brackets with quills"                             =>  0x2045],
   ["top half brackets"                                       =>  0x2E22],
   ["bottom half brackets"                                    =>  0x2E24],
   ["S-shaped bag delimiters"                                 =>  0x27C5],
   ["arcs with less/greater than brackets"                    =>  0x2993],
   ["double arcs with greater/less than brackets"             =>  0x2995],
   ["sideways U brackets"                                     =>  0x2E26],
   ["double parenthesis"                                      =>  0x2E28],
   ["wiggly fences"                                           =>  0x29D8],
   ["double wiggly fences"                                    =>  0x29DA],
   ["low paraphrase brackets"                                 =>  0x2E1C],
   ["raised omission brackets"                                =>  0x2E0C],
   ["substitution brackets"                                   =>  0x2E02],
   ["double substitution brackets"                            =>  0x2E04],
   ["transposition brackets"                                  =>  0x2E09],
   ["Ogham feather marks"                                     =>  0x169B],
   ["Tibetan marks gug rtags"                                 =>  0x0F3A],
   ["Tibetan marks ang khang"                                 =>  0x0F3C],
;

#
# Test double quoted delimiter
#
{
    my $test = make_test "Bracketed string" =>
                         $RE {bquoted};

    foreach my $pair (@pairs) {
        my ($left, $right, $name) = @$pair;

        $test -> match ("${left}A few words${right}",
                       ["${left}A few words${right}", $left,
                               "A few words",         $right],
                       test => "Using ${name} as delimiters");

        $test -> match ("${left}A few ${left}words${right}",
                       ["${left}A few ${left}words${right}", $left,
                               "A few ${left}words",         $right],
                       test => "Using ${name} as delimiters; " .
                               "use opening delimiter in string");

        $test -> match ("${left}A few \\${right}words${right}",
                       ["${left}A few \\${right}words${right}", $left,
                               "A few \\${right}words",         $right],
                       test => "Using ${name} as delimiters; " .
                               "use escaped closing delimiter in string");

        $test -> match ("${left}A few\nwords${right}",
                       ["${left}A few\nwords${right}", $left,
                               "A few\nwords",         $right],
                       test => "Using ${name} as delimiters; " .
                               "don't trip over newlines");

        $test -> no_match ("${left}A few words${left}",
                            reason => "Using opening delimiter " .
                                      "as the closing one");

        $test -> no_match ("${right}A few words${right}",
                            reason => "Using closing delimiter " .
                                      "as the opening one");

        $test -> no_match ("${left}A few ${right}words${right}",
                            reason => "Unescaped closing delimiter in string");

        $test -> no_match ("${left}A few words\\${right}",
                            reason => "Escaping the closing delimiter is bad");

        $test -> no_match ("${left}A few \\\\${right}words${right}",
                            reason => "Unescaped the escape neutralizes");
    }

    foreach (my $i = 0; $i < @pairs; $i ++) {
        my $j  = ($i + 7) ** 2;
           $j %= @pairs;
        if ($j == $i) {
            $j += 15;
            $j %= @pairs;
        }
        my $left  = $pairs [$i] [0];
        my $right = $pairs [$j] [1];

        $test -> no_match ("${left}A few words${right}",
                            reason => "Mismatched delimiters");
    }
}



done_testing;
