package Rodney::Command::Ascstreak;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Ascension streak for a player.';
}

sub run {
    my $self = shift;
    my $args = shift;

    $args->{server_denied} = 1;

    my $games = $self->games($args);
    my $nick  = $self->target($args);

    my %streak = (
        ascensions => 0,
        max        => 0,
        current    => 0,
        active     => 0,
        since      => 0,
        list       => [],
        maxlist    => [],
    );

    my $count = $games->count;

    while (my $g = $games->next) {
        if ($g->death eq 'ascended') {
            $streak{since} = 0;
            $streak{ascensions}++;
            $streak{current}++;
            $streak{begin} = $g->gamenum unless $streak{begin};
            push @{$streak{list}}, $g->role;
            if ($streak{current} > $streak{max}) {
                $streak{max} = $streak{current};
                $streak{maxlist} = $streak{list};
                $streak{maxbegin} = $streak{begin}
            }
        }
        else {
            # end current streak
            $streak{begin} = 0;
            $streak{current} = 0;
            $streak{list} = [];
            $streak{since}++;
        }
    }

    if ($streak{ascensions} == 0) {
        return sprintf '%s has no ascensions in %d games.',
                       $nick, $count;
    }
    elsif ($streak{ascensions} == 1) {
        my $res = sprintf '%s has one ascension in %d games',
                          $nick, $count;
        if ($streak{since} == 0) {
            $res .= ', and can keep going!' 
        }
        else {
            $res .= ', and has played ' . $streak{since} . ' games since.'; 
        }
        return $res;
    }
    else {
        my $res;

        if ($streak{max} > 1) {
            $res = sprintf '%s has %d consecutive ascensions (#%d-%d): %s',
                           $nick, $streak{max}, $streak{maxbegin},
                           $streak{maxbegin} + $streak{max} - 1,
                           join(', ', @{ $streak{maxlist} });
        }
        else {
            $res = sprintf '%s has %d ascensions, none consecutive, in %d games',
                           $nick, $streak{ascensions}, $count;
        }

        if ($streak{max} > $streak{current} && $streak{current} > 0) {
            my $plural = $streak{current} > 1 ? 's' : '';
            my $range = $streak{begin} .
                        ($streak{current} > 1
                        ? '-' . $streak{begin} + $streak{current} - 1
                        : '');
            $res .= sprintf '; and has ascended past %d game%s (#%s): %s.',
                            $streak{current}, $plural, $range,
                            join(', ', @{ $streak{list} });
        }
        else {
            # ooh, exciting, I know
            $res .= '.';
        }

        return $res;
    }
}

1;

