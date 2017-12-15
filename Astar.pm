package Astar;
use strict;
use Carp qw< croak >;
use BasicPriorityQueue;
use Exporter qw< import >;
our @EXPORT_OK = qw< astar >;

=pod

=head1 SYNOPSIS

   use Astar qw< astar >; # shouldn't need this if you embed

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
   @path = astar(%args);
   @path = astar(\%args); # works with reference to hash too

   # get an array reference back, containing the list above
   $path = astar(%args);
   $path = astar(\%args); # works with reference to hash too

=head1 NOTES

This module needs C<BasicPriorityQueue> to work properly.

=cut

sub astar {    # parameters validation
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start goal distance successors >;
   exists($args{$_}) || croak "missing parameter '$_'" for @reqs;
   my ($start, $goal, $dist, $succs) = @args{@reqs};
   my $h     = $args{heuristic}  || $dist;
   my $id_of = $args{identifier} || sub { return "$_[0]" };

   my ($id, $gid) = ($id_of->($start), $id_of->($goal));
   my %node_for = ($id => {value => $start, g => 0});
   my $queue = BasicPriorityQueue->new(
      before => sub { $_[0]{f} < $_[1]{f} },    # lower come first
      data => [{id => $id, f => 0}],    # f is invariant for start node
   );

   while (!$queue->is_empty) {
      my $cid = $queue->dequeue->{id};
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
         $queue->enqueue({id => $sid, f => $g + $h->($sv, $goal)});
      } ## end for my $sv ($succs->($cv...))
   } ## end while (!$queue->is_empty)

   return;
} ## end sub astar

sub __unroll {    # unroll the path from start to goal
   my ($node, $node_for, @path) = ($_[0], $_[1], $_[0]{value});
   while (defined(my $p = $node->{p})) {
      $node = $node_for->{$p};
      unshift @path, $node->{value};
   }
   return wantarray ? @path : \@path;
} ## end sub __unroll

1;
