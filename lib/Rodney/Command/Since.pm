#!/usr/bin/env perl
package Rodney::Command::Since;
use strict;
use warnings;
use parent 'Rodney::Command::Meta';

sub help {
    return "Lists information about a player's games since (and including) a specific ascension number. By default it uses the most recent ascension. Example usage: !since #4 !gamesby";
}

sub games_callback {
    my $self = shift;
    my $games = shift;
    my $args = shift;

    $args->{text} =~ /#(\d+)/;
    my $asc = $1;

    my $_games = $games->clone;

    # have to find the gamenum for this ascension
    $_games->limit(
        column => 'ascended',
        value  => 't',
    );

    return "Don't have that many ascensions"
        if defined $asc && $_games->count < $asc;

    if (defined $asc) {
        $_games->set_page_info(
            per_page     => 1,
            current_page => $asc,
        );

        $games->limit(
            column   => 'gamenum',
            value    => $_games->first->gamenum,
            operator => '>=',
        );
    }
    else {
        $games->limit(
            column   => 'gamenum',
            value    => $_games->last->gamenum,
            operator => '>=',
        );
    }
}

1;

