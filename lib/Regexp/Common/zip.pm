package Regexp::Common::zip;

use 5.10.0;

use strict;
use warnings;
no  warnings 'syntax';

use Regexp::Common qw /pattern clean no_defaults/;

our $VERSION = '2016060101';


#
# Prefer '[0-9]' over \d, because the latter may include more
# in Unicode string.
#

#
# ISO and Cept codes. ISO code is the second column, Cept code is
# the third. First column matches either.
#
# http://cept.org/ecc/topics/numbering-networks/numbering-related-
#        cooperation/the-cept-countries-joining-year-to-cept,
#        -cept-and-iso-country-codes,-e164-and-e212-country-codes
# (http://bit.ly/1Ue268b)
#
my %code = (
    Australia         =>  [qw /AUS? AU AUS/],
    Austria           =>  [qw /AU?T AT AUT/],
    Belgium           =>  [qw /BE?  BE B/],
    Denmark           =>  [qw /DK   DK DK/],
    France            =>  [qw /FR?  FR F/],
    Germany           =>  [qw /DE?  DE D/],
    Greenland         =>  [qw /DK   DK DK/],
    Italy             =>  [qw /IT?  IT I/],
    Netherlands       =>  [qw /NL   NL NL/],
    Norway            =>  [qw /NO?  NO N/],
    Spain             =>  [qw /ES?  ES E/],
    USA               =>  [qw /USA? US USA/],
);

# Returns the empty string if the argument is undefined, the argument otherwise.
sub __ {defined $_ [0] ? $_ [0] : ""}

# Used for allowable options. If the value starts with 'y', the option is
# required ("{1,1}" is returned, if the value starts with 'n', the option
# is disallowed ("{0,0}" is returned), otherwise, the option is allowed,
# but not required ("{0,1}" is returned).
sub _t {
    if (defined $_ [0]) {
        if ($_ [0] =~ /^y/i) {return "{1,1}"}
        if ($_ [0] =~ /^n/i) {return "{0,0}"}
    }
    "{0,1}"
}

# Returns the (sub)pattern for the country named '$name', and the 
# -country option '$country'.
sub _c {
    my ($name, $country) = @_;
    if (defined $country && $country ne "") {
        if ($country eq 'iso')  {return $code {$name} [1]}
        if ($country eq 'cept') {return $code {$name} [2]}
        return $country;
    }
    $code {$name} [0]
}


