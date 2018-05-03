package Bareiss;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< bareiss >;

sub bareiss {    # transforms matrix in-place, hopefully
   my ($A, $B, $m, $n) = ($_[0], [@{$_[0]}], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   ($A, $B) = ($B, $A) if (($n & 1) xor (int(($n - 1) / 2) & 2));
   for (my $k = 1; $k <= $n - 1; $k += 2) {
      ($A, $B) = ($B, $A);
      my $K = ($k - 1) * $m + $k - 1;    # upper-left corner
      if ($k < $n - 1) {
         my $c0 =
           $B->[$K] * $B->[$K + $m + 1] - $B->[$K + 1] * $B->[$K + $m];
         for my $i ($k + 1 .. $n - 1) {
            my $I  = $i * $m + $k - 1;
            my $c1 = $B->[$K + 1] * $B->[$I] - $B->[$K] * $B->[$I + 1];
            my $c2 =
              $B->[$K + $m] * $B->[$I + 1] - $B->[$K + $m + 1] * $B->[$I];
            for my $j ($k + 1 .. $m - 1) {
               $A->[$i * $m + $j] =
                 $c0 * $B->[$i * $m + $j] +
                 $c1 * $B->[$k * $m + $j] +
                 $c2 * $B->[($k - 1) * $m + $j];
            } ## end for my $j ($k + 1 .. $m...)
         } ## end for my $i ($k + 1 .. $n...)
      } ## end if ($k < $n - 1)
      if ($k < $n) {
         for my $l ($k .. $m - 1) {
            $A->[$k * $m + $l] =
              $B->[$K] * $B->[$k * $m + $l] -
              $B->[($k - 1) * $m + $l] * $B->[$K + $m];
         }
      } ## end if ($k < $n)
   } ## end for (my $k = 1; $k <= $n...)
   return $A;
} ## end sub bareiss
