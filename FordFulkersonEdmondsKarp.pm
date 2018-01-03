package FordFulkersonEdmondsKarp;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< ford_fulkerson_edmonds_karp >;

use constant ACC => 1e-13;

sub ford_fulkerson_edmonds_karp {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< capacity successors source target >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($cap, $scs, $s, $t) = @args{@reqs};
   my $id_of = $args{identifier} || sub { return "$_[0]" };

   my (@q, %ef, %nf) = ($s); # initialization
   while (@q) {
      next if $nf{my $vi = $id_of->(my $v = shift @q)};
      for my $w ($scs->($nf{$vi} = $v)) {
         next if $vi eq (my $wi = $id_of->($w)); # avoid self-edges
         push @q, $w unless exists $nf{$wi};
         next if exists $ef{$vi}{$wi};
         $ef{$vi}{$wi} = $ef{$wi}{$vi}
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
            next if (($src eq $l) && (($cap - $flow) < ACC))
               || (($src eq $n) && ($flow < ACC));
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
         my $avail = ($src eq $l) ? ($cap - $flow) : $flow;
         $bneck = $avail if (! defined $bneck) || ($avail < $bneck);
         $l = $_;
      }
      ($l, $max_flow) = ($s, $max_flow + $bneck);   # update graph
      for (@path) {
         $ef{$l}{$_}{f} += ($ef{$l}{$_}{s} eq $l) ? $bneck : -$bneck;
         $l = $_;
      }
   }

   my (%flag, @min_cut) = ($s => 1); # min-cut finding
   @q = ($s);
   while (@q) {
      push @min_cut, (my $l = shift @q);
      for my $n (keys %{$ef{$l} || {}}) {
         next if $flag{$n}++;
         next if ($ef{$l}{$n}{c} - $ef{$l}{$n}{f}) < ACC;
         push @q, $n;
      }
   }
   @min_cut = map {$nf{$_}} @min_cut;

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
