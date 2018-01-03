use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;
use Data::Dumper;

use FordFulkersonEdmondsKarp qw< ford_fulkerson_edmonds_karp >;

do_test(
   {
      a => { b => 5, c => 5 },
      b => { d => 3, e => 2 },
      c => { d => 1, e => 3 },
      d => { z => 6 },
      e => { z => 6 },
   },
   {
      a => { b => 5, c => 4 },
      b => { d => 3, e => 2 },
      c => { d => 1, e => 3 },
      d => { z => 4 },
      e => { z => 5 },
   },
   'a', 'z', 9, qw< a c >,
);

do_test(
   {
      A => {B => 1000, C => 1000},
      B => {C => 1, D => 1000},
      C => {D => 1000},
   },
   {
      A => {B => 1000, C => 1000},
      B => {D => 1000},
      C => {D => 1000},
   },
   'A', 'D', 2000, 'A'
);

sub do_test {
   my ($caps, $flows, $source, $target, $mf, @mc) = @_;
   my $retval = ford_fulkerson_edmonds_karp(
      capacity => sub { return $caps->{$_[0]}{$_[1]} },
      successors => sub { return sort keys %{$caps->{$_[0]}} },
      source => $source,
      target => $target,
   );
   isa_ok $retval, 'HASH';
   is $retval->{max_flow}, $mf, "max_flow ($mf)";
   is_deeply [sort @{$retval->{min_cut}}], \@mc, "min_cut (@mc)";

   while (my ($from, $data) = each %$flows) {
      while (my ($to, $flow) = each %$data) {
         is $retval->{flow_between}->($from, $to), $flow,
            "$from -($flow)-> $to";
      }
   }
}

done_testing;
