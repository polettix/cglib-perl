use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;

use DepthFirstVisit;

my %adjacents_for = (
   1 => [2, 3, 4],
   2 => [1, 4],
   3 => [1, 5],
   4 => [1, 2, 5],
   5 => [4],
);

my %args = (
   start => 1,
   successors => sub { return @{$adjacents_for{$_[0]}} },
);

my @reachable;
lives_ok {@reachable = DepthFirstVisit::depth_first_visit(%args)}
   'depth_first_visit lives';

is_deeply [sort {$a <=> $b} @reachable], [1..5], 'reachability return value';

my $reachable = DepthFirstVisit::depth_first_visit(\%args);
is_deeply [sort @$reachable], [1..5], 'working with refs';

{
   my @collected;
   $args{pre_action} = sub { push @collected, $_[0] };
   DepthFirstVisit::depth_first_visit(\%args);
   is_deeply \@collected, [1, 2, 4, 5, 3], 'pre_action' or diag "@collected";
}

{
   my @collected;
   $args{post_action} = sub { push @collected, $_[0] };
   DepthFirstVisit::depth_first_visit(\%args);
   is_deeply \@collected, [5, 4, 2, 3, 1], 'post_action' or diag "@collected";
}

{
   my %pred_of;
   $args{pre_action} = sub { $pred_of{$_[0]} = $_[1] };
   DepthFirstVisit::depth_first_visit(\%args);
   is_deeply \%pred_of, {1 => undef, 2 => 1, 4 => 2, 5 => 4, 3 => 1}, 'pre_action, path collection';
}

done_testing;
