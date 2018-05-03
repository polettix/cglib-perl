package Matrix;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< M >;
use overload '""' => \&stringify;

sub clone { return M(@{$_[0]}{qw< r c d >}) }
sub idx   { return $_[0]{c} * $_[1] + $_[2] }
sub M     { return __PACKAGE__->new(@_) }
sub new;          # see below
sub stringify;    # see below
sub v { return $_[0]{d}[$_[0]{c} * $_[1] + $_[2]] }
sub V { return $_[0]{d}[$_[0]{c} * $_[1] + $_[2]] = $_[3] }

sub new {
   my ($p, $r, $c, $d) = @_;
   return bless {r => $r, c => $c, d => [$d ? @$d : (0) x ($r * $c)]}, $p;
}

sub stringify {
   my ($s) = @_;
   my $inner = join " |\n| ", map {
      join '  ',
        map { sprintf '%2s', $_ }
        @{$s->{d}}[$_ * $s->{c} .. ($_ + 1) * $s->{c} - 1]
   } 0 .. $s->{r} - 1;
   return '| ' . $inner . ' |';
} ## end sub stringify