my %zip = (
    Australia   =>
        # Postal codes of the form 'DDDD'. Not all codes are used;
        # postal codes in use are updated quarterly, and can be 
        # found at https://postcode.auspost.com.au/free_display.html?id=1
        #
        # https://en.wikipedia.org/wiki/Postcodes_in_Australia
        #
        "(?k:" .
        "(?|1(?:2(?:15|2[05]|3[05]|40)|"                               .
               "3(?:00|35|40|5[05]|60)|"                               .
               "4(?:35|45|5[05]|6[056]|7[05]|8[015]|9[059])|"          .
               "5(?:15|6[05]|70|85|9[05])|"                            .
               "6(?:3[05]|40|55|60|7[05]|8[05])|"                      .
               "7(?:0[01]|1[05]|30|5[05]|65|90)|"                      .
               "8(?:0[05]|11|25|35|51|60|7[15]|85|90))"                .

          "|2(?:0(?:0[0-246-9]|1[0-25-9]|[2-4][0-9]|5[0279]|"          .
                   "6[0-9]|7[0-79]|8[0-9]|9[02-79])|"                  .
               "1(?:[0-2][0-9]|3[0-8]|4[0-8]|5[0-9]|6[0-8]|"           .
                   "7[0-9]|9[0-9])|"                                   .
               "2(?:0[03-9]|1[0-46-9]|2[0-9]|3[0-4]|5[016-9]|"         .
                   "6[0-57]|78|8[0-79]|9[0-9])|"                       .
               "3(?:0[02-9]|1[0-24-9]|2[0-9]|3[03-9]|4[0-8]|"          .
                   "5[0-9]|6[0159]|7[0-29]|8[0-26-8]|9[05-9])|"        .
               "4(?:0[0-689]|1[015]|2[0-9]|3[019]|4[013-9]|"           .
                   "5[02-6]|6[02-69]|[78][0-9]|90)|"                   .
               "5(?:0[02568]|1[5-9]|2[025-9]|3[03-9]|4[015689]|"       .
                   "5[015-9]|6[03-9]|7[0-9]|8[0-8]|9[04])|"            .
               "6(?:0[0-9]|1[0-24-9]|2[0-9]|3[0-3]|4[0-9]|"            .
                   "5[0-35689]|6[0135689]|7[1258]|8[01])|"             .
               "7(?:0[0-35-8]|1[0-7]|2[0-25-79]|3[0-9]|4[57-9]|"       .
                   "5[0-46-9]|6[0-35-9]|7[03-9]|8[02-7]|9[0-57-9])|"   .
               "8(?:0[03-9]|1[078]|2[0-9]|3[0-689]|4[02-9]|5[02]|"     .
                   "6[4-9]|7[013-9]|80|9[089])|"                       .
               "9(?:0[0-6]|1[1-4]))"                                   .

          "|3(?:0(?:0[0-468]|1[0-35689]|2[0-9]|3[0-46-9]|[45][0-9]|"   .
                   "6[0-8]|7[0-689]|8[1-57-9]|9[013-79])|"             .
               "1(?:0[1-9]|1[13-6]|2[1-9]|[34][0-9]|5[0-689]|"         .
                   "[6-9][0-9])|"                                      .
               "2(?:0[0-24-7]|1[1-9]|2[0-8]|3[0-9]|4[0-39]|5[014]|"    .
                   "6[04-9]|7[0-9]|8[0-79]|9[2-4])|"                   .
               "3(?:0[0-59]|1[0-2457-9]|2[1-589]|3[0-578]|4[0-25]|"    .
                   "5[0-7]|6[0134]|7[013-57-9]|8[014578]|9[0-356])|"   .
               "4(?:0[0-279]|1[2-589]|2[0347-9]|3[0-578]|4[0-246-8]|"  .
                   "5[0138]|6[0-57-9]|7[2578]|8[02357-9]|9[01468])|"   .
               "5(?:0[0-25-79]|1[25-8]|2[0-3579]|3[0137]|4[02469]|"    .
                   "5[0-24-9]|6[1-8]|7[0-3569]|8[013-689]|9[014-79])|" .
               "6(?:0[78]|1[0246-9]|2[0-49]|3[0-9]|4[0134679]|"        .
                   "5[89]|6[0-69]|7[0-35-8]|8[2357-9]|9[01457-9])|"    .
               "7(?:0[01457-9]|1[1-57-9]|2[02-8]|3[0235-9]|4[014679]|" .
                   "5[0-9]|6[0-7]|7[057-9]|8[1-35-9]|9[1-35-79])|"     .
               "8(?:0[02-9]|1[02-68]|2[0-5]|3[1-35]|4[0-247]|"         .
                   "5[0-46-9]|6[02459]|7[013-58]|8[025-9]|9[0-3568])|" .
               "9(?:0[02-49]|1[0-35689]|2[0-35-9]|3[01346-9]|4[0-6]|"  .
                   "5[01346-9]|6[024-7]|7[15-9]|8[01478]|9[0-256]))"   .

          "|4(?:0(?:0[0-9]|1[0-47-9]|2[0-259]|3[0-24-7]|5[13-59]|"     .
                   "6[014-9]|7[02-8])|"                                .
               "1(?:0[1-9]|1[0-9]|2[0-57-9]|3[0-3]|5[1-9]|6[013-59]|"  .
                   "7[0-489]|8[34])|"                                  .
               "2(?:0[57-9]|[12][0-9]|30|7[0-25]|8[057])|"             .
               "3(?:0[013-79]|1[0-3]|4[0-7]|5[02-9]|6[0-5]|7[0-8]|"    .
                   "8[0-578]|90)|"                                     .
               "4(?:0[0-8]|1[0-35-9]|2[0-8]|5[45]|6[12578]|"           .
                   "7[0-2457-9]|8[0-26-9]|9[0-46-8])|"                 .
               "5(?:0[0-9]|1[0-24-9]|2[01]|[56][0-9]|7[0-5]|8[01])|"   .
               "6(?:0[01568]|1[0-5]|2[015-7]|30|5[059]|6[02]|"         .
                   "7[01346-8]|80|9[4579])|"                           .
               "7(?:0[0-79]|1[0-9]|2[0-8]|3[0-35-9]|4[0-6]|5[013467]|" .
                   "9[89])|"                                           .
               "8(?:0[02-9]|1[0-9]|2[0-589]|30|49|5[024-9]|"           .
                   "6[01589]|7[0-9]|8[0-8]|9[0-25]))"                  .

          "|5(?:0(?:0[016-9]|1[0-9]|2[0-5]|3[1-57-9]|4[0-9]|5[0-2]|"   .
                   "6[1-9]|7[0-6]|8[1-9]|9[0-8])|"                     .
               "1(?:0[6-9]|1[0-8]|2[015-7]|3[1-46-9]|4[0-24]|"         .
                   "[56][0-9]|7[0-4])|"                                .
               "2(?:0[1-4]|1[0-4]|2[0-3]|3[1-8]|4[0-5]|5[0-69]|"       .
                   "6[0-9]|7[0-35-9]|80|9[01])|"                       .
               "3(?:0[1-46-9]|1[01]|2[0-2]|3[0-3]|4[0-6]|5[0-7]|"      .
                   "60|7[1-4]|81)|"                                    .
               "4(?:0[01]|1[0-9]|2[0-2]|3[1-4]|40|5[1-5]|6[0-24]|"     .
                   "7[0-3]|8[0-35]|9[0135])|"                          .
               "5(?:0[12]|10|2[0-3]|40|5[024-68]|60|7[0-35-7]|"        .
                   "8[0-3])|"                                          .
               "6(?:0[0-9]|3[0-3]|4[0-2]|5[0-5]|6[01]|7[01]|80|90)|"   .
               "7(?:0[01]|1[09]|2[02-5]|3[0-4])|"                      .
               "9(?:42|50))"                                           .

          "|6(?:0(?:0[013-9]|1[0-24-9]|2[0-9]|3[0-8]|4[1-4]|"          .
                   "[56][0-9]|7[0-46-9]|8[1-4]|90)|"                   .
               "1(?:0[0-9]|1[0-2]|2[1-6]|4[7-9]|[56][0-9]|"            .
                   "7[0-6]|8[0-2])|"                                   .
               "2(?:0[7-9]|1[013-58]|2[013-9]|3[0-36769]|4[034]|"      .
                   "5[1-68]|6[02]|7[15]|8[0-24-68]|90)|"               .
               "3(?:0[24689]|1[1-35-8]|2[0-46-8]|3[0-35-8]|4[1368]|"   .
                   "5[0-35-9]|6[1357-9]|7[0235]|8[3-6]|9[0-8])|"       .
               "4(?:0[13579]|1[0-589]|2[0-9]|3[0-46-8]|4[0235-8]|"     .
                   "5[02]|6[0-35-8]|7[0235-79]|8[0457-9]|90)|"         .
               "5(?:0[1-79]|1[0-9]|2[1258]|3[0-25-7]|5[68]|"           .
                   "6[0246-9]|7[1245])|"                               .
               "6(?:0[35689]|1[2-46]|2[03578]|3[0-2589]|4[026])|"      .
               "7(?:0[157]|1[0-468]|2[0-2568]|3[13]|4[03]|5[1348]|"    .
                   "6[025]|70|9[89])|"                                 .
               "8(?:3[17-9]|4[0-9]|50|65|72|92)|"                      .
               "9(?:0[1-79]|1[0-9]|2[0-69]|3[1-69]|4[1-7]|5[1-9]|"     .
                   "6[013-9]|7[09]|8[1-9]|9[0-27]))"                   .

          "|7(?:0(?:0[0-24-9]|1[0-25-9]|2[0-7]|30|5[0-5])|"            .
               "1(?:09|1[23679]|20|39|40|5[015]|6[23]|7[0-9]|"         .
                   "8[02-7]|90)|"                                      .
               "2(?:09|1[0-6]|4[89]|5[02-9]|6[0-578]|7[05-7]|9[0-2])|" .
               "3(?:0[0-7]|1[056]|2[0-25]|3[01])|"                     .
               "4(?:6[6-9]|70))"                                       .

          "|8(?:0(?:0[1-9]|1[0-2]))"                                   .

          "|9726"                                                      .

          #
          # Place this last, because the leading 0 is optional; if
          # not, matching against "2001" would find "200".
          #
          "|0?(?:200|8(?:0[014]|1[0-5]|2[0-289]|3[0-24-9]|4[05-7]|"    .
                        "5[0-4]|6[0-2]|7[0-5]|8[0156])|909)"           .
        "))",
    
    # "(?k:(?k:[1-8][0-9]|9[0-7]|0?[28]|0?9(?=09))(?k:[0-9]{2}))",
                    # Postal codes of the form 'DDDD', with the first
                    # two digits 02, 08 or 20-97. Leading 0 may be omitted.
                    # 909 and 0909 are valid as well - but no other postal
                    # codes starting with 9 or 09.

    Belgium     =>  "(?k:(?k:[1-9])(?k:[0-9]{3}))",
                    # Postal codes of the form: 'DDDD', with the first
                    # digit representing the province; the others
                    # distribution sectors. Postal codes do not start
                    # with a zero.

    Denmark     =>  "(?k:(?k:[1-9])(?k:[0-9])(?k:[0-9]{2}))",
                    # Postal codes of the form: 'DDDD', with the first
                    # digit representing the distribution region, the
                    # second digit the distribution district. Postal
                    # codes do not start with a zero. Postal codes 
                    # starting with '39' are in Greenland.

    France      =>  "(?k:(?k:[0-8][0-9]|9[0-8])(?k:[0-9]{3}))",
                    # Postal codes of the form: 'DDDDD'. All digits are used.
                    # First two digits indicate the department, and range
                    # from 01 to 98, or 00 for army.

    Germany     =>  "(?k:(?k:[0-9])(?k:[0-9])(?k:[0-9]{3}))",
                    # Postal codes of the form: 'DDDDD'. All digits are used.
                    # First digit is the distribution zone, second a
                    # distribution region. Other digits indicate the
                    # distribution district and postal town.

    Greenland   =>  "(?k:(?k:39)(?k:[0-9]{2}))",
                    # Postal codes of Greenland are part of the Danish
                    # system. Codes in Greenland start with 39.

    Italy       =>  "(?k:(?k:[0-9])(?k:[0-9])(?k:[0-9])(?k:[0-9])(?k:[0-9]))",
                    # First digit: region.
                    # Second digit: province.
                    # Third digit: capital/province (odd for capital).
                    # Fourth digit: route.
                    # Fifth digit: place on route (0 for small places)

    Norway      =>  "(?k:[0-9]{4})",
                    # Four digits, no significance (??).

    Spain       =>  "(?k:(?k:0[1-9]|[1-4][0-9]|5[0-2])(?k:[0-9])(?k:[0-9]{2}))",
                    # Five digits, first two indicate the province.
                    # Third digit: large town, main delivery rounds.
                    # Last 2 digits: delivery area, secondary delivery route
                    #                or link to rural areas.

    Switzerland =>  "(?k:[1-9][0-9]{3})",
                    # Four digits, first is district, second is area,
                    # third is route, fourth is post office number.
);

