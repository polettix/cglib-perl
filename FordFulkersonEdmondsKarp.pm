package FordFulkersonEdmondsKarp;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< ford_fulkerson_edmonds_karp >;

use constant ACC => 1e-13;

sub ford_fulkerson_edmonds_karp {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< capacity successors source target >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($cap, $scs, $s, $t, $u) = @args{@reqs, 'undirected'};
   my $id_of = $args{identifier} || sub { return "$_[0]" };

   my (@q, %ef, %nf) = ($s); # initialization
   while (@q) {
      next if exists($nf{my $vi = $id_of->(my $v = shift @q)});
      for my $w ($scs->($nf{$vi} = $v)) {
         next if $vi eq (my $wi = $id_of->($w)); # avoid self-edges
         push @q, $w unless exists $nf{$wi};
         next if exists $ef{$vi}{$wi}; # already added this edge
         $ef{$vi}{$wi} = $ef{$vi}{$wi}
            = { s => $vi, t => $wi, c => $cap->($v, $w), f => 0 };
      }
   }

   my $max_flow = 0;          # main algorithm
   while ('necessary') {
      my (@q, @path, %flag) = ([$s]); # find augmenting path
      AUGMENTING_PATH_SEARCH: while (@q) {
         my ($l, @trail) = @{shift @q};
         for my $n (keys %{$ef{$l} || {}}) {
            my ($cap, $flow, $src) = @{$ef{$l}{$n}}{qw< c f s >};
            my $av = $src eq $l ? $cap - $flow : $u ? $flow - $cap : $flow;
            next if $av < ACC;
            if ($n eq $t) {
               @path = reverse($n, $l, @trail);
               shift @path; # don't need the source node
               last AUGMENTING_PATH_SEARCH;
            }
            next if $flag{$n}++; # don't re-enqueue
            push @q, [$n, $l, @trail];
         }
      }
      last unless @path; # no augmenting path found
      my ($l, $bneck) = ($s); # calculate bottleneck capacity
      for (@path) {
         my ($cap, $flow, $src) = @{$ef{$l}{$_}}{qw< c f s >};
         my $avail = $src eq $l ? $cap - $flow : $u ? $flow - $cap : $flow;
         $bneck = $avail if (! defined $bneck) || ($avail < $bneck);
         $l = $_;
      }
      ($l, $max_flow) = ($s, $max_flow + $bneck);   # update graph
      for (@path) {
         $ef{$l}{$_}{f} += ($ef{$l}{$_}{s} eq $l) ? $bneck : -$bneck;
         $l = $_;
      }
   }

   my %reach = ((@q = $s) => 1); # tracks vertices still reachable from src
   while (@q) {
      my $l = shift @q;
      my $edges = $ef{$l} or next;
      for my $n (keys %$edges) {
         my ($src, $cap, $flow) = @{$edges->{$n}}{qw< s c f >};
         my $avail = $src eq $l ? $cap - $flow : $u ? $flow - $cap : $flow;
         next if ($avail < ACC) || $reach{$n}++;
         push @q, $n;
      }
   }
   my @min_cut = map { # edges between reachable and unreachable vertices
      my ($nl, @neighbors) = ($nf{$_}, keys %{$ef{$_} || {}});
      map { [$nl, $nf{$_}] } grep { !$reach{$_} } @neighbors;
   } keys %reach;

   return {
      max_flow => $max_flow,
      min_cut => \@min_cut,
      flow_between => sub {
         my ($s, $t) = map {$id_of->($_)} @_[0, 1];
         return unless exists($ef{$s}) && exists($ef{$s}{$t});
         return $ef{$s}{$t}{s} eq $s ? $ef{$s}{$t}{f} : -$ef{$s}{$t}{f};
      },
   };
}

1;
