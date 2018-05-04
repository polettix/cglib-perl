package Bareiss;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< bareiss >;

sub bareiss {    # transforms matrix in-place, hopefully
   my ($A, $m, $n) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   for (my $k = 1; $k <= $n - 1; $k += 2) {
      my $K = ($k - 1) * $m + $k - 1;    # upper-left corner
      if ($k < $n - 1) {
         my $c0 =
           $A->[$K] * $A->[$K + $m + 1] - $A->[$K + 1] * $A->[$K + $m];
         for my $i ($k + 1 .. $n - 1) {
            my $I  = $i * $m + $k - 1;
            my $c1 = $A->[$K + 1] * $A->[$I] - $A->[$K] * $A->[$I + 1];
            my $c2 =
              $A->[$K + $m] * $A->[$I + 1] - $A->[$K + $m + 1] * $A->[$I];
            for my $j ($k + 1 .. $m - 1) {
               $A->[$i * $m + $j] =
                 $c0 * $A->[$i * $m + $j] +
                 $c1 * $A->[$k * $m + $j] +
                 $c2 * $A->[($k - 1) * $m + $j];
            } ## end for my $j ($k + 1 .. $m...)
         } ## end for my $i ($k + 1 .. $n...)
      } ## end if ($k < $n - 1)
      if ($k < $n) {
         for my $l ($k .. $m - 1) {
            $A->[$k * $m + $l] =
              $A->[$K] * $A->[$k * $m + $l] -
              $A->[($k - 1) * $m + $l] * $A->[$K + $m];
         }
      } ## end if ($k < $n)
   } ## end for (my $k = 1; $k <= $n...)
   return $A;
} ## end sub bareiss
