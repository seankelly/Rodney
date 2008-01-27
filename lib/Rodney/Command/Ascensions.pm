#!/usr/bin/env perl
package Rodney::Command::Ascensions;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;

    my $nick = $self->target($args);
    my $games = $self->games($args);
    my $ascs  = $self->games($args);

    for ($games, $ascs) {
        $_->limit(
            column => 'player',
            value  => $nick,
        );
    }

    $ascs->limit(
        column => 'ascended',
        value  => 1,
    );

    $self->ascensions($args, $ascs, $games, $nick);
}

sub ascensions {
    my $self  = shift;
    my $args  = shift;
    my $ascs  = shift;
    my $games = shift;
    my $nick  = shift;

    if ($games->count == 0) {
        return "No matches for $nick." if $args->{games_modified};
        return "No games for $nick.";
    }

    $nick = $games->first->player->name;

    if ($ascs->count == 0) {
        return "No matches for $nick." if $args->{games_modified};
        return "No ascensions for $nick.";
    }

    my %role;

    while (my $asc = $ascs->next) {
        $role{ $asc->role }++;
    }

    my @parts = map  { "$role{$_}x$_" }
                sort { $role{$b} <=> $role{$a} || $a cmp $b }
                keys %role;

    return sprintf '%s has %s in %s (%.2f%%): %s',
        $nick,
        $self->plural($ascs->count, 'ascension'),
        $self->plural($games->count, 'game'),
        100 * $ascs->count / $games->count,
        join ' ', @parts;
}

1;

