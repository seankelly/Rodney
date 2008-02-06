#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Rodney;

my $rodney = Rodney->new(
    server   => "irc.freenode.org",
    channels => ["#rodney"],
    nick     => "Rodney4",
);

$rodney->run;

