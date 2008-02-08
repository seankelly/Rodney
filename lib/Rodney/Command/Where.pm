#!/usr/bin/env perl
package Rodney::Command::Where;
use strict;
use warnings;
use parent 'Rodney::Command';
use Rodney::Util qw/plane plural stats/;

sub help {
    return 'Where a player died';
}

sub run {
    my $self = shift;
    my $args = shift;

    $args->{server_denied} = 1;

    my $games = $self->games($args);
    my $nick = $self->target($args);

    unless ($games->count) {
        return "No matches for $nick." if $args->{games_modified};
        return "No games for $nick.";
    }

    my %where;

    while (my $g = $games->next) {
        if ($g->dungeon ne 'planes') {
            $where{ ucfirst($g->dungeon) }++;
        }
        elsif ($g->ascended) {
            $where{Asc}++;
        }
        else {
            $where{ plane($g->curlvl, 1) }++;
        }
    }

    return sprintf '%s has ended %s: %s',
        $nick,
        plural($games->count, 'game'),
        stats(%where);
}

1;

