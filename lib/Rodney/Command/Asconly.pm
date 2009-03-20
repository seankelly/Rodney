#!/usr/bin/env perl
package Rodney::Command::Asconly;
use strict;
use warnings;
use parent 'Rodney::Command::Meta';

sub games_callback {
    my ($self, $games) = @_;
    $games->limit(
        column   => 'ascended',
        value    => 1,
    );
}

1;

