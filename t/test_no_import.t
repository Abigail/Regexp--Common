# LOAD
BEGIN {print "1..3\n";}

use Regexp::Common qw /no_defaults/;

print "ok 1\n";

print defined &Regexp::Common::URL::pattern ? "not ok 2\n" : "ok 2\n";

# Make sure $; isn't modified.
print $; eq "\034" ? "ok 3" : "not ok 3";
print ' # $; eq "\034"', "\n";

__END__
 
 $Log: test_no_import.t,v $
 Revision 2.101  2003/04/02 20:56:50  abigail
 Test for $;

