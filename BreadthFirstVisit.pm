package BreadthFirstVisit;
use strict;

sub breadth_first_visit {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @starts = exists($args{start}) ? ($args{start})
      : exists($args{starts})        ? (@{$args{starts}})
      :                                die "missing 'start' or 'starts'";
   my $succs = $args{successors} || die "missing parameter 'successors'";
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my $action  = $args{action} || undef;
   my %marked;
   my @queue = map { $marked{$id_of->($_)} = 1; [$_, undef] } @starts;
   while (@queue) {
      my ($v, $pred) = @{shift @queue};  # "dequeue"
      $action->($v, $pred) if $action;
      for my $w ($succs->($v)) {
         push @queue, [$w, $v] unless $marked{$id_of->($w)}++;
      }
   }
   return unless defined wantarray; # don't bother with void context
   return keys %marked if wantarray;
   return [keys %marked] if defined wantarray;
}

1;
