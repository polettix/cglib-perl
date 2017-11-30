use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;
use List::Util qw< shuffle >;

use PriorityQueue;

{
   my $pq = PriorityQueue->new;
   $pq->put($_) for qw< 6 8 10 13 15 2 11 12 9 1 4 14 5 3 7 >;
   is $pq->size, 15, 'regression - initial size';
   $pq->remove(3);
   is $pq->size, 14, 'regression - size after removing 3';
   ok $pq->contains(11), 'regression - still contains 11';
   $pq->remove(11);
   ok !$pq->contains(11), 'regression - does not contain 11 any more';
   is $pq->size, 13, 'regression - size after removing 11';
   $pq->remove(4);
   is $pq->size, 12, 'regression - size after removing 4';
}

done_testing;
