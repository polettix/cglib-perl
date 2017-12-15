package TSTrie;
use strict;
use Carp qw< croak >;

use constant CHAR   => 0;
use constant STOP   => 0;
use constant LEFT   => 1;
use constant MID    => 2;
use constant RIGHT  => 3;
use constant VALUE  => 4;
use constant VALUED => 5;

sub contains { my @v = $_[0]->get($_[1]); return @v > 0 }
sub get      ; # see below
sub keys     { return $_[0]->_collect($_[1]) }
sub longest_prefix_of; # see below
sub new      { return bless {n => 0, root => undef}, $_[0] }
sub put      { @{$_[0]->_goto_node($_[1], 1)}[VALUE, VALUED] = ($_[2], 1) }
sub size     { return $_[0]{n} }


# in list context, returns empty list if key is not present, something
# otherwise. In scalar context, absence is flagged by undef, so make sure
# that undef is not a valid VALUE if you want to use this in scalar context
sub get {
   my $node = $_[0]->_goto_node($_[1], 0) || return;
   return $node->[VALUED] ? $node->[VALUE] : ();
}

sub longest_prefix_of {
   my ($self, $prefix) = @_;
   croak 'invalid prefix' unless defined $prefix;
   my $prefix_length = length($prefix) or return ''; # don't bother...
   my $result_length = 0;
   my $x = $self->{root};
   my $d = 0;
   my $c = substr $prefix, $d, 1;
   while (defined($x) && ($d < $prefix_length)) {
      my $xc = $x->[CHAR];
      if    ($c lt $xc) { $x = $x->[LEFT] }
      elsif ($c gt $xc) { $x = $x->[RIGHT] }
      else {
         $c = substr $prefix, $d, 1 if ++$d < $prefix_length;
         $result_length = $d if $x->[VALUED];
         $x = $x->[MID];
      }
   }
   return substr $prefix, 0, $result_length;
}

sub _collect {
   my ($self, $prefix) = @_;
   $prefix = '' unless defined $prefix;
   my $x = length($prefix)
      ? ($self->_goto_node($prefix, 0) || [])->[MID]
      : $self->{root};
   return unless $x;
   my @stack = ([$x, LEFT]);
   my @retval;
   while (@stack) {
      my ($x, $phase) = @{$stack[-1]};
      if ($phase == LEFT) {
         $stack[-1][1] = MID; # move on
         push @stack, [$x->[LEFT], LEFT] if $x->[LEFT];
      }
      elsif ($phase == MID) {
         $prefix .= $x->[CHAR]; # have to "pop" later!
         push @retval, $prefix if $x->[VALUED];
         $stack[-1][1] = RIGHT; # move on
         push @stack, [$x->[MID], LEFT] if $x->[MID];
      }
      elsif ($phase == RIGHT) {
         substr $prefix, -1, 1, ''; # "pop" char
         $stack[-1][1] = STOP; # done!
         push @stack, [$x->[RIGHT], LEFT] if $x->[RIGHT];
      }
      else { pop @stack }
   }
   return @retval;
}

sub _goto_node {
   my ($self, $key, $create) = @_;
   croak 'invalid key' unless defined($key) && (my $l = length $key);
   my $x = \($self->{root});   # reference to node, used for visit
   my $d = 0;                  # displacement in the key
   my $c = substr $key, $d, 1; # current char in visit
   while (($d < $l) && ($create || defined($$x))) {
      my $n = $$x ||= [$c]; # all other fields are undef by default
      my $xc = $n->[CHAR];
      if    ($c lt $xc) { $x = \($n->[LEFT]) }
      elsif ($c gt $xc) { $x = \($n->[RIGHT]) }
      elsif (++$d < $l) { ($x, $c) = (\($n->[MID]), substr($key, $d, 1)) }
   }
   $self->{n}++ if $create && ! defined $$x->[VALUED];
   return $$x;
}

1;
