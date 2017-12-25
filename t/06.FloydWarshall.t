use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;

use FloydWarshall qw< floyd_warshall >;

my %dist_to = (
   1 => {
      3 => 6,
      4 => 3,
   },
   2 => { 1 => 3 },
   3 => { 4 => 2 },
   4 => {
      2 => 1,
      3 => 1,
   },
   5 => {
      2 => 4,
      4 => 2,
   },
);

my $fw = floyd_warshall(
   distance => sub {
      return $_[0][0] == $_[1][0] ? 0 : $dist_to{$_[0][0]}{$_[1][0]}
   },
   identifier => sub { return $_[0][0] },
   successors => sub { return map {[$_]} keys %{$dist_to{$_[0][0]}} },
   start => [5],
);

isa_ok $fw, 'HASH';
my ($distance, $has_path, $path) = @{$fw}{qw< distance has_path path >};
isa_ok $_, 'CODE' for ($distance, $has_path, $path);

ok !$has_path->([1], [5]), 'path 1-->5 does not exist';
ok $has_path->([5], [1]), 'path 5-->1 exists';

my @dists = map {
   my $v = [$_];
   [map { $distance->($v, [$_]) // undef } 1 .. 5];
} 1 .. 5;
is_deeply \@dists, [
   [0, 4, 4, 3, undef],
   [3, 0, 7, 6, undef],
   [6, 3, 0, 2, undef],
   [4, 1, 1, 0, undef],
   [6, 3, 3, 2, 0],
], 'distances';

my @paths = map {
   my $v = [$_];
   [map { [$path->($v, [$_])] } 1 .. 5];
} 1 .. 5;
use Data::Dumper;
is_deeply \@paths, [
   [[[1]], [[1], [4], [2]], [[1], [4], [3]], [[1], [4]], []],
   [[[2], [1]], [[2]], [[2], [1], [4], [3]], [[2], [1], [4]], []],
   [[[3], [4], [2], [1]], [[3], [4], [2]], [[3]], [[3], [4]], []],
   [[[4], [2], [1]], [[4], [2]], [[4], [3]], [[4]], []],
   [[[5], [4], [2], [1]], [[5], [4], [2]], [[5], [4], [3]], [[5], [4]], [[5]]],
], 'paths' or diag Dumper $fw->{stuff}[1];

done_testing;
