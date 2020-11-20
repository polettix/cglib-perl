package BasicPriorityQueue;
use strict;     # Adapted from https://algs4.cs.princeton.edu/24pq/

=pod

=encoding utf-8

=head1 SYNOPSIS

   use BasicPriorityQueue;

   # All arguments are optional
   my $pq = BasicPriorityQueue->(
      before => \&compare, # true if $_[0] comes before $_[1]
      items  => \@list,    # initial values for queue
   );

   my $first_item = $pq->dequeue; # get and remove "top" item from queue
   my $peek_item  = $pq->top;     # get "top" item but keep in queue
   $pq->enqueue($new_item);
   do_something($pq->dequeue) while ! $pq->is_empty;
   do_something($pq->dequeue) while $pq->size;

=cut

sub dequeue;    # see below
sub enqueue;    # see below
sub is_empty    { return !$#{$_[0]{items}} }
sub top         { return $#{$_[0]{items}} ? $_[0]{items}[1] : () }
sub new;        # see below
sub size        { return $#{$_[0]{items}} }

sub dequeue {    # includes "sink"
   my ($is, $before, $k) = (@{$_[0]}{qw< items before >}, 1);
   return unless $#$is;
   my $r = ($#$is > 1) ? (splice @$is, 1, 1, pop @$is) : pop @$is;
   while ((my $j = $k * 2) <= $#$is) {
      ++$j if ($j < $#$is) && $before->($is->[$j + 1], $is->[$j]);
      last if $before->($is->[$k], $is->[$j]);
      (@{$is}[$j, $k], $k) = (@{$is}[$k, $j], $j);
   }
   return $r;
} ## end sub dequeue

sub enqueue {    # includes "swim"
   my ($is, $before) = (@{$_[0]}{qw< items before >});
   push @$is, $_[1];
   my $k = $#$is;
   (@{$is}[$k / 2, $k], $k) = (@{$is}[$k, $k / 2], int($k / 2))
     while ($k > 1) && $before->($is->[$k], $is->[$k / 2]);
} ## end sub enqueue

sub new {
   my $package = shift;
   my $self = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
   $self->{before} ||= sub { $_[0] < $_[1] };
   (my $is, $self->{items}) = ($self->{items} || [], ['-']);
   $self->enqueue($_) for @$is;
   return $self;
} ## end sub new

1;
