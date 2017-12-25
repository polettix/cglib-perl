package FloydWarshall; # https://algs4.cs.princeton.edu/code/ ...
use strict;
use PriorityQueue;
use Exporter qw< import >;
our @EXPORT_OK = qw< floyd_warshall >;

sub floyd_warshall {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< distance successors >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($dist, $scs) = @args{@reqs};
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my @q = exists($args{starts}) ? @{$args{starts}}
      : exists($args{start}) ? ($args{start})
      : die "missing parameter 'starts' or 'start'";
   my (%d, %p, %nf); # distances, predecessors
   while (@q) { # initialization
      next if exists $nf{my $vi = $id_of->(my $v = shift @q)};
      for my $w ($scs->($nf{$vi} = $v)) {
         next if $vi eq (my $wi = $id_of->($w)); # avoid self-edges
         ($d{$vi}{$wi}, $p{$vi}{$wi}) = ($dist->($v, $w), $vi);
         push @q, $w unless exists $nf{$wi};
      }
      $d{$vi}{$vi} = 0;
   }
   my @vs = keys %nf;
   for my $vi (@vs) {
      for my $vv (@vs) {
         next unless exists $p{$vv}{$vi};
         for my $vw (@vs) {
            next if (!exists $d{$vi}{$vw}) || (exists($d{$vv}{$vw})
               && ($d{$vv}{$vw} <= $d{$vv}{$vi} + $d{$vi}{$vw}));
            $d{$vv}{$vw} = $d{$vv}{$vi} + $d{$vi}{$vw}; 
            $p{$vv}{$vw} = $p{$vi}{$vw};
         }
         return if $d{$vv}{$vv} < 0; # negative cycle, bail out
      }
   }
   return {
      has_path => sub {
         my ($vi, $wi) = map { $id_of->($_) } @_[0, 1];
         return exists($d{$vi}) && exists($d{$vi}{$wi});
      },
      distance => sub {
         my ($vi, $wi) = map { $id_of->($_) } @_[0, 1];
         return unless exists($d{$vi}) && exists($d{$vi}{$wi});
         return $d{$vi}{$wi};
      },
      path => sub {
         my ($fi, $ti) = map { $id_of->($_) } @_[0, 1];
         return unless exists($d{$fi}) && exists($d{$fi}{$ti});
         my @path;
         while ($ti ne $fi) {
            unshift @path, $nf{$ti};
            $ti = $p{$fi}{$ti};
         }
         unshift @path, $nf{$ti};
         return wantarray ? @path : \@path;
      },
   };
}

1;
