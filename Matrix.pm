package Matrix;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< I M O >;
use overload '""' => \&stringify;

sub append_below; # see below
sub append_right { return $_[0]->T->append_below($_[1]->clone->T)->T }
sub clone { return bless [@{$_[0]}], __PACKAGE__ }
sub column_echelon; # see below
sub I; # see below
sub kernel; # see below
sub idx { return $_[0][-1] * $_[1] + $_[2] }
sub M { return bless [ref($_[0]) ? @{$_[0]} : @_], __PACKAGE__ }
sub Mify { return bless $_[0], __PACKAGE__ }
sub O { return M((0) x ($_[0] * $_[1] || $_[0]), $_[1] || $_[0]) }
sub n_columns { return $_[0][-1] }
sub n_rows { return $#{$_[0]} / $_[0][-1] }
sub stringify;    # see below
sub T; # see below
sub v { my $i = idx(@_); @_ > 3 ? ($_[0][$i] = $_[3]) : $_[0][$i] }

sub _gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }

sub append_below {
   my ($s, $t, $ct) = ($_[0], $_[1], $_[1][-1]);
   die "cannot just_below(), incompatible matrixes" unless pop(@$s) == $ct;
   @$s = (@$s, @$t);
   return $s;
}

sub column_echelon {
   my ($s, $c, $r, @sws) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my ($n, $t) = (defined($_[1]) ? $_[1] : $c < $r ? $c : $r, $r * $c);
 LOOP:
   for my $k (0 .. $n - 1) {
      my $K = $k * $c + $k;
      if (!$s->[$K]) {
       SEARCH_PIVOT:
         for my $i ($k .. $n - 1) {
            for my $j ($k .. $c - 1) {
               next unless $s->[$i * $c + $j];
               $s->swap_rows($k, $i) && unshift @sws, [$k, $i] if $k != $i;
               $s->swap_columns($k, $j) if $k != $j;
               last SEARCH_PIVOT;
            }
         }
      }
      my $akk = $s->[$K] or last LOOP;    # rest is all zeros
      for my $j ($k + 1 .. $c - 1) {
         my $akj = $s->[$k * $c + $j] or next;
         my $g = _gcd($akk, $akj);
         my ($kk, $kj) = ($g > 1) ? ($akk / $g, $akj / $g) : ($akk, $akj);
         for (my $I = $k * $c; $I + $j < $t; $I += $c) {
            $s->[$I + $j] = $s->[$I + $j] * $kk - $s->[$I + $k] * $kj;
         }
      } ## end for my $j ($k + 1 .. $c...)
   } ## end LOOP: for my $k (0 .. ($c < $r...))
   $s->swap_rows(@$_) for @sws;
   return $s;
} ## end sub column_echelon

sub I {
   my ($n, $n2, $i) = ($_[0], $_[0] * $_[0], 0);
   my @array = ((0) x $n2, $n);
   ($array[$i], $i) = (1, $i + $n + 1) while $i < $n2;
   return bless \@array, __PACKAGE__;
}

sub kernel {
   my ($s, $c, $r) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my $M = $s->clone->append_below(I($c))->column_echelon($r);
   my $k = ($r < $c ? $r : $c) - 1;
   $k-- while ($k >= 0) && ($M->[$k * $c + $k] == 0);
   my @retval;
 CANDIDATE:
   for my $j (++$k .. $c - 1) {
      $M->[$_ * $c + $j] && next CANDIDATE for $j .. $r - 1;
      my ($gcd, $has_positive, @v) = (0);
      for my $i ($r .. $r + $c - 1) {
         push @v, my $v = $M->[$i * $c + $j];
         $gcd = _gcd($gcd, $v);
         $has_positive ||= $v > 0;
      }
      $gcd = -$gcd if ($gcd < 0) && $has_positive;
      $gcd and $_ /= $gcd for @v;
      push @retval, \@v;
   } ## end CANDIDATE: for my $j (++$k .. $c -...)
   return \@retval;
} ## end sub kernel

sub row_echelon {
   my ($s, $c, $r, @w) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my ($n, $t) = (defined($_[1]) ? $_[1] : $c < $r ? $c : $r, $r * $c);
 LOOP:
   for my $k (0 .. $n - 1) {
      my $K = $k * $c + $k;
      if (!$s->[$K]) {
       SEARCH_PIVOT:
         for my $j ($k .. $n - 1) {
            for my $i ($k .. $r - 1) {
               next unless $s->[$i * $c + $j];
               $s->swap_columns($k, $j) && unshift @w, [$k, $j] if $k < $j;
               $s->swap_rows($k, $i) if $k != $i;
               last SEARCH_PIVOT;
            }
         }
      }
      my $akk = $s->[$K] or last LOOP;    # rest is all zeros
      for (my $I = (my $K = $k * $c) + $c; $I <= $t - $c; $I += $c) {
         my $aik = $s->[$I + $k] or next;
         my $g = _gcd($akk, $aik);
         my ($kk, $ik) = ($g > 1) ? ($akk / $g, $aik / $g) : ($akk, $aik);
         for (my $j = $k; $j < $c; $j++) {
            $s->[$I + $j] = $s->[$I + $j] * $kk - $ik * $s->[$K + $j];
         }
      } ## end for my $j ($k + 1 .. $c...)
   } ## end LOOP: for my $k (0 .. ($c < $r...))
   $s->swap_columns(@$_) for @w;
   return $s;
} ## end sub column_echelon

sub stringify {
   my ($s, $c, $r) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my $l = (sort { $a <=> $b } map { length } @{$s}[0 .. $#$s - 1])[-1];
   my $inner = join "|\n|", map { join ' ', map { sprintf " %${l}s ", $_ }
        @{$s}[$_ * $c .. ($_ + 1) * $c - 1] } 0 .. $r - 1;
   return '|' . $inner . '|';
} ## end sub stringify

sub swap_columns {
   my ($s, $f, $t, $c, $T) = (@_[0..2], $_[0][-1], $#{$_[0]});
   return $s if $f == $t;
   (@{$s}[$f, $t], $f, $t) = (@{$s}[$t, $f], $f + $c, $t + $c) while $f < $T;
   return $s;
}

sub swap_rows {
   my ($s, $c, $r) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my ($F, $T) = ($_[1] * $c, $_[2] * $c);
   return $s if $F == $T;
   @{$s}[$F + $_, $T + $_] = @{$s}[$T + $_, $F + $_] for 0 .. $c - 1;
   return $s;
}

sub T {
   my ($s, $c, $r, $i) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   @{$s}[map {$i = $_; map {$i + $_ * $r} 0 .. $c - 1} 0 .. $r - 1] = @$s;
   $s->[-1] = $r;
   return $s;
}
