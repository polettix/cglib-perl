use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;
use List::Util qw< shuffle >;

use PriorityQueue;

my $pq;
lives_ok { $pq = PriorityQueue->new } 'constructor';
isa_ok $pq, 'PriorityQueue';

ok $pq->is_empty, 'is_empty - starts empty';
is $pq->size, 0, 'size - starting size is correct';

$pq->put(10);
ok !$pq->is_empty, 'is_empty - not empty any more';
is $pq->size, 1, 'size - one element inside';
is $pq->top, 10, 'top - element is right';
is $pq->size, 1, 'size- top did not change anything';

$pq->put(12);
is $pq->size, 2, 'size - two elements inside';
is $pq->top, 10, 'top - element is still right';

$pq->put(9);
is $pq->size, 3, 'size - three elements inside';
is $pq->top, 9, 'top - element changed, and it is right';

{
   $pq->put($_) for shuffle 1 .. 15;
   is $pq->size, 15, 'added a bunch, in random order';
   my @collected;
   push @collected, $pq->pop until $pq->is_empty;
   is_deeply \@collected, [1..15], 'extraction was in right order';
}

{
   $pq->put($_) for shuffle 2 .. 15;
   my $id1 = $pq->put(1);
   is $pq->top_id, $id1, 'top_id';

   my $id13 = $pq->put(13);
   is $pq->size, 15, 'put - present element does not increase size';
   ok $pq->contains_id($id13), 'contains_id - present item';
   is $pq->item_of($id13), 13, 'item_of';

   $pq->remove(10);
   is $pq->size, 14, 'remove - removed something';
   $pq->remove_id($id13);
   is $pq->size, 13, 'remove_id - removed something';

   ok $pq->contains(12), 'contains - present item';
   ok !$pq->contains(10), 'contains - removed item';
   ok !$pq->contains(22), 'contains - never existed item';
   ok !$pq->contains(13), 'contains - removed item, via remove_id';
   ok !$pq->contains_id($id13), 'contains_id - removed item';

   my @collected;
   push @collected, $pq->pop until $pq->is_empty;
   is_deeply \@collected, [1..9, 11, 12, 14, 15], 'extraction was fine';
}

my $n_random = 1_000;
my $outcome;
for (1 .. $n_random) {
   $outcome = random_run() or next;
   last;
}
ok !$outcome, "$n_random random tests"
   or diag "put(@{$outcome->[0]}) remove(@{$outcome->[1]})";

sub random_run {
   my $pq = PriorityQueue->new;
   my $n_elements = 1 + rand(30);
   my $n_removed = 1 + int(rand($n_elements) / 5);
   my @elements = 1 .. $n_elements;
   my @shuffled = shuffle @elements;
   $pq->put($_) for @shuffled;
   my @removed;
   for (1 .. $n_removed) {
      my $index = int(rand @elements);
      my $item = splice @elements, $index, 1;
      push @removed, $item;
      $pq->remove($item);
   }
   while (! $pq->is_empty) {
      my $got = $pq->pop or return [\@shuffled, \@removed];
      my $exp = shift @elements;
      return [\@shuffled, \@removed] unless $got == $exp;
   }
   return;
}

done_testing;
