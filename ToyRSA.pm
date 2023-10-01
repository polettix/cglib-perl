package ToyRSA;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Math::BigInt;

sub toy_rsa_keys ($p, $q) {
   ($p, $q) = map { Math::BigInt->new($_) } ($p, $q);
   my $n = $p * $q;             # "big unfactorable" number
   my $T = $n - $q - $p + 1;    # totient (p - 1) * (q - 1)

   my $e = Math::BigInt->new(0x10001);    # try this first
   $e = ($e >> 1) | 1 while $e >= $T || Math::BigInt::bgcd($e, $T) != 1;
   $e += 2 while $e < 2 || Math::BigInt::bgcd($e, $T) != 1;
   die "wtf?!?\n" if $e >= $T;

   return ([$e, $n], [$e->copy->bmodinv($T), $n]);
} ## end sub toy_rsa_keys

sub toy_rsa_apply ($m, $key) {
   die "too low stuff!\n" if $m >= $key->[1];    # m >= n
   return Math::BigInt->new($m)->bmodpow($key->@*);
}

sub to_hex ($x) { Math::BigInt->new($x)->as_hex }
sub print_key ($name, $key) {
   my ($mod, $n) = map { to_hex($_) } $key->@*;
   say "$name";
   say "   mod: $mod";
   say "     n: $n";
}

exit sub (
   $cleartext = 42,
   $p         = '170141183460469231731687303715884105727',
   $q         = '43143988327398957279342419750374600193',
  )
{
   my ($public, $private) = toy_rsa_keys($p, $q);
   print_key(private => $private);
   print_key(public => $public);

   my $encrypted = toy_rsa_apply($cleartext, $private);
   my $decrypted = toy_rsa_apply($encrypted, $public);
   say "encrypted: @{[to_hex($encrypted)]}";
   say "decrypted: @{[to_hex($decrypted)]}";
   say "cleartext: @{[to_hex($cleartext)]}";
}->(@ARGV) unless caller;

1;
