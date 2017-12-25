package BellmanFord; # Wikipedia: .../wiki/Bellman%E2%80%93Ford_algorithm
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< bellman_ford >;

sub bellman_ford {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< distance successors start >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my ($dist, $scs, $start, @q, %nf, @es) = (@args{@reqs}, $args{start});
   while (@q) { # edges in %ed, vertices in %nf
      next if exists $nf{my $vi = $id_of->(my $v = shift @q)};
      for my $w ($scs->($nf{$vi} = $v)) {
         next if $vi eq (my $wi = $id_of->($w)); # avoid self-edges
         push @es, [$vi, $wi, $dist->($v, $w)];
         push @q, $w unless exists $nf{$wi};
      }
   }
   my (%d, %p) = ($id_of->($start) => 0);
   for (1 .. scalar(%nf) - 1) { # repeat this many times
      my $worked;
      for my $e (@es) {
         my ($vi, $wi, $ed) = @$e;
         next if (!exists $d{$vi}) ||
            ((exists $d{$wi}) && ($d{$vi} + $ed >= $d{$wi}));
         $d{$wi} = $d{$vi} + $ed;
         $p{$wi} = $vi;
         $worked = 1;
      }
      last unless $worked;
   }
   (($d{$_->[0]} + $_->[2] < $d{$_->[1]}) && return) for @es;
   return {
      has_path_to => sub { exists $d{$id_of->($_[0])} },
      distance => sub {
         my $id = $id_of->($_[0]);
         return exists($d{$id}) ? $d{$id} : undef;
      },
      path_to => sub {
         my ($t, $tid) = ($_[0], $id_of->($_[0]));
         return unless exists $d{$tid};
         my @path;
         while (defined $tid) {
            unshift @path, $nf{$tid};
            $tid = exists($p{$tid}) ? $p{$tid} : undef;
         }
         return wantarray ? @path : \@path;
      },
   };
}

1;
