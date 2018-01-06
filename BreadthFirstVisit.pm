package BreadthFirstVisit;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< breadth_first_visit >;

sub breadth_first_visit {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @s = exists($args{start}) ? ($args{start})
      : exists($args{starts})   ? (@{$args{starts}})
      :                           die "missing 'start' or 'starts'";
   my $succs = $args{successors} || die "missing parameter 'successors'";
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my $va = $args{action} || $args{visit_action} || undef;
   my $da = $args{discover_action} || undef;
   my %m; # keep track of marked nodes
   my @q = map {
      $da && $da->($_, undef); $m{$id_of->($_)} = 1; [$_, undef] } @s;
   while (@q) {
      my ($v, $pred) = @{shift @q};  # "dequeue"
      $va->($v, $pred) if $va;
      for my $w ($succs->($v)) {
         next if $m{$id_of->($w)}++;
         $da->($w, $v) if $da;
         push @q, [$w, $v];
      }
   }
   return unless defined wantarray; # don't bother with void context
   return keys %m if wantarray;
   return [keys %m] if defined wantarray;
}

1;