my %alternatives = (
    Australia    => [qw /Australian/],
    France       => [qw /French/],
    Germany      => [qw /German/],
);


while (my ($country, $zip) = each %zip) {
    my @names = ($country);
    push @names => @{$alternatives {$country}} if $alternatives {$country};
    foreach my $name (@names) {
        my $pat_name = $name eq "Denmark" && $] < 5.00503
                       ?   [zip => $name, qw /-country=/]
                       :   [zip => $name, qw /-prefix= -country=/];
        pattern name    => $pat_name,
                create  => sub {
                    my $pt  = _t $_ [1] {-prefix};

                    my $cn  = _c $country => $_ [1] {-country};
                    my $pfx = "(?:(?k:$cn)-)";

                    "(?k:$pfx$pt$zip)";
                },
                ;
    }
}


# Postal codes of the form 'DDDD LL', with F, I, O, Q, U and Y not
# used, SA, SD and SS unused combinations, and the first digit
# cannot be 0. No specific meaning to the letters or digits.
foreach my $country (qw /Netherlands Dutch/) {
    pattern name   => ['zip', $country => qw /-prefix= -country=/, "-sep= "],
            create => sub {
                my $pt  = _t $_ [1] {-prefix};

                # Unused letters: F, I, O, Q, U, Y.
                # Unused combinations: SA, SD, SS.
                my $num =  '[1-9][0-9]{3}';
                my $let =  '[A-EGHJ-NPRTVWXZ][A-EGHJ-NPRSTVWXZ]|' .
                           'S[BCEGHJ-NPRTVWXZ]';

                my $sep = __ $_ [1] {-sep};
                my $cn  = _c Netherlands => $_ [1] {-country};
                my $pfx = "(?:(?k:$cn)-)";

                "(?k:$pfx$pt(?k:(?k:$num)(?k:$sep)(?k:$let)))";
            },
            ;
}


