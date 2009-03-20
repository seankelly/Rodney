package Rodney::Command::Zscore;
use strict;
use warnings;
use parent 'Rodney::Command';
use Rodney::Util qw/plural stats fstats/;
use List::Util qw/sum/;

sub run {
    my $self = shift;
    my $args = shift;

    $args->{server_denied} = 1;

    my $games = $self->games($args);
    my $nick = $self->target($args);

    $games->limit(column => 'ascended',
                  value =>  '1',
              );

    unless ($games->count) {
        return "No matches for $nick." if $args->{games_modified};
        return "No games for $nick.";
    }

    my %role;
    my %score;

    while (my $g = $games->next) {
        $role{ $g->role }++;# 1 / (1 + $role{ $g->rol;
        $score{ $g->role } += 1 / $role{ $g->role };
    }

    my $zscore = sum values %score;

    return sprintf '%s has a Z-score of %.6f over %s: %s',
        $nick,
        $zscore,
        plural($games->count, 'ascension'),
        fstats(%score);
}

1;
