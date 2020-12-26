package Numbers;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< binomial binomial_bi
   chinese_remainder_theorem chinese_remainder_theorem_bi
   factorial factorial_bi
   gcd egcd factor is_prime lcm >;

sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }
sub lcm { return ($_[0] / gcd(@_)) * $_[1] }

sub binomial {
   my ($n, $k, $n_k, $r) = (@_[0, 1], $_[0] - $_[1], $_[0] - $_[0] + 1);
   ($k, $n_k) = ($n_k, $k) if $k > $n_k;
   my @den = (2 .. $k);
   while ($n > $n_k) {
      ($n, my $f) = ($n - 1, $n);
      for (@den) {
         next if $_ == 1 || (my $gcd = gcd($_, $f)) == 1;
         ($_, $f) = ($_ / $gcd, $f / $gcd);
         last if $f == 1;
      }
      $r *= $f if $f > 1;
   }
   return $r;
}

sub binomial_bi {
   require Math::BigInt;
   return binomial(Math::BigInt->new($_[0]), $_[1]);
}

# provide a list of reminder1, modulus1, reminder2, modulus2, ...
sub chinese_remainder_theorem {
   die "no inputs" unless scalar @_;
   die "need an even number of inputs" if scalar(@_) % 2 == 1;
   my ($N, $R) = splice @_, 0, 2;
   while (@_) {
      my ($n, $r) = splice @_, 0, 2;
      my ($gcd, $x, $y) = egcd($N, $n);
      if ($gcd != 1) {
         die "cannot combine: {x ~ $R (mod $N)} with {$x ~ $r (mod $n)}"
            unless ($R % $gcd) == ($r % $gcd);
         $_ /= $gcd for ($N, $n);
      }
      my $P = $N * $n;
      ($N, $R) = ($P, ($r * $x * $N + $R * $y * $n) % $P);
   }
   return ($N, $R);
}

sub chinese_remainder_theorem_bi {
   require Math::BigInt;
   return chinese_remainder_theorem(map { Math::BigInt->new($_) } @_);
}

sub egcd {    # https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
   my ($X, $x, $Y, $y, $A, $B, $q) = (1, 0, 0, 1, @_);
   while ($A) {
      ($A, $B, $q) = ($B % $A, $A, int($B / $A));
      ($x, $X, $y, $Y) = ($X, $x - $q * $X, $Y, $y - $q * $Y);
   }
   return ($B, $x, $y);
} ## end sub egcd

sub factor {
   my ($x) = @_;
   return $x if $x < 4;
   my ($d, @factors) = (2);
   while ($x > 1) {
      $d++ && next if $x % $d;
      push @factors, $d;
      $x /= $d;
   }
   return @factors;
}

sub factorial {
   my ($x, $min, $f) = ($_[0], $_[1] || 1, $_[0]);
   $f *= $x while --$x >= $min;
   return $f;
}

sub factorial_bi {
   require Math::BigInt;
   return factorial(Math::BigInt->new($_[0]), @_ > 1 ? $_[1] : ());
}

sub is_prime { # https://en.wikipedia.org/wiki/Primality_test
   return if $_[0] < 2;
   return 1 if $_[0] <= 3;
   return unless ($_[0] % 2) && ($_[0] % 3);
   for (my $i = 6 - 1; $i * $i <= $_[0]; $i += 6) {
      return unless ($_[0] % $i) && ($_[0] % ($i + 2));
   }
   return 1;
}

1;
