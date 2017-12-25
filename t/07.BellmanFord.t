use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;

use BellmanFord qw< bellman_ford >;

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

my $fw = bellman_ford(
   distance => sub {
      return $_[0][0] == $_[1][0] ? 0 : $dist_to{$_[0][0]}{$_[1][0]}
   },
   identifier => sub { return $_[0][0] },
   successors => sub { return map {[$_]} keys %{$dist_to{$_[0][0]}} },
   start => [5],
);

isa_ok $fw, 'HASH';
my ($distance, $hp_to, $p_to) = @{$fw}{qw< distance has_path_to path_to >};
isa_ok $_, 'CODE' for ($distance, $hp_to, $p_to);

ok $hp_to->([1]), 'path 5-->1 exists';

my @dists = map { $distance->([$_]) } 1 .. 5;
is_deeply \@dists, [6, 3, 3, 2, 0], 'distances';

my @paths = map { [$p_to->([$_])] } 1 .. 5;
use Data::Dumper;
is_deeply \@paths, [
   [[5], [4], [2], [1]], 
   [[5], [4], [2]],
   [[5], [4], [3]],
   [[5], [4]],
   [[5]]],
   'paths' or diag Dumper $fw->{stuff}[1];

done_testing;
