package MaxPQ;    # Adapted from https://algs4.cs.princeton.edu/24pq/
use strict;

sub delete_max {    # includes "sink"
   my ($data, $lt, $k) = (@{$_[0]}{qw< data less_than >}, 1);
   my $r = (@$data > 2) ? (splice @$data, 1, 1, pop @$data) : pop @$data;
   while ((my $j = $k * 2) <= $#$data) {
      ++$j if ($j < $#$data) && $lt->($data->[$j], $data->[$j + 1]);
      last unless $lt->($data->[$k], $data->[$j]);
      (@{$data}[$j, $k], $k) = (@{$data}[$k, $j], $j);
   }
   return $r;
} ## end sub delete_max

sub insert {      # includes "swim"
   my ($data, $lt) = (@{$_[0]}{qw< data less_than>});
   push @$data, $_[1];
   my $k = $#$data;
   (@{$data}[$k / 2, $k], $k) = (@{$data}[$k, $k / 2], int($k / 2))
     while ($k > 1) && $lt->($data->[$k / 2], $data->[$k]);
} ## end sub insert

sub is_empty { return !$#{$_[0]{data}} }

sub max { return $_[0][1] }

sub new {
   my $package = shift;
   my $self = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
   $self->{less_than} ||= sub { $_[0] < $_[1] };
   (my $data, $self->{data}) = ($self->{data} || [], ['-']);
   $self->insert($_) for @$data;
   return $self;
} ## end sub new

sub size { return scalar $#{$_[0]{data}} }

1;
