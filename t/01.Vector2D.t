use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;

use constant PI_2 => atan2(1, 0);
use constant TOL => 1e-10;

use Vector2D qw< v intersection >;

{
   my $v;
   lives_ok { $v = v(9, 11) } 'can instantiate';

   is "$v", '(9, 11)', 'stringification via quotes';
   is $v->stringify, '(9, 11)', 'stringification via method';

   ok $v->equals(v(9, 11)), 'equals';
   ok $v == v(9, 11), '==';

   ok abs($v->angle(v(-11, 9)) - PI_2) < TOL, 'angle';
   ok abs(v(1, 0)->angle(v(1, 1)) - v(1, 1)->angle(v(0, 1))) < TOL,
     'angle (2)';
   ok abs($v->angle_deg(v(-11, 9)) - 90) < TOL, 'angle_deg';

   my $w = $v->clone;
   ok $v == $w, 'clone is equal to the original';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v->clone_plus(v(3, 5));
   ok $w == v(12, 16), 'clone_plus';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v + v(3, 5);
   ok $w == v(12, 16), '+ overloaded operator';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v->clone;
   $w->plus(v(3, 5));
   ok $w == v(12, 16), 'plus (in-place)';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v->clone_minus(v(3, 5));
   ok $w == v(6, 6), 'clone_minus';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v - v(3, 5);
   ok $w == v(6, 6), '- overloaded operator';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v->clone;
   $w->minus(v(3, 5));
   ok $w == v(6, 6), 'minus (in-place)';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   my $versor = $v->versor;
   ok abs($versor->length - 1) < TOL, 'versor and its length';
   ok $v == v(9, 11), 'original not changed after clone modification';

   is $v->length_2, 202, 'length_2';
   is $v->dot(v(3, 5)), 82, 'dot product';
   is $v * v(3, 5), 82, 'dot product via overloaded *';

   $w = $v->clone_scale(2);
   ok $w == v(18, 22), 'clone_scale';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v * 2;
   ok $w == v(18, 22), 'scalar product via overloaded *';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = $v->clone;
   $w->scale(2);
   ok $w == v(18, 22), 'scale';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';
   $w->scale_to(sqrt(202)); # return to original size
   ok $w == $v, 'scale_to';

   $w = $v->clone_scale_to(2 * sqrt(202));
   ok $w == v(18, 22), 'clone_scale_to';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   my $q0 = v(1e-16, 1e-16);
   $w = $q0->clone;
   $w->round;
   is "$w", "(0, 0)", 'round... rounded';
   isnt "$q0", "$w", 'stringify different things yields difference';
   ok $w == $q0, 'equality with very little differences makes right thing';

   my $w2 = $q0->clone_round;
   is "$w", "$w2", 'clone_round';

   is $v->cross(v(3, 4)), 3, 'cross product';
   is $v x v(3, 4), 3, 'cross product via overloaded operator x';

   $w = $v->clone;
   $w->normalize;
   ok $w == $v->versor, 'normalize';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   ok $v->orthogonal == v(-11, 9), 'orthogonal';
   ok $v->orthogonal_cw == v(11, -9), 'orthogonal_cw';
   ok $v == v(9, 11), 'original not changed after orthogonal*';

   is $v->x, 9, 'x';
   is $v->y, 11, 'y';

   ok $v->clone_scaled_add(v(1, 1), 3) == v(12, 14), 'clone_scaled_add';
   ok $v == v(9, 11), 'original not changed after clone_scaled_add';

   $w = $v->clone;
   $w->scaled_add(v(1, 1), 3);
   ok $w == v(12, 14), 'scaled_add';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(9, 11), 'original not changed after clone modification';

   $w = v(5, 0);
   $w->project(v(6, 8));
   ok $w == v(1.8, 2.4), 'project' or diag "$w";
   $v = v(5, 0);
   $w2 = $v->clone_project(v(8, -6));
   ok $w2 == v(3.2, -2.4), 'clone_project' or diag "$w2";
   ok $w + $w2 == v(5, 0), 'components are ok';

   ok untangled($v, $w2), 'clone is untangled from original';
   ok $v == v(5, 0), 'original not changed after clone modification';

   $w = $v->clone_rotate_deg(60);
   ok abs($w->x - 5 / 2) < TOL, 'clone_rotate_deg (x)' or diag "$w";
   ok abs($w->length - 5) < TOL, 'clone_rotate_deg (length)';
   ok $w->y > 0, 'clone_rotate_deg (y > 0)';

   $w = $v->clone;
   $w->rotate_deg(60);
   ok abs($w->x - 5 / 2) < TOL, 'rotate_deg (x)' or diag "$w";
   ok abs($w->length - 5) < TOL, 'rotate_deg (length)';
   ok $w->y > 0, 'rotate_deg (y > 0)';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(5, 0), 'original not changed after clone modification';

   $w = $v->clone_rotate(PI_2 / 3);
   ok abs($w->y - 5 / 2) < TOL, 'clone_rotate (y)' or diag "$w";
   ok abs($w->length - 5) < TOL, 'clone_rotate (length)';
   ok $w->x > 0, 'clone_rotate (x > 0)';

   $w = $v->clone;
   $w->rotate(PI_2 / 3);
   ok abs($w->y - 5 / 2) < TOL, 'rotate (y)' or diag "$w";
   ok abs($w->length - 5) < TOL, 'rotate (length)';
   ok $w->x > 0, 'rotate (x > 0)';
   ok untangled($v, $w), 'clone is untangled from original';
   ok $v == v(5, 0), 'original not changed after clone modification';

   my $i = v(1, 0)->intersector(v(1, 1), v(-1, 1));
   ok $i == v(0.5, 0.5), 'intersector (1)' or diag "$i";
   $i = v(1, 0)->intersector(v(1, 1), v(-0.4, 0.4));
   ok $i == v(0.5, 1.25), 'intersector (2)' or diag "$i";
   $i = v(1, 0)->intersector(v(0.2, 0.2), v(-0.4, 0.4));
   ok $i == v(2.5, 1.25), 'intersector (3)' or diag "$i";
   $i = v(1, 0)->intersector(v(-0.2, -0.2), v(-0.4, 0.4));
   ok $i == v(-2.5, 1.25), 'intersector (4)' or diag "$i";

   $i = intersection(v(0, 0), v(1, 1), v(1, 0), v(-1, 1));
   ok $i == v(0.5, 0.5), 'intersection (pts & vectors)' or diag "$i";

   $i = intersection(v(0, 0), v(1, 1), v(1, 0), v(0, 1), all_points => 1);
   ok $i == v(0.5, 0.5), 'intersection (all_points)' or diag "$i";

   $i = intersection(v(0, 0), v(0.2, 0.2), v(1, 0), v(-1, 1));
   ok $i == v(0.5, 0.5), 'intersection (out of segments)' or diag "$i";

   $i = intersection(v(0, 0), v(0.2, 0.2), v(1, 0), v(-1, 1), strict => 1);
   is $i, undef, 'intersection (strict)' or diag "$i";
}

done_testing;


sub untangled {
   my ($v, $w) = @_;
   $w->scale(2);
   return !$v->equals($w);
}
