use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use UnionFind;

my $uf = UnionFind->new(identifier => sub {'X' . $_[0][0]});
isa_ok $uf, 'UnionFind';

$uf->add([$_]) for 1 .. 9;
is $uf->count, 9, 'count';
is_deeply $uf->find([7]), [7], 'find';
is $uf->find_id([3]), 'X3', 'find_id';
$uf->union([2], [5]);
$uf->union([1], [8]);
is $uf->count, 7, 'count';
$uf->union([1], [5]);
is $uf->count, 6, 'count';
$uf->union([2], [8]);
is $uf->count, 6, 'count';
ok $uf->connected([1], [2]), 'connected';
ok !$uf->connected([1], [9]), 'connected (negative test)';

done_testing;
