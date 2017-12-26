package Fibonacci;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< fibonacci_nth fibonacci_nth_bi >;

sub fibonacci_multiply {
   my ($x, $y) = @_;
   @$x = (
      $x->[0] * $y->[0] + $x->[1] * $y->[2],
      $x->[0] * $y->[1] + $x->[1] * $y->[3],
      $x->[2] * $y->[0] + $x->[3] * $y->[2],
      $x->[2] * $y->[1] + $x->[3] * $y->[3],
   );
} ## end sub _multiply

sub fibonacci_power {
   my ($q, $n, $q0) = (@_[0, 1], $_[2] || [@{$_[0]}]);
   return $q if $n < 2;
   fibonacci_power($q, int($n / 2), $q0);
   fibonacci_multiply($q, $q);
   fibonacci_multiply($q, $q0) if $n % 2;
   return $q;
} ## end sub _power

sub fibonacci_nth {
   my ($n, $one, $zero) = ($_[0], $_[1] || 1, ($_[1] || 1) - ($_[1] || 1));
   return
       $n < 1 ? $zero
     : $n < 3 ? $one
     :          fibonacci_power([$one, $one, $one, $zero], $n - 1)->[0];
} ## end sub nth

sub fibonacci_nth_bi {
   require Math::BigInt;
   return fibonacci_nth($_[0], Math::BigInt->new(1));
}

1;
