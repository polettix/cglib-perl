package MonteCarloTreeSearch;
use strict;
use Exporter qw< import>;
our @EXPORT_OK = qw< monte_carlo_tree_search monte_carlo_tree_searcher >;
use List::Util qw< shuffle >;

sub monte_carlo_tree_search {
   my %args = (@ && ref($_[0])) ? %{$_[0]} : @_;
   my $searcher = monte_carlo_tree_searcher(\%args);
   $searcher->study_for($args{study_amount});
   return $searcher->best_move;
}

sub monte_carlo_tree_searcher {
   my %args = (@ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< moves_for move state winners >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   $args{selection_score} ||= sub {
      my ($pn, $cn, $cscore) = @_;
      return $cscore / $cn + sqrt(2 * log($pn) / $cn);
   };
   $args{random_move_for} ||= sub {
      my @moves = $args{moves_for}->($_[0]);
      return $moves[rand @moves];
   };
   $args{tree} = {state => $args{state}, n => 0, score => 0};
   return bless \%args, __PACKAGE__;
}

sub study_for {
   my ($self, $amount) = ($_[0], $_[1] || '0.07s');
   if (my ($seconds) = $amount =~ m{\A ([\d.]+)s \z}mxs) {
      require Time::HiRes;
      my $deadline = Time::HiRes::time() + $seconds;
      $self->study_cycle while Time::HiRes::time() < $deadline;
   }
   elsif (my ($n) = $amount =~ m{\A \# (\d+) \z}mxs) {
      $self->study_cycle while $n-- > 0;
   }
   else { die "unknown amount for study <$amount>" }
}

sub study_cycle {
   my $self = shift;
   my $trail = $self->_selection;
   $self->_expansion($trail) if $trail->[-1]{n}; # expand if necessary
   my $winners = $self->_simulation($trail);
   $self->_backpropagation($trail, $winners);
   return $self;
}

sub _selection {
   my ($self, $ssc, @trail) = ($_[0], $_[0]{selection_score}, $_[0]{tree});
   while (defined(my $nodes = $trail[-1]{next_nodes})) {
      my $uxones = $trail[-1]{unexplored_next_nodes};
      if (@$uxones) { push @trail, shift @$uxones }
      else { # exploit vs explore here
         my ($best, $bscr);
         for my $n (@$nodes) {
            my $scr = $ssc->($trail[-1]{n}, @{$n}{qw< n score >});
            ($best, $bscr) = ($n, $scr) if (!defined($best)) || ($scr > $bscr);
         }
         push @trail, $best;
      }
   }
   return \@trail;
}

sub _expansion {
   my ($mv, $mvf, $trail) = ($_[0]{move}, $_[0]{moves_for}, $_[1]);
   my ($n, $s) = ($trail->[-1], $trail->[-1]{state});
   my @nns = shuffle map { my ($m, $p) = $_->@*;
      { move => $m, player => $p, state => $mv->($s, $m) } } $mvf->($s);
   @{$n}{qw< next_nodes unexplored_next_nodes >} = ([@nns], \@nns);
   push @$trail, shift @nns;
   return $trail;
}

sub _simulation {
   my ($self, $trail, $state) = (@_[0, 1], $_[1][-1]{state});
   my ($mv, $rmf, $wins) = @{$self}{qw< move random_move_for winners >};
   while ('necessary') {
      if (my $winners = $wins->($state)) { return $winners }
      my $rm = $rmf->($state)->[0];
      $state = $mv->($state, $rmf->($state)->[0]);
   }
}

sub _backpropagation {
   my ($self, $trail, %won) = (@_[0,1], map {$_ => 1} @{$_[2]});
   my $player_for = $self->{player_for};
   my $nws = scalar keys %won or return $self;
   for my $n (@$trail) {
      $n->{n}++;
      $n->{score} += 1 / $nws if defined $n->{player} && $won{$n->{player}};
   }
   return $self;
}

sub best_move {
   my ($nodes, $bn, $bc) = ($_[0]{tree}{next_nodes});
   for my $n (@$nodes) {
      ($bn, $bc) = ($n, $n->{n}) if (! defined $bc) || ($bc < $n->{n});
   }
   return $bn->{move} unless wantarray;
   return @{$bn}{qw< move player >};
}

1;