# Postal codes of the form 'DDDDD' or 'DDDDD-DDDD'. All digits are used,
# none carry any specific meaning.
pattern name    => [qw /zip US -prefix= -country= -extended= -sep=-/],
        create  => sub {
            my $pt  = _t $_ [1] {-prefix};
            my $et  = _t $_ [1] {-extended};

            my $sep = __ $_ [1] {-sep};

            my $cn  = _c USA => $_ [1] {-country};
            my $pfx = "(?:(?k:$cn)-)";
            # my $zip = "(?k:[0-9]{5})";
            # my $ext = "(?:(?k:$sep)(?k:[0-9]{4}))";
            my $zip = "(?k:(?k:[0-9]{3})(?k:[0-9]{2}))";
            my $ext = "(?:(?k:$sep)(?k:(?k:[0-9]{2})(?k:[0-9]{2})))";

            "(?k:$pfx$pt(?k:$zip$ext$et))";
        },
        ;


#
# Postal codes are four digits, but not all combinations are used.
#
# Valid codes from:
#       https://en.wikipedia.org/wiki/List_of_postal_codes_in_Austria
# 
pattern name   => ['zip', 'Austria' => qw /-prefix= -country=/],
        create => sub {
            my $pt  = _t $_ [1] {-prefix};
            my $cn  = _c Austria => $_ [1] {-country};
            my $pfx = "(?:(?k:$cn)-)";
            my $pat = "(?|" .
              "1(?:[0-8][0-9][0-9]|90[01])|"                  .  # 1000 - 1901
              "2(?:[0-3][0-9][0-9]|"                          .  # 2000 - 2399
                  "4(?:0[0-9]|1[0-3]|2[1-5]|3[1-9]|"          .  # 2400 - 2439
                  "[4-6][0-9]|7[0-5]|8[1-9]|9[0-9])|"         .  # 2440 - 2499
                  "[5-7][0-9][0-9]|"                          .  # 2500 - 2799
                  "8(?:[0-7][0-9]|8[01]))|"                   .  # 2800 - 2881
              "3(?:0(?:0[1-9]|[1-9][0-9])|"                   .  # 3001 - 3099
                  "[12][0-9][0-9]|"                           .  # 3100 - 3299
                  "3(?:[0-2][0-9]|3[0-5]|[4-9][0-9])|"        .  # 3300 - 3399
                  "[4-8][0-9][0-9]|"                          .  # 3400 - 3899
                  "9(?:[0-6][0-9]|7[0-3]))|"                  .  # 3900 - 3973
              "4(?:[01][0-9][0-9]|"                           .  # 4000 - 4199
                  "2(?:[0-8][0-9]|9[0-4])|"                   .  # 4200 - 4294
                  "3(?:0[0-3]|[1-8][0-9]|9[0-2])|"            .  # 4300 - 4392
                  "4(?:[0-1][0-9]|2[01]|3[1-9]|[4-9][0-9])|"  .  # 4400 - 4499
                  "[5-8][0-9][0-9]|"                          .  # 4500 - 4899
                  "9(?:[0-7][0-9]|8[0-5]))|"                  .  # 4900 - 4985
              "5(?:0[0-9][0-9]|"                              .  # 5000 - 5099
                  "1(?:0[0-9]|1[0-4]|[23][0-9]|4[0-5]|"       .  # 5100 - 5145
                      "5[1-9]|[6-9][0-9])|"                   .  # 5151 - 5199
                  "2(?:0[0-5]|1[1-9]|[2-7][0-9]|8[0-3])|"     .  # 5200 - 5283
                  "3(?:0[0-3]|1[01]|2[1-9]|[34][0-9]|"        .  # 5300 - 5349
                      "5[01]|60)|"                            .  # 5350 - 5360
                  "[4-6][0-9][0-9]|"                          .  # 5400 - 5699
                  "7(?:[0-6][0-9]|7[01]))|"                   .  # 5700 - 5771
              "6(?:[0-5][0-9][0-9]|"                          .  # 6000 - 6599
                  "6(?:[0-8][0-9]|9[01])|"                    .  # 6600 - 6691
                  "[78][0-9][0-9]|"                           .  # 6700 - 6899
                  "9(?:[0-8][0-9]|9[0-3]))|"                  .  # 6900 - 6993
              "7(?:[0-3][0-9][0-9]|"                          .  # 7000 - 7399
                  "4(?:0[0-9]|1[0-3]|2[1-9]|[3-9][0-9])|"     .  # 7400 - 7499
                  "5(?:[0-6][0-9]|7[0-3]))|"                  .  # 7500 - 7573
              "8(?:[0-2][0-9][0-9]|"                          .  # 8000 - 8299
                  "3(?:[0-5][0-9]|6[0-3]|8[0-5])|"            .  # 8300 - 8385
                  "4(?:0[1-9]|[1-9][0-9])|"                   .  # 8401 - 8499
                  "[5-8][0-9][0-9]|"                          .  # 8500 - 8899
                  "9(?:[0-8][0-9]|9[0-3]))|"                  .  # 8900 - 8993
              "9(?:[0-6][0-9][0-9]|"                          .  # 9000 - 9699
                  "7(?:[0-7][0-9]|8[0-2])|"                   .  # 9700 - 9782
                  "8(?:[0-6][0-9]|7[0-3])|"                   .  # 9800 - 9873
                  "9(?:[0-8][0-9]|9[0-2]))"                   .  # 9900 - 9992
            ")";

            "(?k:$pfx$pt(?k:$pat))";
        }
        ;



