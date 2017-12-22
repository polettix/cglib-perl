use strict;
use warnings;
use lib qw< t/lib . >;
use Test::More;
use Test::Exception;

use AlphaBeta qw< alpha_beta >;

for my $test (tests()) {
   my ($depth, $tree, $ev, $eterms, $epath) = @$test;
   my @terminals;
   my ($v, $p) = alpha_beta(
      state => {
         node => $tree,
         parents => [],
      },
      moves_for => sub {
         my $aref = $_[0]{node};
         return $aref->{children} ? @{$aref->{children}} : ();
      },
      move => sub {
         my ($state, $move) = @_;
         push @{$state->{parents}}, $state->{node};
         $state->{node} = $move;
         return $state;
      },
      rollback => sub {
         my ($state, $move) = @_;
         $state->{node} = pop @{$state->{parents}};
         return $state;
      },
      finished => sub {},
      depth => $depth,
      evaluate => sub {
         push @terminals, $_[0]{node}{id};
         return $_[0]{node}{value};
      },
   );

   is_deeply \@terminals, $eterms, 'terminals visited'
      or diag "(@terminals)";

   my @path = map { $_->{id} } @$p;
   is_deeply \@path, $epath, 'path to "best" terminal'
      or diag "(@path)";

   is $v, $ev, 'value';
}

done_testing;

sub tests {
   return (
      [
         4,
         {
            id => 0,
            children => [
               {
                  id => 1,
                  children => [
                     {
                        id => 3,
                        children => [
                           {
                              id => 7,
                              children => [
                                 { id => 14, value => 3 },
                                 { id => 15, value => 17 },
                              ]
                           },
                           {
                              id => 8,
                              children => [
                                 { id => 16, value => 2 },
                                 { id => 17, value => 12 },
                              ]
                           }
                        ]
                     },
                     {
                        id => 4,
                        children => [
                           {
                              id => 9,
                              children => [
                                 { id => 18, value => 15 },
                              ]
                           },
                           {
                              id => 10,
                              children => [
                                 { id => 19, value => 25 },
                                 { id => 20, value => 0 },
                              ]
                           }
                        ]
                     }
                  ]
               },
               {
                  id => 2,
                  children => [
                     {
                        id => 5,
                        children => [
                           {
                              id => 11,
                              children => [
                                 { id => 21, value => 2 },
                                 { id => 22, value => 5 },
                              ]
                           },
                           {
                              id => 12,
                              children => [
                                 { id => 23, value => 3 },
                              ]
                           }
                        ]
                     },
                     {
                        id => 6,
                        children => [
                           {
                              id => 13,
                              children => [
                                 { id => 24, value => 2 },
                                 { id => 25, value => 14 },
                              ]
                           }
                        ]
                     }
                  ]
               },
            ]
         },
         3,
         [qw< 14 15 16 18 21 23 >],
         [qw< 1 3 7 14 >],
      ],
      [
         3,
         {
            id => 0,
            children => [
               {
                  id => 1,
                  children => [
                     {
                        id => 4,
                        children => [
                                 { id => 13, value => -5 },
                                 { id => 14, value => -6 },
                                 { id => 15, value => -19 },
                        ]
                     },
                     {
                        id => 5,
                        children => [
                                 { id => 16, value => -10 },
                                 { id => 17, value => 8 },
                                 { id => 18, value => 19 },
                        ]
                     },
                     {
                        id => 6,
                        children => [
                                 { id => 19, value => -14 },
                                 { id => 20, value => -6 },
                                 { id => 21, value => 6 },
                        ]
                     },
                  ]
               },

               {
                  id => 2,
                  children => [
                     {
                        id => 7,
                        children => [
                                 { id => 22, value => 8 },
                                 { id => 23, value => 2 },
                                 { id => 24, value => 15 },
                        ]
                     },
                     {
                        id => 8,
                        children => [
                                 { id => 25, value => -17 },
                                 { id => 26, value => 2 },
                                 { id => 27, value => -2 },
                        ]
                     },
                     {
                        id => 9,
                        children => [
                                 { id => 28, value => -17 },
                                 { id => 29, value => 1 },
                                 { id => 30, value => 4 },
                        ]
                     },
                  ]
               },

               {
                  id => 3,
                  children => [
                     {
                        id => 10,
                        children => [
                                 { id => 31, value => 7 },
                                 { id => 32, value => 3 },
                                 { id => 33, value => 11 },
                        ]
                     },
                     {
                        id => 11,
                        children => [
                                 { id => 34, value => -14 },
                                 { id => 35, value => 7 },
                                 { id => 36, value => 8 },
                        ]
                     },
                     {
                        id => 12,
                        children => [
                                 { id => 37, value => 13 },
                                 { id => 38, value => -6 },
                                 { id => 39, value => -4 },
                        ]
                     },
                  ]
               },
            ],
         },
         10,
         [qw< 13 14 15 16 17 18 19 22 23 24 31 32 33 >],
         [qw< 1 5 16 >],
      ]
   );
}
