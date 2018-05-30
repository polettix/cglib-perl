package ConvexHull;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< convex_hull >;
use constant ACC => 1e-13;

=pod

=head1 SYNOPSIS

   use ConvexHull 'convex_hull'; # shouldn't need this if you embed

   # simple options hash reference as first argument
   my %opts = (
      all => 0,  # include also collinear points on the edge?
   );
   my @points = ([$x0, $y0], [$x1, $y1], ...); # also Vector2D is fine

   # get a (non-closed) list of vertices belonging to the convex hull
   my @ch = convex_hull(\%opts, @points);

=head1 DESCRIPTION

Computes the Convex Hull of a list of points, which can be represented
either as array references (with X, Y coordinates, in order) or through
L<Vector2D> objects. It uses the Graham algorithm.

The first parameter to the function is always a hash reference of
options. As of today, only the C<all> options is supported, to get back
all the points on the hull, even if they are in the middle of a straight
line. By default they are removed. For example, consider the following
list of points (note that one of them is internal):

   [0, 0], [1, 1], [1, 1.5], [2, 2], [0, 2]

By default, the "minimal" convex hull is returned (option C<all> set to
a false value):

   [0, 0], [2, 2], [0, 2]

but with C<all> set to a true value you get back:

   [0, 0], [1, 1], [2, 2], [0, 2]

=cut

sub convex_hull {
   my %opts = %{shift @_};
   my @p = @_ or return;
   for my $i (1 .. $#p) { # put lower-left corner in $p[0]
      @p[0, $i] = @p[$i, 0] if $p[$i][1] < $p[0][1]
         || $p[$i][1] == $p[0][1] && $p[$i][0] < $p[0][0];
   }
   @p[1..$#p] = map { $_->[1] } # sort by increasing angle with x axis
      sort {$b->[0] <=> $a->[0]} # (reverse sort here)
      map {
         my $dx2 = ($_->[0] - $p[0][0]) ** 2;
         my $l2 = $dx2 + ($_->[1] - $p[0][1]) ** 2;
         $dx2 = -$dx2 if $_->[0] < $p[0][0]; # preserve sign
         $l2 > ACC ? [$dx2 / $l2, $_] : ();
      } @p[1..$#p];
   unshift @p, $p[-1]; # not sure really needed, does not really hurt
   my ($l, $K, $L) = (1, @p[0, 1]);
   my ($KLx, $KLy) = ($L->[0] - $K->[0], $L->[1] - $K->[1]);
   POINT: for my $i (2 .. $#p) {
      my $I = $p[$i];
      while ('necessary') { # "backtrack" if clockwise angle
         my ($KIx, $KIy) = ($I->[0] - $K->[0], $I->[1] - $K->[1]);
         my $ccw = $KLx * $KIy - $KLy * $KIx;
         last if $ccw > 0; # counter-clockwise angle is good
         last if $ccw == 0 && $opts{all}; # collect collinears?
         if ($l > 1) { # "pop" one element from stack, update temps
            ($l, $K, $L) = ($l - 1, $p[$l - 2], $K);
            ($KLx, $KLy) = ($L->[0] - $K->[0], $L->[1] - $K->[1]);
         }
         elsif ($i == $#p) { last } # all collinear
         else                   { next POINT }
      }
      @p[$l, $i] = @p[$i, $l] if ++$l != $i;
      ($K, $L) = ($L, $p[$l]);
      ($KLx, $KLy) = ($L->[0] - $K->[0], $L->[1] - $K->[1]);
   }
   return splice @p, 1, $l if wantarray;
   return [splice @p, 1, $l];
}

1;