# pattern name   => [qw /zip British/, "-sep= "],
#         create => sub {
#             my $sep     = $_ [1] -> {-sep};
# 
#             my $london  = '(?:EC[1-4]|WC[12]|S?W1)[A-Z]';
#             my $single  = '[BGLMS][0-9]{1,2}';
#             my $double  = '[A-Z]{2}[0-9]{1,2}';
# 
#             my $left    = "(?:$london|$single|$double)";
#             my $right   = '[0-9][ABD-HJLNP-UW-Z]{2}';
# 
#             "(?k:(?k:$left)(?k:$sep)(?k:$right))";
#         },
#         ;
# 
# pattern name   => [qw /zip Canadian/, "-sep= "],
#         create => sub {
#             my $sep     = $_ [1] -> {-sep};
# 
#             my $left    = '[A-Z][0-9][A-Z]';
#             my $right   = '[0-9][A-Z][0-9]';
# 
#             "(?k:(?k:$left)(?k:$sep)(?k:$right))";
#         },
#         ;


1;

__END__

=pod

=head1 NAME

Regexp::Common::zip -- provide regexes for postal codes.

=head1 SYNOPSIS

    use Regexp::Common qw /zip/;

    while (<>) {
        /^$RE{zip}{Netherlands}$/   and  print "Dutch postal code\n";
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

This module offers patterns for zip or postal codes of many different
countries. They all have the form C<$RE{zip}{Country}[{options}]>.

The following common options are used:

=head2 C<{-prefix=[yes|no|allow]}> and C<{-country=PAT}>.

Postal codes can be prefixed with a country abbreviation. That is,
a dutch postal code of B<1234 AB> can also be written as B<NL-1234 AB>.
By default, all the patterns will allow the prefixes. But this can be
changed with the C<-prefix> option. With C<-prefix=yes>, the returned
pattern requires a country prefix, while C<-prefix=no> disallows a
prefix. Any argument that doesn't start with a C<y> or a C<n> allows a
country prefix, but doesn't require them.

The prefixes used are, unfortunally, not always the same. Officially,
ISO country codes need to be used, but the usage of I<CEPT> codes (the
same ones as used on cars) is common too. By default, each postal code
will recognize a country prefix that's either the ISO standard or the
CEPT code. That is, German postal codes may prefixed with either C<DE>
or C<D>. The recognized prefix can be changed with the C<-country>
option, which takes a (sub)pattern as argument. The arguments C<iso>
and C<cept> are special, and indicate the language prefix should be the
ISO country code, or the CEPT code.

Examples:
 /$RE{zip}{Netherlands}/;
           # Matches '1234 AB' and 'NL-1234 AB'.
 /$RE{zip}{Netherlands}{-prefix => 'no'}/;
           # Matches '1234 AB' but not 'NL-1234 AB'.
 /$RE{zip}{Netherlands}{-prefix => 'yes'}/;
           # Matches 'NL-1234 AB' but not '1234 AB'.

 /$RE{zip}{Germany}/;
           # Matches 'DE-12345' and 'D-12345'.
 /$RE{zip}{Germany}{-country => 'iso'}/; 
           # Matches 'DE-12345' but not 'D-12345'.
 /$RE{zip}{Germany}{-country => 'cept'}/;
           # Matches 'D-12345' but not 'DE-12345'.
 /$RE{zip}{Germany}{-country => 'GER'}/;
           # Matches 'GER-12345'.

=head2 C<{-sep=PAT}>

Some countries have postal codes that consist of two parts. Typically
there is an official way of separating those parts; but in practise
people tend to use different separators. For instance, if the official
way to separate parts is to use a space, it happens that the space is
left off. The C<-sep> option can be given a pattern as argument which
indicates what to use as a separator between the parts.

Examples:
 /$RE{zip}{Netherlands}/;
           # Matches '1234 AB' but not '1234AB'.
 /$RE{zip}{Netherlands}{-sep => '\s*'}/;
           # Matches '1234 AB' and '1234AB'.

=head2 C<$RE{zip}{Australia}>

Returns a pattern that recognizes Australian postal codes. Australian
postal codes consist of four digits; the first two digits, which range
from '10' to '97', indicate the state. Territories use '02' or '08'
as starting digits; the leading zero is optional. '0909' is the only 
postal code starting with '09' (the leading zero is optional here as
well) - this is the postal code for the Nothern Territory University).
The (optional) country
prefixes are I<AU> (ISO country code) and I<AUS> (CEPT code).
Regexp::Common 2.107 and before used C<$RE{zip}{Australia}>. This is
still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=back

