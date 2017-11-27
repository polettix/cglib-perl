package Astar;
use strict;
use MaxPQ;

sub astar {    # parameters validation
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $start = $args{start}      || die "missing parameter 'start'";
   my $goal  = $args{goal}       || die "missing parameter 'goal'";
   my $dist  = $args{distance}   || die "missing parameter 'distance'";
   my $succs = $args{successors} || die "missing parameter 'successors'";
   my $h     = $args{heuristic}  || $dist;
   my $id_of = $args{identifier} || sub { return "$_[0]" };

   my ($id, $gid) = ($id_of->($start), $id_of->($goal));
   my %node_for = ($id => {value => $start, g => 0});
   my $queue = MaxPQ->new(
      less_than => sub { $_[0]{f} >= $_[1]{f} },    # need a MinPQ
      data => [{id => $id, f => 0}],    # f is invariant for start node
   );

   while (!$queue->is_empty) {
      my $cid = $queue->delete_max->{id};
      my $cx  = $node_for{$cid};
      next if $cx->{visited}++;

      my $cv = $cx->{value};
      return __unroll($cx, \%node_for) if $cid eq $gid;

      for my $sv ($succs->($cv)) {
         my $sid = $id_of->($sv);
         my $sx = $node_for{$sid} ||= {value => $sv};
         next if $sx->{visited};

         my $g = $cx->{g} + $dist->($cv, $sv);
         next if defined($sx->{g}) && ($g >= $sx->{g});
         @{$sx}{qw< p g >} = ($cid, $g);    # p: id of best "previous"
         $queue->insert({id => $sid, f => $g + $h->($sv, $goal)});
      } ## end for my $sv ($succs->($cv...))
   } ## end while (!$queue->is_empty)

   return;
} ## end sub Astar

sub __unroll {    # unroll the path from start to goal
   my ($node, $node_for, @path) = ($_[0], $_[1], $_[0]{value});
   while (defined(my $p = $node->{p})) {
      $node = $node_for->{$p};
      unshift @path, $node->{value};
   }
   return wantarray ? @path : \@path;
} ## end sub __unroll

1;
