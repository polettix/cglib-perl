package DepthFirstVisit;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< depth_first_visit >;

sub depth_first_visit {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start successors >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($start, $succs) = @args{@reqs};
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my $pre_action  = $args{pre_action} || undef;
   my $post_action = $args{post_action} || undef;
   my $skip_action = $args{skip_action} || undef;
   my %adjacents = ($id_of->($start) => [$succs->($start)]);
   my @stack = ([$start, undef]);
   $pre_action->($start, undef) if $pre_action;
   while (@stack) {
      my ($v, $pred) = @{$stack[-1]}; # "peek"
      my $vid = $id_of->($v);
      if (@{$adjacents{$vid}}) {
         my $w = shift @{$adjacents{$vid}};
         my $wid = $id_of->($w);
         if (exists $adjacents{$wid}) { # already visited
            $skip_action->($w, $v) if $skip_action;
         }
         else {                         # new node to be visited
            $adjacents{$wid} = [$succs->($w)];
            push @stack, [$w, $v];
            $pre_action->($w, $v) if $pre_action;
         }
      }
      else {
         $post_action->($v, $pred) if $post_action;
         pop @stack;
      } # finished with this frame
   }
   return unless defined wantarray; # don't bother with void context
   return keys %adjacents if wantarray;
   return [keys %adjacents] if defined wantarray;
}

1;
