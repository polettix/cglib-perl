package DijkstraFunction;
use strict;
use PriorityQueue;
use Exporter qw< import >;
our @EXPORT_OK = qw< dijkstra >;

=pod

=head1 SYNOPSIS

   use DijkstraFunction qw< dijkstra >;

   # Arguments, M for Mandatory, O for Optional
   my %args = (
      start      => $node1, # M, node in your graph
      distance   => \&dsub, # M, subref, takes 2 nodes, returns number
      successors => \&ssub, # M, subref, takes 1 node, returns nodes list
      identifier => \&dsub, # O, subref, takes 1 node, returns id,
                            #    defaults to stringification of input node
      goals      => \@aref, # O, list of nodes in your graph, defaults all
   );

   my $href = dijkstra(%args) # works with \%args too

   my $distance = $href->{distance_to}->($goal); # number or undef
   my @path = $href->{path_to}->($goal); # list
   my $path = $href->{path_to}->($goal); # ref array

=head1 NOTES

Implementation of the Dijkstra algorithm for single-source minimum
distance. Leverages C<PriorityQueue> for efficiency in node selection.

This version returns a hash reference with two keys inside, both
pointing to a sub reference:

=over C<path_to>

takes a vertex, returns a path to the vertex. It returns a list if
called in list context, otherwise it returns a reference to an array.

=over C<distance_to>

takes a vertex, returns distance to it (or undef if the source is not
connected to the target vertex).

=cut

sub dijkstra {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start distance successors >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($start, $dist, $succs) = @args{@reqs};
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my %is_goal = map { $id_of->($_) => 1 } @{$args{goals} || []};
   my $on_goal = scalar(keys %is_goal) ? $args{on_goal} || sub {
      delete $is_goal{$_[0]};
      return scalar keys %is_goal;
   } : undef;

   my $id      = $id_of->($start);
   my $queue   = PriorityQueue->new(
      before => sub { $_[0]{d} < $_[1]{d} },
      id_of  => sub { return $_[0]{id} },
      items => [{v => $start, id => $id, d => 0}],
   );

   my %thread_to = ($id => {d => 0, p => undef, pid => $id});
   while (!$queue->is_empty) {
      my ($ug, $uid, $ud) = @{$queue->dequeue}{qw< v id d >};
      last if $on_goal && $is_goal{$uid} && (!$on_goal->($uid));
      for my $vg ($succs->($ug)) {
         my ($vid, $alt) = ($id_of->($vg), $ud + $dist->($ug, $vg));
         $queue->contains_id($vid)
           ? ($alt >= ($thread_to{$vid}{d} //= $alt + 1))
           : exists($thread_to{$vid})
           and next;
         $queue->enqueue({v => $vg, id => $vid, d => $alt});
         $thread_to{$vid} = {d => $alt, p => $ug, pid => $uid};
      } ## end for my $vg ($succs->($ug...))
   } ## end while (!$queue->is_empty)

   return {
      path_to => sub {
         my ($v) = @_;
         my $vid = $id_of->($v);
         my $thr = $thread_to{$vid} || return; # connected?

         my @retval;
         while ($v) {
            unshift @retval, $v;
            ($v, $vid) = @{$thr}{qw< p pid >};
            $thr = $thread_to{$vid};
         }
         return wantarray ? @retval : \@retval;
      },
      distance_to => sub { ($thread_to{$id_of->($_[0])} || {})->{d} },
   };
} ## end sub dijkstra

1;
