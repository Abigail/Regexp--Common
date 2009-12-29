# VOODOO LINE-NOISE
my($C,$M,$P,$N,$S);END{print"1..$C\n$M";print"\nfailed: $N\n"if$N}
sub ok{$C++; $M.= ($_[0]||!@_)?"ok $C\n":($N++,"not ok $C (".
((caller 1)[1]||(caller 0)[1]).":".((caller 1)[2]||(caller 0)[2]).")\n")}
sub try{$P=qr/^$_[0]$/}sub fail{ok($S=$_[0]!~$P)}sub pass{ok($S=$_[0]=~$P)}

# LOAD

use Regexp::Common;
ok;

# TEST URIs

try $RE{URI}{HTTP};

pass 'http://www.example.com';
pass 'http://www.example.com/';
pass 'http://www.example.com/some/file/some/where';
pass 'http://www.example.com/some/directory/some/where/';
pass 'http://www.example.com:80/some/file';
pass 'http://127.0.0.1';
pass 'http://127.0.0.1/';
pass 'http://127.0.0.1:12345/some/file';
pass 'http://www.example.com/%7Eabigail/';
pass 'http://www.example.com:80/some/path?query';
# Test "safe" chars.
pass 'http://www.example.com/--_$.+++';
pass 'http://www.example.com/.';
# Test "extra" chars.
pass "http://www.example.com/**!(),,''";
# Test HTTP additional chars.
pass 'http://www.example.com/:;@=&=;';
pass 'http://www.example.com/some/path?query';
pass 'http://www.example.com/some/path?funny**!(),,:;@=&=';
pass 'http://www.example.com/some/?';
pass 'http://www.example.com/?';
pass 'http://www.example.com//////////////';
# Usernames/passwords are NOT allowed in http URIs.
fail 'http://abigail@www.example.com';
fail 'http://abigail@www.example.com:80/some/file';
fail 'http://abigail:secret@www.example.com:80/some/file';
fail 'http://abigail:secret@127.0.0.1:80/some/file';
# ~ was NOT allowed by RFC 1738, but currently is.
pass 'http://www.example.com/~abigail/';
# Fail on "national" characters.
fail 'http://www.example.com/nope|nope';
fail 'http://www.example.com/`';
# Fail on "punctation" characters.
fail 'http://www.example.com/some/file#target';
# Two question marks used to be failure, but is now allowed.
pass 'http://www.example.com/some/path?query1?query2';
pass 'http://www.example.com/some/??';
# Can have slashes in query.
pass 'http://www.example.com/some/path?query/path';
# Scheme must be lower case, and correct.
fail 'HTTP://www.example.com/';
fail 'ftp://www.example.com/';
fail 'https://www.example.com/';

try $RE{URI}{HTTP}{-scheme => 'https'};

pass 'https://www.example.com';
pass 'https://www.example.com/';
pass 'https://www.example.com/some/file/some/where';
pass 'https://www.example.com/some/directory/some/where/';
pass 'https://www.example.com:80/some/file';
pass 'https://127.0.0.1';
pass 'https://127.0.0.1/';
pass 'https://127.0.0.1:12345/some/file';
pass 'https://www.example.com/%7Eabigail/';
pass 'https://www.example.com:80/some/path?query';
# Test "safe" chars.
pass 'https://www.example.com/--_$.+++';
pass 'https://www.example.com/.';
# Test "extra" chars.
pass "https://www.example.com/**!(),,''";
# Test HTTP additional chars.
pass 'https://www.example.com/:;@=&=;';
pass 'https://www.example.com/some/path?query';
pass 'https://www.example.com/some/path?funny**!(),,:;@=&=';
pass 'https://www.example.com/some/?';
pass 'https://www.example.com/?';
pass 'https://www.example.com//////////////';
# Usernames/passwords are NOT allowed in http URIs.
fail 'https://abigail@www.example.com';
fail 'https://abigail@www.example.com:80/some/file';
fail 'https://abigail:secret@www.example.com:80/some/file';
fail 'https://abigail:secret@127.0.0.1:80/some/file';
# ~ was NOT allowed by RFC 1738, but currently is.
pass 'https://www.example.com/~abigail/';
# Fail on "national" characters.
fail 'https://www.example.com/nope|nope';
fail 'https://www.example.com/`';
# Fail on "punctation" characters.
fail 'https://www.example.com/some/file#target';
# Two question marks used to be failure, but is now allowed.
pass 'https://www.example.com/some/path?query1?query2';
pass 'https://www.example.com/some/??';
# Can have slashes in query.
pass 'https://www.example.com/some/path?query/path';
# Scheme must be lower case, and correct.
fail 'HTTP://www.example.com/';
fail 'ftp://www.example.com/';
fail 'http://www.example.com/';
