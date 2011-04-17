# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST URIs

try $RE{URI};

for my $scheme (qw [http https]) {
  pass "$scheme://www.example.com";
  pass "$scheme://www.example.com/";
  pass "$scheme://www.example.com/some/file/some/where";
  pass "$scheme://www.example.com/some/directory/some/where";
  pass "$scheme://www.example.com:80/some/file";
  pass "$scheme://127.0.0.1";
  pass "$scheme://127.0.0.1/";
  pass "$scheme://127.0.0.1:12345/some/file";
  pass "$scheme://www.example.com:80/some/path?query";
  pass "$scheme://www.example.com/%7Eabigail/";
  # Test "safe" chars.
  pass "$scheme://www.example.com/--_\$.+++";
  pass "$scheme://www.example.com/.";
  # Test "extra" chars.
  pass "$scheme://www.example.com/**!(),,''";
  # Test HTTP additional chars.
  pass "$scheme://www.example.com/:;\@=&=;";
  pass "$scheme://www.example.com/some/path?query";
  pass "$scheme://www.example.com/some/path?funny**!(),,:;\@=&=";
  pass "$scheme://www.example.com/some/?";
  pass "$scheme://www.example.com/?";
  pass "$scheme://www.example.com//////////////";
  # Usernames/passwords are NOT allowed in http URIs.
  fail "$scheme://abigail\@www.example.com";
  fail "$scheme://abigail\@www.example.com:80/some/file";
  fail "$scheme://abigail:secret\@www.example.com:80/some/file";
  fail "$scheme://abigail:secret\@127.0.0.1:80/some/file";
  # ~ was NOT allowed by RFC 1738, but currently is.
  pass "$scheme://www.example.com/~abigail/";
  # Fail on "national" characters.
  fail "$scheme://www.example.com/nope|nope";
  fail "$scheme://www.example.com/`";
  # Fail on "punctation" characters.
  fail "$scheme://www.example.com/some/file#target";
  # Two question marks used to be failure, but is now allowed.
  pass "$scheme://www.example.com/some/path?query1?query2";
  pass "$scheme://www.example.com/some/??";
  # Can have slashes in query.
  pass "$scheme://www.example.com/some/path?query/path";
}
# Scheme must be lower case, and correct.
fail 'HTTP://www.example.com/';
fail 'HTTPS://www.example.com/';

pass 'ftp://ftp.example.com';
pass 'ftp://ftp.example.com/';
pass 'ftp://ftp.example.com/some/file/some/where';
pass 'ftp://ftp.example.com/some/directory/some/where/';
pass 'ftp://ftp.example.com:21/some/file';
pass 'ftp://127.0.0.1';
pass 'ftp://127.0.0.1/';
pass 'ftp://127.0.0.1:12345/some/file';
pass 'ftp://ftp.example.com/%7Eabigail/';
fail 'ftp://ftp.example.com:21/some/path?query';
# Test "safe" chars.
pass 'ftp://ftp.example.com/--_$.+++';
pass 'ftp://ftp.example.com/.';
# Test "extra" chars.
pass "ftp://ftp.example.com/**!(),,''";
# Test URI additional chars.
pass 'ftp://www.example.com/:@=&=';
pass 'ftp://www.example.com//////////////';
# Should fail on ';'.
fail 'ftp://www.example.com/some/path;here';
# Usernames/passwords are allowed in ftp URIs.
pass 'ftp://abigail@ftp.example.com';
pass 'ftp://abigail@ftp.example.com:21/some/file';
pass 'ftp://abigail:secret@ftp.example.com:21/some/file';
pass 'ftp://abigail:secret@127.0.0.1:21/some/file';
pass 'ftp://abigail:secret:here@127.0.0.1:21/some/file';
# ~ was NOT allowed by RFC 1738, but currently is.
pass 'ftp://ftp.example.com/~abigail/';
# Fail on "national" characters.
fail 'ftp://ftp.example.com/nope|nope';
fail 'ftp://ftp.example.com/`';
# Fail on "punctation" characters.
fail 'ftp://www.example.com/some/file#target';
# Cannot have queries.
fail 'ftp://ftp.example.com/some/path?query1?query2';
fail 'ftp://ftp.example.com/some/??';
fail 'ftp://ftp.example.com/some/path?query/path';
# Test type.
pass 'ftp://ftp.example.com/some/path;type=A';
pass 'ftp://ftp.example.com/some/path;type=i';
pass 'ftp://abigail@ftp.example.com/some/path/somewhere;type=a',
fail 'ftp://ftp.example.com/some/path;type=Q';
fail 'ftp://ftp.example.com/some/path;type=AI';
pass 'ftp://ftp.example.com/;type=I';
# Scheme must be lower case, and correct.
fail 'HTTP://ftp.example.com/';
fail 'FTP://ftp.example.com/';
fail 'feeble://ftp.example.com/';

pass 'tel:+12345';
pass 'tel:+358-555-1234567';
pass 'tel:456-7890;phone-context=213';
pass 'tel:456-7890;phone-context=X-COMPANY-NET';
pass 'tel:+1-212-555-1234;tsp=terrifictelecom.com';
pass 'tel:+1-212-555-1234;tsp=terrifictelecom.com;phone-context=X-COMPANY-NET';
pass 'tel:+358-555-1234567;postd=pp22';
pass 'tel:0w003585551234567;phone-context=+3585551234';
pass 'tel:+1234567890;phone-context=+1234;vnd.company.option=foo';
pass 'tel:+1234567890;phone-context=+1234;vnd.company.option=%22foo%22';
pass 'tel:+1234;option=%22!%22';
pass 'tel:+1234;option=%22%5C%22%22';
pass 'tel:+1234;option=%22%5C!%22';
pass 'tel:+1234;option=%22bar%22';
pass 'tel:+456-7890;phone-context=213;phone-context=213';
pass 'tel:456-7890;phone-context=213;phone-context=213';
fail 'tel:456-7890';
fail 'tel:+1-800-RUN-PERL';
fail 'tel:+1234;option=%22%22%22';
fail 'tel:+1234;option=%22%5C%22';
pass 'tel:+123-456-789;isub=123(456)';
pass 'tel:+123456;postd=***';

# RT 52309 This 'hangs'
pass 'news:comp.infosystems.www.servers.unix';
