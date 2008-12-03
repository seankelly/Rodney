#!/usr/bin/env perl
package Rodney::Command::Noscum;
use strict;
use warnings;
use parent 'Rodney::Command::Meta';

# official: i just loosened the definition of a scum from score == 0 to
#           score < 10   (and dlvl == 1 && (quit or escaped))

sub games_callback {
    my ($self, $games) = @_;
    $games->limit(
        column   => 'score',
        value    => 1000,
        operator => '>=',
    );
    $games->limit(
        column   => 'death',
        value    => 'quit',
        operator => '!=',
    );
    $games->limit(
        column   => 'death',
        value    => 'escaped',
        operator => '!=',
    );
}

1;

