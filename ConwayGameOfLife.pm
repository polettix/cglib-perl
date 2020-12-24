package ConwayGameOfLife;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< conway_game_of_life >;

=pod

=head1 SYNOPSIS

   use ConwayGameOfLife 'conway_game_of_life'; # or just copy-paste...

   my $opts = {
      iterations => 1,
      neighbors => sub {
         my ($key) = @_;
         my ($x, $y) = split m{,}mxs, $key;
         my @neighbors;
         for my $X (-1 .. 1) {
            for my $Y (-1 .. 1) {
               next unless $X || $Y;
               push @neighbors, join ',', $x + $X, $y + $Y;
            }
         }
         return \@neighbors;
      },
      existence_condition => sub {
         my ($key, $count, $previous_status) = @_;
         return exists $previous_status->{$key}
            ? ($count == 2 || $count == 3)
            : ($count == 3);
      },
      status => ['0,0', '0,1', '1,1'],
   };
   my $outcome = conway_game_of_life($opts);

   # output has same format as input, can be used for other iterations
   my $more_iterations = conway_game_of_life($outcome);

=head1 DESCRIPTION

Performs iterations for a Conway's Game of Life. Just provide:

=over

=item B<< existence_condition >>

sub reference taking a C<key>, a C<count> of active neighbors, and the
previous C<status> always as a hash reference (see below);

=item B<< iterations >>

the number of iterations to perform (defaults to 1);

=item B<< neighbors >>

sub reference taking a C<key> and providing the list of neighbors inside a
reference to an array;

=item B<< status >>

the initial status (or the final one, in the outcome). It can be either an
array reference holding active keys in a round, or a hash reference whose
keys are active.

=back

=cut

sub conway_game_of_life {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< existence_condition neighbors status >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my $iterations = defined $args{iterations} ? $args{iterations} : 1;
   my $ash = ref $args{status} eq 'HASH' ? 1
      : ref $args{status} eq 'ARRAY' ? 0 : die "invalid status";
   my $status = $ash ? $args{status} : {map {$_ => 1} @{$args{status}}};
   while ($iterations > 0) {
      ($status, my $previous, my %count_for) = (\my %next, $status);
      for my $key (keys %$previous) {
         $count_for{$key} = 0 unless exists $count_for{$key};
         $count_for{$_}++ for @{$args{neighbors}->($key)};
      }
      while (my ($k, $c) = each %count_for) {
         $next{$k} = 1 if $args{existence_condition}->($k, $c, $previous);
      }
      --$iterations;
   }
   $args{status} = $ash ? $status : [keys %$status];
   return \%args;
}

1;
