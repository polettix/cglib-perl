use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;
use List::Util qw< shuffle >;

use PriorityQueue;

my $pq = PriorityQueue->new;
$pq->enqueue($_) for (11, 9, 72);
is $pq->dequeue, 9, 'regression - first comes 3';
is $pq->dequeue, 11, 'regression - then 11';
is $pq->dequeue, 72, 'regression - then 72';

done_testing;
