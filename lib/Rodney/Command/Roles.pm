package Rodney::Command::Roles;
use strict;
use warnings;
use parent 'Rodney::Command';
use Rodney::Util qw/plural stats/;

sub help {
    return 'Which roles were played';
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

    my %role;

    while (my $g = $games->next) {
        $role{ $g->role }++;
    }

    return sprintf '%s has played %s: %s',
        $nick,
        plural($games->count, 'game'),
        stats(%role);
}

1;


