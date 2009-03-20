package Rodney::Command::Gamesby;
use strict;
use warnings;
use parent 'Rodney::Command';
use Rodney::Util qw/plural once/;

sub run {
    my $self = shift;
    my $args = shift;

    $args->{server_denied} = 1;

    my $nick = $self->target($args);
    my $games = $self->games($args);

    $self->gamesby($args, $games, $nick);
}

sub gamesby {
    my $self  = shift;
    my $args  = shift;
    my $games = shift;
    my $nick  = shift;

    if ($games->count == 0) {
        return "No matches for $nick." if $args->{games_modified};
        return "No games for $nick.";
    }

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
    push @parts, "ascended "  . once($ascensions) if $ascensions;
    push @parts, "died "      . once($deaths)     if $deaths;
    push @parts, "lifesaved " . once($lifesaves)  if $lifesaves;
    push @parts, "quit "      . once($quits)      if $quits;
    push @parts, "escaped "   . once($escapes)    if $escapes;

    my $date = $start eq $end ? "on $start" : "between $start and $end";

    return sprintf '%s has played %s, %s, highest score %s, %s.',
        $nick,
        plural($games->count, 'game'),
        $date,
        $high,
        join ', ', @parts;
}

1;

