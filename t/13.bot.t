#!/usr/bin/env perl
use strict;
use Test::More;
use File::Basename qw< dirname >;

do(dirname(dirname(__FILE__)) . '/bot') or BAIL_OUT 'cannot load bot file';
can_ok MyRound => qw< clone new readline readchomplines >;
can_ok MyBot   => qw< clone new readline readchomplines run >;

done_testing;
