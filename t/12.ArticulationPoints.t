use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Data::Dumper;

use ArticulationPoints qw< articulation_points >;

{
   my @adj_for = (
      [1, 2, 3],
      [0, 2],
      [0, 1],
      [0, 4],
      [3],
   );
   test(\@adj_for, [0, 3],
      '1st in https://www.geeksforgeeks.org/'
      .'articulation-points-or-cut-vertices-in-a-graph/');
}

{
   my @adj_for = (
      [1],
      [0, 2],
      [1, 3],
      [2],
   );
   test(\@adj_for, [1, 2],
      '2nd in https://www.geeksforgeeks.org/'
      .'articulation-points-or-cut-vertices-in-a-graph/');
}

{
   my @adj_for = (
      [1, 2],
      [0, 2, 3, 4, 6],
      [0, 1],
      [1, 5],
      [1, 5],
      [3, 4],
      [1],
   );
   test(\@adj_for, [1],
      '3rd in https://www.geeksforgeeks.org/'
      .'articulation-points-or-cut-vertices-in-a-graph/');
}

{
   my @adj_for = (
      [1, 2],
      [0, 3],
      [0, 3],
      [1, 2, 4],
      [3, 5],
      [4, 6],
      [7, 8, 9],
      [6],
      [6, 10, 11],
      [6, 12, 13],
      [8, 11],
      [8, 10, 12],
      [9, 11],
      [9]
   );
   test(\@adj_for, [3, 4, 5, 6, 9],
      'https://en.wikipedia.org/wiki/Biconnected_component');
}

sub test {
   my ($adj_for, $expected, $title) = @_;
   my @aps = sort {$a <=> $b} articulation_points(
      successors => sub { return @{$adj_for->[$_[0]]} },
      start => 0,
   );
   is_deeply \@aps, $expected, $title or diag "--> (@aps)";
   return;
}

done_testing;
