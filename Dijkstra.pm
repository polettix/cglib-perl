package Dijkstra;
use strict;
use Carp qw< croak >;
use PriorityQueue;
use Exporter qw< import >;
our @EXPORT_OK = qw< dijkstra >;

=pod

=head1 SYNOPSIS

   use Dijkstra qw< dijkstra >;

   # Arguments, M for Mandatory, O for Optional
   my %args = (
      start      => $node1, # M, node in your graph
      distance   => \&dsub, # M, subref, takes 2 nodes, returns number
      successors => \&ssub, # M, subref, takes 1 node, returns nodes list
      identifier => \&dsub, # O, subref, takes 1 node, returns id,
                            #    defaults to stringification of input node
      goals      => \@aref, # O, list of nodes in your graph, defaults all
   );

   my $obj = dijkstra(%args) # works with \%args too

   # $obj->isa('Dijkstra::Result') && print "yes it is\n";

   my $distance = $obj->distance_to($goal); # number or undef
   my @path = $obj->path_to($goal); # list
   my $path = $obj->path_to($goal); # ref array

=head1 NOTES

Implementation of the Dijkstra algorithm for single-source minimum
distance. Leverages C<PriorityQueue> for efficiency in node selection.

=cut

sub dijkstra {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start distance successors >;
   exists($args{$_}) || croak "missing parameter '$_'" for @reqs;
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

   return bless {t => \%thread_to, id => $id_of, s => $start}, 'Dijkstra';
} ## end sub dijkstra

package Dijkstra; # repetita juvant... especially with cut-and-paste
use strict;

sub path_to {
   my ($self, $v) = @_;
   my $vid = $self->{id}->($v);
   my $thr = $self->{t}{$vid} || return;    # connected?

   my @retval;
   while ($v) {
      unshift @retval, $v;
      ($v, $vid) = @{$thr}{qw< p pid >};
      $thr = $self->{t}{$vid};
   }

   return wantarray ? @retval : \@retval;
} ## end sub path_to

sub distance_to { return ($_[0]{t}{$_[0]{id}->($_[1])} || {})->{d} }

1;
