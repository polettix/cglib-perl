package Matrix;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< eye M >;
use overload '""' => \&stringify;

sub clone { return bless [@{$_[0]}], __PACKAGE__ }
sub eye; # see below
sub kernel; # see below
sub idx { return $_[0][-1] * $_[1] + $_[2] }
sub M { return Mify([ref($_[0]) ? @{$_[0]} : @_]) }
sub Mify { return bless $_[0], __PACKAGE__ }
sub merge_below; # see below
sub merge_right { return $_[0]->T->merge_below($_[1]->clone->T)->T }
sub n_columns { return $_[0][-1] }
sub n_rows { return $#{$_[0]} / $_[0][-1] }
sub stringify;    # see below
sub T; # see below
sub v { my $i = idx(@_); @_ > 3 ? ($_[0][$i] = $_[3]) : $_[0][$i] }

sub eye {
   my ($n, $n2, $i) = ($_[0], $_[0] * $_[0], 0);
   my @array = ((0) x $n2, $n);
   ($array[$i], $i) = (1, $i + $n + 1) while $i < $n2;
   return bless \@array, __PACKAGE__;
}

sub kernel {
   my ($s, $c, $r) = ($_[0]->clone, $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my $bareiss = __PACKAGE__->can('bareiss') ||
      do { require Bareiss; \&Bareiss::bareiss };
   $s->merge_below(eye($c))->T; # ready for row-echelon
   return $bareiss->($s);
}

sub merge_below {
   my ($s, $t, $ct) = ($_[0], $_[1], $_[1][-1]);
   die "cannot just_below(), incompatible matrixes" unless pop(@$s) == $ct;
   @$s = (@$s, @$t);
   return $s;
}

sub stringify {
   my ($s, $c, $r) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my $l = (sort { $a <=> $b } map { length } @{$s}[0 .. $#$s - 1])[-1];
   my $inner = join "|\n|", map { join ' ', map { sprintf " %${l}s ", $_ }
        @{$s}[$_ * $c .. ($_ + 1) * $c - 1] } 0 .. $r - 1;
   return '|' . $inner . '|';
} ## end sub stringify

sub T {
   my ($s, $c, $r, $i) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   @{$s}[map {$i = $_; map {$i + $_ * $r} 0 .. $c - 1} 0 .. $r - 1] = @$s;
   $s->[-1] = $r;
   return $s;
}
