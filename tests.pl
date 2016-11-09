use v5.24;
use Date;
use Test::More tests => 5;
use Test::Exception;

my @subs = qw(new days day month year addYears addMonths weekday toString addDays subDays);

subtest 'Test module' => sub {
	plan tests => scalar @subs;
	can_ok('Date', $_) for (@subs);
};

my ($date1, $date2, $date3, $date3);

subtest 'Test date creation' => sub { 
	plan tests => 5;
	new_ok('Date' => ['1.1.1']);
	new_ok('Date' => ['01.01.1']);
	$date1 = Date->new('01.11.2016');
	cmp_ok($date1->days, '==', 736574, 'from string');
	$date2 = Date->new(736208);
	cmp_ok($date2->days, '==', 736208, 'from number of days');
	$date3 = Date->new($date2);
	cmp_ok($date3->days, '==', 736208, 'from another date');
};

subtest 'Test date props and subs' => sub {
	plan tests => 7;
	cmp_ok($date1->day, '==',  1, 'day');
	cmp_ok($date1->month, '==',  11, 'month');
	cmp_ok($date1->year, '==',  2016, 'year');
	ok($date1->isLeap, 'leap');
	ok(!($date2->isLeap), 'not leap');
	is($date1->weekday, 'Tuesday', 'weekday');
	like("$date1", qr/1.11.2016/, 'date as string');
};

subtest 'Test date operations' => sub {
	plan tests => 10;
	$date1 += 100;
	cmp_ok($date1->days, '==', 736674, 'days addition, plus operator overload');
	$date1 -= 100;
	cmp_ok($date1->days, '==', 736574, 'days subtraction, minus operator overload');
	$date1->addMonths(13);
	is_deeply([ $date1->days, $date1->month, $date1->year ], [ 737000, 1, 2018 ], 'months addition');
	$date1->addMonths(-13);
	is_deeply([ $date1->days, $date1->month, $date1->year ], [ 736574, 11, 2016 ], 'months subtraction');
	$date1->addYears(2);
	is_deeply([ $date1->days, $date1->year ], [ 737304, 2018 ], 'years addition');
	$date1->addYears(-2);
	is_deeply([ $date1->days, $date1->year ], [ 736574, 2016 ], 'years subtraction');
	$date1->day(15);
	cmp_ok($date1->days, '==', 736588, 'set day property');
	$date1->month(10);
	cmp_ok($date1->days, '==', 736557, 'set month property');
	$date1->year(1000);
	cmp_ok($date1->days, '==', 365470, 'set year property');
	cmp_ok(Date->new('2.11.2016') - Date->new('1.11.2016'), '==', 1, 'dates subtraction');
};

subtest 'Test exceptions' => sub {
	plan tests => 27;
	throws_ok(sub { Date->new('32.1.1') }, qr/Incorrect day value for January in 1 : 32.*/, 'invalid constructor date with day 32');
	throws_ok(sub { Date->new('0.1.1') }, qr/Incorrect day value for January in 1 : 0.*/, 'invalid constructor date with day 0');
	throws_ok(sub { Date->new('-1.1.1') }, qr/Incorrect day value for January in 1 : -1.*/, 'invalid constructor date with day -1');
	throws_ok(sub { Date->new('29.2.2015') }, qr/Incorrect day value for February in 2015 : 29.*.*/, 'invalid constructor date with day 28 for not leap year');
	throws_ok(sub { Date->new('1.13.1') }, qr/Incorrect month value: 13.*/, 'invalid constructor date with month 13');
	throws_ok(sub { Date->new('1.0.1') }, qr/Incorrect month value: 0.*/, 'invalid constructor date with month 0');
	throws_ok(sub { Date->new('1.-1.1') }, qr/Incorrect month value: -1.*/, 'invalid constructor date with month -1');
	throws_ok(sub { Date->new({1, 2}) }, qr/Passing invalid date: .*/, 'wrong constructor parameter');
	throws_ok(sub { Date->new() }, qr/Passing no arguments.*/, 'no constructor parameter');
	throws_ok(sub { my $date = Date->new('31.01.2016'); $date->month(2); }, qr/Incorrect day value for February in 2016 : 31.*.*/, 'invalid day setting for new month');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->day(31); }, qr/Incorrect day value for February in 2016 : 31.*.*/, 'invalid day setting for current month');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->day(0); }, qr/Incorrect parameter: .*/, 'invalid day setting (0)');
	throws_ok(sub { my $date = Date->new('28.02.2015'); $date->day(29); }, qr/Incorrect day value for February in 2015 : 29.*.*/, 'invalid day setting (29) for February 2015');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->month(13); }, qr/Incorrect month value: 13.*/, 'invalid month setting (13)');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->month(0); }, qr/Incorrect parameter: .*/, 'invalid month setting (0)');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->day([1, 2, 3]); }, qr/Incorrect parameter: .*/, 'invalid day setting (NaN)');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->month([1, 2, 3]); }, qr/Incorrect parameter: .*/, 'invalid month setting (NaN)');
	throws_ok(sub { my $date = Date->new('29.02.2016'); $date->year([1, 2, 3]); }, qr/Incorrect parameter: .*/, 'invalid year setting (NaN)');
	throws_ok(sub { my $date = Date->new('29/02/2016') }, qr/Inapropriate format: .*/, 'invalid constructor date format');
	throws_ok(sub { my $date = Date->new('1.1.0'); }, qr/Inapropriate format: .*/, 'invalid constructor date with year 0');
	throws_ok(sub { my $date = Date->new('01.01.01'); }, qr/Inapropriate format: .*/, 'invalid constructor date with year 01');
	throws_ok(sub { $date1 += 'quuux' }, qr/Incorrect parameter: .*/, 'addition of NaN');
	throws_ok(sub { $date1 -= 'quuux' }, qr/Incorrect parameter: .*/, 'subtraction of NaN');
	throws_ok(sub { $date1->addYears('quuux') },  qr/Incorrect parameter: .*/, 'addYears(NaN)');
	throws_ok(sub { $date1->addMonths('quuux') },  qr/Incorrect parameter: .*/, 'addMonths(NaN)');
	throws_ok(sub { $date1->year(0) }, qr/Incorrect parameter: .*/, 'invalid year setting (0)');
	throws_ok(sub { Date->new('2.11.2016') - Date->new('3.11.2016') }, qr/Incorrect parameter: .*/, 'invalid dates subtraction');
};