package Matrix;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< M >;
use overload '""' => \&stringify;

sub clone { return bless [@{$_[0]}], __PACKAGE__ }
sub idx { return $_[0][-1] * $_[1] + $_[2] }
sub Mify { return bless $_[0], __PACKAGE__ }
sub M { return Mify([ref($_[0]) ? @{$_[0]} : @_]) }
sub stringify;    # see below
sub v { my $i = idx(@_); @_ > 3 ? ($_[0][$i] = $_[3]) : $_[0][$i] }

sub stringify {
   my ($s, $c, $r) = ($_[0], $_[0][-1], $#{$_[0]} / $_[0][-1]);
   my $l = (sort { $a <=> $b } map { length } @{$s}[0 .. $#$s - 1])[-1];
   my $inner = join "|\n|", map {
      join ' ',
        map { sprintf " %${l}s ", $_ }
        @{$s}[$_ * $c .. ($_ + 1) * $c - 1]
   } 0 .. $r - 1;
   return '|' . $inner . '|';
} ## end sub stringify