As of version 2016060301, no C<< $4 >> or C<< $5 >> will be set.

=head2 C<< $RE {zip} {Austria} >>

Returns a pattern which recognizes Austian postal codes. Austrian postal
codes consists of 4 digits, but not all possibilities are used. This
pattern matches the postal codes in use. The (optional) country prefixes
are I<AT> (ISO country code) and I<AUT> (CEPT code).

If C<< {-keep} >> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country code prefix.

=back

=head2 C<$RE{zip}{Belgium}>

Returns a pattern than recognizes Belgian postal codes. Belgian postal
codes consist of 4 digits, of which the first indicates the province.
The (optional) country prefixes are I<BE> (ISO country code) and
I<B> (CEPT code).

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The digit indicating the province.

=item $5

The last three digits of the postal code.

=back


=head2 C<$RE{zip}{Denmark}>

Returns a pattern that recognizes Danish postal codes. Danish postal
codes consist of four numbers; the first digit (which cannot be 0),
indicates the distribution region, the second the distribution
district. The (optional) country prefix is I<DK>, which is both
the ISO country code and the CEPT code.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The digit indicating the distribution region.

=item $5

The digit indicating the distribution district.

=item $6

The last two digits of the postal code.

=back


=head2 C<$RE{zip}{France}>

Returns a pattern that recognizes French postal codes. French postal
codes consist of five numbers; the first two numbers, which range
from '01' to '98', indicate the department. The (optional) country
prefixes are I<FR> (ISO country code) and I<F> (CEPT code).
Regexp::Common 2.107 and before used C<$RE{zip}{French}>. This is
still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The department.

