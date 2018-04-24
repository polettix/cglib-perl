package ArticulationPoints;
use strict;
use DepthFirstVisit qw< depth_first_visit >;
use Exporter qw< import >;
our @EXPORT_OK = qw< articulation_points >;

sub articulation_points {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @s = exists($args{start}) ? ($args{start})
      : exists($args{starts})   ? (@{$args{starts}})
      :                           die "missing 'start' or 'starts'";
   my $id_for = $args{identifier} || sub { return "$_[0]" };
   my ($index, %nf, %low, %pf, @retval) = (0);
   depth_first_visit(
      %args,       # base parameters, e.g. successors and id_for
      start => $_, # do one connected component at a time
      pre_action => sub {
         my ($v, $p) = @_;
         my $idx = $index++;
         $nf{my $vid = $id_for->($v)} = {
            node   => $v,   # immutable
            index  => $idx, # immutable
            low    => $idx, # evolves in time
            children => 0,  # evolves in time
            match    => 0,  # is it an articulation node?
         };
         return unless defined $p;
         $nf{$nf{$vid}{parent} = $id_for->($p)}{children}++;
      },
      skip_action => sub {
         my ($v, $p) = @_;
         return unless defined $p; # need parent for skip tests
         my $node = $nf{my $vid = $id_for->($v)};
         my $pnode = $nf{my $pid = $id_for->($p)};
         return unless defined $pnode->{parent};
         return if $vid eq $pnode->{parent};
         $pnode->{low} = $node->{index} if $node->{index} < $pnode->{low};
      },
      post_action => sub {
         my ($v, $p) = @_;
         my ($node, $is_root) = ($nf{$id_for->($v)}, !defined($p));
         push @retval, $v
            if (!$is_root && $node->{match})
            || ($is_root  && ($node->{children} > 1));
         return if $is_root;
         my $pnode = $nf{$id_for->($p)};
         $pnode->{match} = 1 if $node->{low} >= $pnode->{index};
         $pnode->{low} = $node->{low} if $node->{low} < $pnode->{low};
      },
   ) for @s;

   return @retval if wantarray;
   return \@retval;
}

1;
