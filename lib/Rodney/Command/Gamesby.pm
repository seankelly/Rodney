#!/usr/bin/env perl
package Rodney::Command::Gamesby;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;

    my $nick = $self->target($args);
    my $games = $self->games($args);

    $games->limit(
        column => 'player',
        value  => $nick,
    );

    $self->gamesby($games, $nick);
}

sub gamesby {
    my $self  = shift;
    my $games = shift;
    my $nick  = shift;

    return "No games for $nick." if $games->count == 0;

    undef $nick;

    my ($start, $end, $high, $ascensions, $deaths,
        $lifesaves, $quits, $escapes);

    while (my $game = $games->next) {
        $nick ||= $game->player->name;

        ++$ascensions if $game->ascended;
        ++$deaths     if $game->died;
        ++$quits      if $game->quit;
        ++$escapes    if $game->escaped;

        $lifesaves += $game->lifesaves;

        $start ||= $game->startdate;
        $end = $game->enddate;

        $high = $game->score
            if !defined($high) || $game->score > $high;
    }

    my @parts;
    push @parts, "ascended "  . $self->once($ascensions) if $ascensions;
    push @parts, "died "      . $self->once($deaths)     if $deaths;
    push @parts, "lifesaved " . $self->once($lifesaves)  if $lifesaves;
    push @parts, "quit "      . $self->once($quits)      if $quits;
    push @parts, "escaped "   . $self->once($escapes)    if $escapes;

    return sprintf '%s has played %s, between %s and %s, highest score %s, %s.',
        $nick,
        $self->plural($games->count, 'game'),
        $start,
        $end,
        $high,
        join ', ', @parts;
}

1;

