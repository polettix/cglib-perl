package Permutations;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< permutations_iterator >;

=pod

=head1 SYNOPSIS

   use Permutations qw< permutations_iterator >;

   # Arguments, M for Mandatory, O for Optional
   my %args = (
      filter => \&sub,   # O, defaults to returning permutation (*)
      items  => \@array, # M, items to permute and initial order
   );
   (*) in list context returns permutation as list, array ref otherwise.

   my $p_it = permutations_iterator(%args);
   $p_it    = permutations_iterator(\%args); # hashref, same as above

   # with default filter we can get a list
   while (my @permutation = $p_it->()) {
      do_something(@permutation);
   }

   # with default filter we can get an array reference
   while (my $permutation = $p_it->()) {
      do_something(@$permutation);
   }

=cut

sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $items = $args{items} || die "invalid or missing parameter 'items'";
   my $filter = $args{filter} || sub { wantarray ? @_ : [@_] };
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub {
      if (! defined $sp) { $sp = 0 }
      else {
         while ($sp < @indexes) {
            if ($stack[$sp] < $sp) {
               my $other = $sp % 2 ? $stack[$sp] : 0;
               @indexes[$sp, $other] = @indexes[$other, $sp];
               $stack[$sp]++;
               $sp = 0;
               last;
            }
            else {
               $stack[$sp++] = 0;
            }
         }
      }
      return $filter->(@{$items}[@indexes]) if $sp < @indexes;
      return;
   }
}

1;
