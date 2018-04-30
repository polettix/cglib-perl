package Vector2D;
use strict;
use Exporter qw< import >;
use POSIX ();
our @EXPORT_OK = qw< v intersection >;
use constant RAD2DEG => 90 / atan2(1, 0);
use constant DEG2RAD => atan2(1, 0) / 90;
use constant ACC => 1e-13;
use overload
  '+'        => sub { $_[0]->clone->plus($_[1]) },
  '-'        => sub { $_[0]->clone->minus($_[1]) },
  '*'        => \&_mult,
  'x'        => sub { $_[0]->cross($_[1]) },
  '=='       => sub { $_[0]->equals($_[1]) },
  '""'       => sub { $_[0]->stringify },
  'fallback' => undef;

sub angle { return atan2($_[0]->cross($_[1]), $_[0]->dot($_[1])) }
sub angle_deg       { return $_[0]->angle($_[1]) * RAD2DEG }
sub clone           { return ref($_[0])->new($_[0]) }
sub clone_project   { my $v = $_[1]->versor; $v->scale($_[0]->dot($v)) }
sub cross           { return $_[0][0] * $_[1][1] - $_[0][1] * $_[1][0] }
sub distance_from   { return $_[0]->clone->minus($_[1])->length }
sub distance_2_from { return $_[0]->clone->minus($_[1])->length_2 }
sub dot             { return $_[0][0] * $_[1][0] + $_[0][1] * $_[1][1] }
sub equals { return $_[0]->clone->minus($_[1])->length_2 < ACC ? 1 : 0; }
sub intersection;    # see below
sub intersector;     # see below
sub invert { $_ = -$_ for @{$_[0]}; return $_[0] }
sub length   { return sqrt($_[0]->length_2) }
sub length_2 { return $_[0]->dot($_[0]) }
sub minus    { return $_[0]->scaled_add($_[1], -1) }
sub new      { return bless [ref($_[1]) ? @{$_[1]} : @_[1 .. $#_]], $_[0] }
sub normalize { return $_[0]->scale(1 / $_[0]->length) }
sub on_grid { $_ = int POSIX::floor($_ + 0.5) for @{$_[0]}; return $_[0] }
sub orthogonal    { return v(-$_[0][1], $_[0][0]) }
sub orthogonal_cw { return v($_[0][1],  -$_[0][0]) }
sub plus { return $_[0]->scaled_add($_[1], 1) }
sub project { @{$_[0]} = @{$_[0]->clone_project($_[1])}; return $_[0] }
sub rotate;          # see below
sub rotate_deg { return $_[0]->rotate($_[1] * DEG2RAD) }
sub round;           # see below
sub scale { $_[0][$_] *= $_[1] for 0 .. $#{$_[0]}; return $_[0] }
sub scaled_add;      # see below
sub scale_to  { return $_[0]->scale($_[1] / $_[0]->length) }
sub stringify { return '(' . join(', ', @{$_[0]}) . ')' }
sub v         { return __PACKAGE__->new(@_) }
sub versor    { return $_[0]->clone->normalize }
sub x         { $_[0][0] = $_[1] if @_ > 1; return $_[0][0] }
sub y         { $_[0][1] = $_[1] if @_ > 1; return $_[0][1] }

sub intersection {
   my ($A, $v, $C, $w, %opts) = @_;
   if ($opts{all_points}) {    # make sure $v and $w are relative vectors
      $v = $v->clone->minus($A);
      $w = $w->clone->minus($C);
   }
   my ($alpha, $beta) = @{$C->clone->minus($A)->intersector($v, $w)};
   return
     if $opts{strict}
     && !((0 <= $alpha) && ($alpha <= 1) && (0 <= $beta) && ($beta <= 1));
   return $A->clone->scaled_add($v, $alpha);
} ## end sub intersection

# intersection parameters between segments AB and CD, with AB = $v,
# CD = $w and AC = $l
sub intersector {
   my $den = $_[1]->cross($_[2]);
   return if abs($den) < ACC;
   return v($_[0]->cross($_[2]) / $den, $_[0]->cross($_[1]) / $den);
}

sub _mult { ref($_[1]) ? $_[0]->dot($_[1]) : $_[0]->clone->scale($_[1]) }

sub rotate {
   my ($x, $y, $c, $s) = ($_[0][0], $_[0][1], cos($_[1]), sin($_[1]));
   @{$_[0]} = ($x * $c - $y * $s, $x * $s + $y * $c);
   return $_[0];
}

sub round {    # FIXME?
   for (@{$_[0]}) { $_ = 0 if abs($_) < ACC }
   return $_[0];
}

sub scaled_add {
   my ($self, $other, $factor) = @_;
   $factor = 1 unless defined $factor;
   $self->[$_] += $factor * $other->[$_] for 0 .. $#$self;
   return $self;
} ## end sub scaled_add

1;
