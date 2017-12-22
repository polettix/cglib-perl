package AlphaBeta;
use strict;
use Carp qw< croak >;
use Exporter qw< import >;
our @EXPORT_OK = qw< alpha_beta >;

sub alpha_beta {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< state moves_for move evaluate depth finished >;
   exists($args{$_}) || croak "missing parameter '$_'" for @reqs;
   my ($s, $mf, $md, $e, $d, $f) = @args{@reqs};
   return(wantarray ? ($e->($s), []) : $e->($s)) if ($d == 0) || $f->($s);
   my $a = $args{alpha} // undef;
   my ($bm, $bv, $hm); # "best" stuff, undef treated as +/- inf
   for my $m ($mf->($s)) {
      ($hm, my $ns) = (1, $md->($s, $m)); # set "has moved" too
      my ($v, $t) = alpha_beta(
         %args,
         alpha => (defined $args{beta} ? -$args{beta} : undef),
         beta  => (defined $a ? -$a : $a),
         depth => ($d - 1),
      );
      $v = -$v;
      $args{rollback}->($s, $m, $ns) if defined $args{rollback};
      ($bv, $bm) = ($v, [$m, @$t]) if (!defined $bv) || ($v > $bv); # "max"
      last if defined($args{beta}) && $bv >= $args{beta};
      $a = $bv if (!defined $a) || ($a < $bv);
   }
   croak "can't handle no_move" unless $hm || defined $args{no_move};
   return $args{no_move}->($s, $d) unless $hm;
   return wantarray ? ($bv, $bm) : $bv;
}

1;
