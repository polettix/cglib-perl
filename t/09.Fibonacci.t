use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;

use Fibonacci qw< fibonacci_nth fibonacci_nth_bi >;

my @fbs = qw< 0 1 1 2 3 5 8 13 21 34 55 89 >;

is fibonacci_nth($_), $fbs[$_], "fibonacci_nth($_)" for 0 .. $#fbs;
is fibonacci_nth_bi($_), $fbs[$_], "fibonacci_nth_bi($_)" for 0 .. $#fbs;

chomp(my $res = <DATA>);
is length($res), 165, 'correctly read DATA';
my $f789 = fibonacci_nth_bi(789);
is $f789, $res, 'fibonacci_nth_bi(789)';
is length($f789), 165, 'correctly handling fibonacci_nth_bi(789)';

done_testing;

__END__
348147399115490473298491045414894562475320947656181150098909190608449577072992416624176576404665376671883958803044029437264675531681752487564893783189344220686328514
