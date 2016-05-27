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
# Test double quoted delimiter
#
{
    my $test = make_test "Double quoted string" =>
                         $RE {delimited} {-delim => '"'};

    $test -> match (q {"a few words"},
                   [q {"a few words"}, q {"}, q {a few words}, q {"}],
                   test => "Simple string"),
    $test -> match (q {"a few \ words"},
                   [q {"a few \ words"}, q {"}, q {a few \ words}, q {"}],
                   test => "Simple string with escape"),
    $test -> match (q {"a few \" words"},
                   [q {"a few \" words"}, q {"}, q {a few \" words}, q {"}],
                   test => "Simple string with escaped delimiter"),
    $test -> match (q {"a 'few' words"},
                   [q {"a 'few' words"}, q {"}, q {a 'few' words}, q {"}],
                   test => "Simple string with single quotes"),

    $test -> no_match (q {'a few words'}, reason => "Wrong delimiters");
    $test -> no_match (q {a few words"}, reason => "No opening delimiter");
    $test -> no_match (q {"a few words}, reason => "No closing delimiter");
    $test -> no_match (q {"a few" words"}, reason => "Unescaped delimiter");
    $test -> no_match (q {"a few\\\\" words"}, reason => "Escaped escape");
    $test -> no_match (q { "a few words"},
                       reason => "Characters before opening delimiter");
    $test -> no_match (q {"a few words" },
                       reason => "Characters after opening delimiter");
}


#
# Test single quoted delimiter
#
{
    my $test = make_test "Single quoted string" =>
                         $RE {delimited} {-delim => "'"};

    $test -> match (q {'a few words'},
                   [q {'a few words'}, q {'}, q {a few words}, q {'}],
                   test => "Simple string"),
    $test -> match (q {'a few \ words'},
                   [q {'a few \ words'}, q {'}, q {a few \ words}, q {'}],
                   test => "Simple string with escape"),
    $test -> match (q {'a few \' words'},
                   [q {'a few \' words'}, q {'}, q {a few \' words}, q {'}],
                   test => "Simple string with escaped delimiter"),
    $test -> match (q {'a "few" words'},
                   [q {'a "few" words'}, q {'}, q {a "few" words}, q {'}],
                   test => "Simple string with double quotes"),

    $test -> no_match (q {"a few words"}, reason => "Wrong delimiters");
    $test -> no_match (q {a few words'}, reason => "No opening delimiter");
    $test -> no_match (q {'a few words}, reason => "No closing delimiter");
    $test -> no_match (q {'a few' words'}, reason => "Unescaped delimiter");
    $test -> no_match (q {'a few\\\\' words'}, reason => "Escaped escape");
    $test -> no_match (q { 'a few words'},
                       reason => "Characters before opening delimiter");
    $test -> no_match (q {'a few words' },
                       reason => "Characters after opening delimiter");
}


#
# Test an odd (space) delimiter
#
{
    my $test = make_test "Space quoted string" =>
                         $RE {delimited} {-delim => " "};

    $test -> match (q { a-few-words },
                   [q { a-few-words }, q { }, q {a-few-words}, q { }],
                   test => "Simple string"),
    $test -> match (q { a-few-\-words },
                   [q { a-few-\-words }, q { }, q {a-few-\-words}, q { }],
                   test => "Simple string with escape"),
    $test -> match (q { a-few-\ -words },
                   [q { a-few-\ -words }, q { }, q {a-few-\ -words}, q { }],
                   test => "Simple string with escaped delimiter"),

    $test -> no_match (q {"a few words"}, reason => "Wrong delimiters");
}


#
# Test $RE {quoted}. This automatically tests multiple delimiters as well.
#
{
    my $test = make_test "Quoted string (using 'quoted')" => $RE {quoted};

    $test -> match (q {"a few words"},
                   [q {"a few words"}, q {"}, q {a few words}, q {"}],
                   test => "Simple string, using double quotes"),
    $test -> match (q {'a few words'},
                   [q {'a few words'}, q {'}, q {a few words}, q {'}],
                   test => "Simple string, using single quotes"),
    $test -> match (q {`a few words`},
                   [q {`a few words`}, q {`}, q {a few words}, q {`}],
                   test => "Simple string, using backticks"),
    $test -> match (q {"a few \ words"},
                   [q {"a few \ words"}, q {"}, q {a few \ words}, q {"}],
                   test => "Double quoted string with escape"),
    $test -> match (q {'a few \ words'},
                   [q {'a few \ words'}, q {'}, q {a few \ words}, q {'}],
                   test => "Single quoted string with escape"),
    $test -> match (q {`a few \ words`},
                   [q {`a few \ words`}, q {`}, q {a few \ words}, q {`}],
                   test => "Backtick quoted string with escape"),
    $test -> match (q {"a few \" words"},
                   [q {"a few \" words"}, q {"}, q {a few \" words}, q {"}],
                   test => "Double quoted string with escaped delimiter"),
    $test -> match (q {'a few \' words'},
                   [q {'a few \' words'}, q {'}, q {a few \' words}, q {'}],
                   test => "Single quoted string with escaped delimiter"),
    $test -> match (q {`a few \` words`},
                   [q {`a few \` words`}, q {`}, q {a few \` words}, q {`}],
                   test => "Backtick quoted string with escaped delimiter"),
    $test -> match (q {"a 'few' words"},
                   [q {"a 'few' words"}, q {"}, q {a 'few' words}, q {"}],
                   test => "Double quoted string with single quotes"),
    $test -> match (q {'a "few" words'},
                   [q {'a "few" words'}, q {'}, q {a "few" words}, q {'}],
                   test => "Single quoted string with double quotes"),
    $test -> match (q {`a "few" words`},
                   [q {`a "few" words`}, q {`}, q {a "few" words}, q {`}],
                   test => "Backtick quoted string with double quotes"),

    $test -> no_match (q {'a few words"}, reason => "Mixed delimiters");
    $test -> no_match (q {'a few words`}, reason => "Mixed delimiters");
    $test -> no_match (q {"a few words`}, reason => "Mixed delimiters");
    $test -> no_match (q {"a few words'}, reason => "Mixed delimiters");
    $test -> no_match (q {`a few words"}, reason => "Mixed delimiters");
    $test -> no_match (q {`a few words'}, reason => "Mixed delimiters");
}


#
# Test an another delimiter
#
{
    my $test = make_test "Bang as delimiter" =>
                         $RE {delimited} {-delim => '"'} {-esc => '!'};

    $test -> match (q {"a few words"},
                   [q {"a few words"}, q {"}, q {a few words}, q {"}],
                   test => "Simple string"),
    $test -> match (q {"a few ! words"},
                   [q {"a few ! words"}, q {"}, q {a few ! words}, q {"}],
                   test => "Simple string with escape"),
    $test -> match (q {"a few !" words"},
                   [q {"a few !" words"}, q {"}, q {a few !" words}, q {"}],
                   test => "Simple string with escaped delimiter"),

    $test -> no_match (q {"a few\" words"}, reason => "Incorrect escape");
    $test -> no_match (q {"a few!!" words"}, reason => "Escaped escape");
}



#
# Test delimiter and escape the same characters
#
{
    my $test = make_test "Delimiter is same as escape" =>
                         $RE {delimited} {-delim => '!'} {-esc => '!'};

    $test -> match (q {!a few words!},
                   [q {!a few words!}, q {!}, q {a few words}, q {!}],
                   test => "Simple string"),
    $test -> match (q {!a few !! words!},
                   [q {!a few !! words!}, q {!}, q {a few !! words}, q {!}],
                   test => "Simple string with escaped delimiter"),

    $test -> no_match (q {!a few\! words!}, reason => "Incorrect escape");
    $test -> no_match (q {!a few! words!},
                       reason => "Escape must be followed by delimiter");
}


#
# Test multiple escapes; they should match up with the delimiters
#
{
    my $test = make_test "Multiple escape characters" =>
                         $RE {quoted} {-esc => '!_'};

    $test -> match (q {"a few words"},
                   [q {"a few words"}, q {"}, q {a few words}, q {"}],
                   test => "Simple string");
    $test -> match (q {"a !"few words"},
                   [q {"a !"few words"}, q {"}, q {a !"few words}, q {"}],
                   test => "Simple string, with escape");
    $test -> match (q {'a _'few words'},
                   [q {'a _'few words'}, q {'}, q {a _'few words}, q {'}],
                   test => "Simple string, with another delimiter/escape");
    $test -> match (q {`a _`few words`},
                   [q {`a _`few words`}, q {`}, q {a _`few words}, q {`}],
                   test => "Escape copied when there are more delimiters");

    $test -> no_match (q {"a _"few words"}, reason => "Incorrect delimiter");
    $test -> no_match (q {'a !'few words'}, reason => "Incorrect delimiter");
    $test -> no_match (q {`a !`few words`}, reason => "Incorrect delimiter");
    $test -> no_match (q {"a \"few words"}, reason => "Incorrect delimiter");
}


#
# Test no escape character
#
{
    my $test = make_test "Double quoted string" =>
                         $RE {delimited} {-delim => '"'} {-esc =>};

    $test -> match (q {"a few words"},
                   [q {"a few words"}, q {"}, q {a few words}, q {"}],
                   test => "Simple string"),

    $test -> no_match (q {"a few" words"}, reason => "Delimiter in string");
    $test -> no_match (q {"a few\" words"}, reason => "There is no escape");
}


#
# Test different closing delimiters
#
{
    my $test = make_test "Bracketed strings" =>
                         $RE {delimited} { -delim => '([{<'} 
                                         {-cdelim => ')]}>'};

    $test -> match ("(a few words)",
                   ["(a few words)", "(", "a few words", ")"],
                   test => "Using parenthesis");
    $test -> match ("[a few words]",
                   ["[a few words]", "[", "a few words", "]"],
                   test => "Using brackets");
    $test -> match ("{a few words}",
                   ["{a few words}", "{", "a few words", "}"],
                   test => "Using braces");
    $test -> match ("<a few words>",
                   ["<a few words>", "<", "a few words", ">"],
                   test => "Using angle brackets");
    $test -> match ("[a [few words]",
                   ["[a [few words]", "[", "a [few words", "]"],
                   test => "Opening delimiter needs no escape");
    $test -> match ('[a [few\] words]',
                   ['[a [few\] words]', "[", 'a [few\] words', "]"],
                   test => "Closing delimiter needs escape");

    $test -> no_match ("[a few words}", reason => "Mismatched delimiters");
    $test -> no_match ("(a few words>", reason => "Mismatched delimiters");
    $test -> no_match ("{a few words{",
                reason => "Using opening delimiter as the closing delimiter");
    $test -> no_match (">a few words>",
                reason => "Using closing delimiter as the opening delimiter");
    $test -> no_match ("[a [few] words]",
                reason => "Unescaped closing delimiter");
}


#
# Use less closing delimiters than opening delimiters
#
{
    my $test = make_test "Less closing delimiters than opening delimiters" =>
                         $RE {delimited} { -delim => "\x{AB}<"}
                                         {-cdelim => "\x{BB}"};
    $test -> match ("\x{AB}a few words\x{BB}",
                   ["\x{AB}a few words\x{BB}", "\x{AB}", "a few words",
                                               "\x{BB}"],
                   test => "Using double angled quotation marks");
    $test -> match ("<a few words\x{BB}",
                   ["<a few words\x{BB}", "<", "a few words", "\x{BB}"],
                   test => "Closing delimiter repeats");
}

done_testing;

__END__
