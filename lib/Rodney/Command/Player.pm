package Rodney::Command::Player;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Returns URL for a player\' NAO page.';
}

sub run {
    my $self = shift;
    my $args = shift;

    $args->{server_denied} = 0;

    my $player = Rodney::PlayerCollection->new(handle => $args->{handle});
    my $target = $self->target($args);
    my $targetlong = $self->target($args, 1);

    $player->limit(
        column => 'name',
        value  => $target,
    );

    if ($player->first) {
        my $name = $player->first->name;
        if (length($targetlong) > 10) {
            $name .= substr $targetlong, 10;
        }
        return 'http://alt.org/nethack/plr.php?player=' . $name;
    }
    else {
        return 'No such player found.';
    }
}

1;

