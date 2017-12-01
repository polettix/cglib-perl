package Astar;    # A*: https://en.wikipedia.org/wiki/A*_search_algorithm
use strict;       # MinPQ: https://algs4.cs.princeton.edu/24pq/

=pod

=head1 SYNOPSIS

   use AstarX; # shouldn't need this if you embed

   # Arguments, M for Mandatory, O for Optional
   my %args = (
      start      => $node1, # M, node in your graph
      goal       => $node2, # M, node in your graph
      distance   => \&dsub, # M, subref, takes 2 nodes, returns number
      successors => \&ssub, # M, subref, takes 1 node, returns nodes list
      heuristic  => \&dsub, # O, subref like distance, defaults to distance
      identifier => \&dsub, # O, subref, takes 1 node, returns id,
                            #    defaults to stringification of input node
   );

   # get a list back
   @path = Astar::astar(%args);
   @path = Astar::astar(\%args); # works with reference to hash too

   # get an array reference back, containing the list above
   $path = Astar::astar(%args);
   $path = Astar::astar(\%args); # works with reference to hash too

=head1 NOTES

The module file is C<AstarX.pm> but the package inside is C<Astar>. It's an
adaptation of C<Astar.pm> to also include a min priority queue (adapted
from C<BasicPriorityQueue.pm>) for maximum compactness.

=cut

sub astar {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $start = $args{start}      || die "missing parameter 'start'";
   my $goal  = $args{goal}       || die "missing parameter 'goal'";
   my $dist  = $args{distance}   || die "missing parameter 'distance'";
   my $succs = $args{successors} || die "missing parameter 'successors'";
   my $h     = $args{heuristic}  || $dist;
   my $id_of = $args{identifier} || sub { return "$_[0]" };

   my ($id, $gid) = ($id_of->($start), $id_of->($goal));
   my %node_for = ($id => {value => $start, g => 0});
   my $queue = bless ['-', {id => $id, f => 0}], __PACKAGE__;

   while (!$queue->_is_empty) {
      my $cid = $queue->_dequeue->{id};
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
         $queue->_enqueue({id => $sid, f => $g + $h->($sv, $goal)});
      } ## end for my $sv ($succs->($cv...))
   } ## end while (!$queue->_is_empty)

   return;
} ## end sub astar

sub _dequeue {                              # includes "sink"
   my ($k, $self) = (1, @_);
   my $r = ($#$self > 1) ? (splice @$self, 1, 1, pop @$self) : pop @$self;
   while ((my $j = $k * 2) <= $#$self) {
      ++$j if ($j < $#$self) && ($self->[$j + 1]{f} < $self->[$j]{f});
      last if $self->[$k]{f} < $self->[$j]{f};
      (@{$self}[$j, $k], $k) = (@{$self}[$k, $j], $j);
   }
   return $r;
} ## end sub _dequeue

sub _enqueue {                              # includes "swim"
   my ($self, $node) = @_;
   push @$self, $node;
   my $k = $#$self;
   (@{$self}[$k / 2, $k], $k) = (@{$self}[$k, $k / 2], int($k / 2))
     while ($k > 1) && ($self->[$k]{f} < $self->[$k / 2]{f});
} ## end sub _enqueue

sub _is_empty { return !$#{$_[0]} }

sub __unroll {    # unroll the path from start to goal
   my ($node, $node_for, @path) = ($_[0], $_[1], $_[0]{value});
   while (defined(my $p = $node->{p})) {
      $node = $node_for->{$p};
      unshift @path, $node->{value};
   }
   return wantarray ? @path : \@path;
} ## end sub __unroll

1;