=item $5

The last three digits.

=back

=head2 C<$RE{zip}{Germany}>

Returns a pattern that recognizes German postal codes. German postal
codes consist of five numbers; the first number indicating the
distribution zone, the second the distribution region, while the 
latter three indicate the distribution district and the postal town.
The (optional) country prefixes are I<DE> (ISO country code) and
I<D> (CEPT code).
Regexp::Common 2.107 and before used C<$RE{zip}{German}>. This is
still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The distribution zone.

=item $5

The distribution region.

=item $6

The distribution district and postal town.

=back


=head2 C<$RE{zip}{Greenland}>

Returns a pattern that recognizes postal codes from Greenland.
Greenland, being part of Denmark, uses Danish postal codes.
All postal codes of Greenland start with 39.
The (optional) country prefix is I<DK>, which is both
the ISO country code and the CEPT code.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

39, being the distribution region and distribution district for Greenland.

=item $5

The last two digits of the postal code.

=back

=head2 C<$RE{zip}{Italy}>

Returns a pattern recognizing Italian postal codes. Italian postal
codes consist of 5 digits. The first digit indicates the region, the
second the province. The third digit is odd for province capitals,
and even for the province itself. The fourth digit indicates the
route, and the fifth a place on the route (0 for small places, 
alphabetically for the rest).

The country prefix is either I<IT> (the ISO country code), or
I<I> (the CEPT code).

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The region.

=item $5

The province.

=item $6 

Capital or province.

=item $7

The route.

=item $8

The place on the route.

=back

=head2 C<$RE{zip}{Netherlands}>

