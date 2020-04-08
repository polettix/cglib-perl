package ConstraintSolver;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< solve_by_constraints >;

sub solve_by_constraints {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< constraints is_done search_factory start >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($constraints, $done, $factory, $state, @stack) = @args{@reqs};
   my $logger = $args{logger} // undef;
   while ('necessary') {
      last if eval {    # eval - constraints might complain loudly...
         $logger->(validating => $state) if $logger;
         my $changed = -1;
         while ($changed != 0) {
            $changed = 0;
            $changed += $_->($state) for @$constraints;
            $logger->(pruned => $state) if $logger;
         } ## end while ($changed != 0)
         $done->($state) || (push(@stack, $factory->($state)) && undef);
      };
      $logger->(backtrack => $state, $@) if $logger;
      while (@stack) {
         last if $stack[-1]->($state);
         pop @stack;
      }
      return unless @stack;
   } ## end while ('necessary')
   return $state;
} ## end sub solve_by_constraints

1;
