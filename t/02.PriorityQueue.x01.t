use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;
use List::Util qw< shuffle >;

use PriorityQueue;

my $pq = PriorityQueue->new;
$pq->put($_) for (11, 9, 72);
is $pq->pop, 9, 'regression - first comes 3';
is $pq->pop, 11, 'regression - then 11';
is $pq->pop, 72, 'regression - then 72';

done_testing;
