package Numbers;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< gcd egcd lcm >;

sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }
sub lcm { return ($_[0] / gcd(@_)) * $_[1] }

sub egcd { # https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
   my ($X, $x, $Y, $y, $A, $B, $q) = (1, 0, 0, 1, @_);
   while ($A) {
      ($A, $B, $q) = ($B % $A, $A, int($B / $A));
      ($x, $X, $y, $Y) = ($X, $x - $q * $X, $Y, $y - $q * $Y);
   }
   return ($B, $x, $y);
}

1;