Returns a pattern that recognizes Dutch postal codes. Dutch postal
codes consist of 4 digits and 2 letters, separated by a space.
The separator can be changed using the C<{-sep}> option, as discussed
above. The (optional) country prefix is I<NL>, which is both the 
ISO country code and the CEPT code. Regexp::Common 2.107 and earlier
used C<$RE{zip}{Dutch}>. This is still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The digits part of the postal code.

=item $5

The separator between the digits and the letters.

=item $6 

The letters part of the postal code.

=back

=head2 C<< $RE{zip}{Norway} >>

Returns a pattern that recognizes Norwegian postal codes. Norwegian
postal codes consist of four digits.

The country prefix is either I<NO> (the ISO country code), or
I<N> (the CEPT code).

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=back

=head2 C<< $RE{zip}{Spain} >>

Returns a pattern that recognizes Spanish postal codes. Spanish postal
codes consist of 5 digits. The first 2 indicate one of Spains fifties
provinces (in alphabetical order), starting with C<00>. The third digit
indicates a main city or the main delivery rounds. The last two digits
are the delivery area, secondary delivery route or a link to rural areas.

The country prefix is either I<ES> (the ISO country code), or
I<E> (the CEPT code).

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The two digits indicating the province.

=item $5

The digit indicating the main city or main delivery route.

=item $6

The digits indicating the delivery area, secondary delivery route
or a link to rural areas.

=back

=head2 C<< $RE{zip}{Switzerland} >>

Returns a pattern that recognizes Swiss postal codes. Swiss postal
codes consist of 4 digits. The first indicates the district, starting
with 1. The second indicates the area, the third, the route, and the
fourth the post office number.

=head2 C<< $RE{zip}{US}{-extended => [yes|no|allow]} >>

Returns a pattern that recognizes US zip codes. US zip codes consist
of 5 digits, with an optional 4 digit extension. By default, extensions
are allowed, but not required. This can be influenced by the 
C<-extended> option. If its argument starts with a C<y>,
extensions are required; if the argument starts with a C<n>,
extensions will not be recognized. If an extension is used, a dash
is used to separate the main part from the extension, but this can
be changed with the C<-sep> option.

The country prefix is either I<US> (the ISO country code), or
I<USA> (the CEPT code).

If C<{-keep}> is being used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The first 5 digits of the postal code.

=item $5

The first three digits of the postal code, indicating a sectional
center or a large city. New in Regexp::Common 2.119.

=item $6

The last 2 digits of the 5 digit part of the postal code, indicating
a post office facility or delivery area. New in Regexp::Common 2.119.

=item $7

The separator between the 5 digit part and the 4 digit part. Up to 
Regexp::Common 2.118, this used to be $5.

=item $8

The 4 digit part of the postal code (if any). Up to Regexp::Common 2.118,
this used to be $6.

=item $9

The first two digits of the 4 digit part of the postal code, indicating
a sector, or several blocks. New in Regexp::Common 2.119.

=item $10

The last two digits of the 4 digit part of the postal code, indicating
a segment or one side of a street. New in Regexp::Common 2.119.

=back

=head3 Questions

=over 4

=item

Can the 5 digit part of the zip code (in theory) start with 000?

=item

Can the 5 digit part of the zip code (in theory) end with 00?

=item

Can the 4 digit part of the zip code (in theory) start with 00?

=item

Can the 4 digit part of the zip code (in theory) end with 00?

=back

=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=over 4

=item L<http://www.columbia.edu/kermit/postal.html>

Frank's compulsive guide to postal addresses.

=item L<http://www.upu.int/post_code/en/addressing_formats_guide.shtml>

Postal addressing systems.

=item L<http://www.uni-koeln.de/~arcd2/33e.htm>

Postal code information.

=item L<http://www.grcdi.nl/linkspc.htm>

Links to Postcode Pages.

=item L<https://postcode.auspost.com.au/free_display.html?id=1>

All Australian postal codes in use.

=item L<http://hdusps.esecurecare.net/cgi-bin/hdusps.cfg/php/enduser/std_adp.php?p_faqid=1014>

Information about US postal codes.

=item L<http://en.wikipedia.org/wiki/Postal_code>

=back

=head1 AUTHORS

Damian Conway S<(I<damian@conway.org>)> and
Abigail S<(I<regexp-common@abigail.be>)>.

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.be>)>.

=head1 BUGS AND IRRITATIONS

Zip codes for most countries are missing.
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
