package Rodney::Schema::Game;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('game');
__PACKAGE__->add_columns(
    id             => {},
    player_id      => {},
    gamenum        => {},
    version        => {},
    score          => {},
    dungeon        => {},
    curlvl         => {},
    maxlvl         => {},
    curhp          => {},
    maxhp          => {},
    deaths         => {},
    start          => { data_type => 'datetime' },
    end            => { data_type => 'datetime' },
    realtime       => {},
    turns          => {},
    uid            => {},
    role           => {},
    race           => {},
    gender         => {},
    startgender    => {},
    alignment      => {},
    startalignment => {},
    death          => {},
    conduct        => {},
    conducts       => {},
    achieve        => {},
    ascended       => {},
);
__PACKAGE__->set_primary_key(qw/id/);

__PACKAGE__->belongs_to(player_id => 'Rodney::Schema::Player');


sub died {
    my $self = shift;
    return not($self->ascended || $self->quit || $self->escaped);
}

sub quit {
    my $self = shift;
    $self->death eq 'quit';
}

sub escaped {
    my $self = shift;
    $self->death eq 'escaped';
}

sub lifesaves {
    my $self = shift;
    my $ls = $self->deaths;
    $ls-- if $self->died;
    return $ls;
}

sub is_scum {
    my $self = shift;
    $self->score < 1000 && ($self->quit || $self->escaped);
}

sub to_string {
    my $self = shift;
    my $verbosity = shift || 0;
    my %args = (
        offset    => 1,
        count     => 0,
        total     => 0,
        @_,
    );
    # offset/count (gamenum/total)
    my $prefix;

    if ($args{count} > 1) {
        $prefix = "$args{offset}/$args{count}";
        if ($args{total}) {
            $prefix .= sprintf ' (%d/%d)',
                $self->gamenum,
                $args{total};
        }
    }
    elsif ($args{count} == 1) {
        $prefix = $self->gamenum;
    }
    else {
        $prefix = $self->id;
    }

    my $result = sprintf '%s. %s (%s %s %s %s), %s, %d points',
        $prefix,
        $self->player->name,
        $self->role, $self->race, $self->gender, $self->alignment,
        $self->death, $self->score;

    if ($verbosity > 2) {
        $result .= ', HP ' . $self->curhp;
        $result .= '(' . $self->maxhp . ')' if $self->maxhp != $self->curhp;
    }

    if ($verbosity > 1) {
        $result .= ', ';
        if ($self->death eq 'ascended') {
            $result .= 'max depth: ' . $self->maxlvl;
            my @conducts = $self->conducts;
            if (@conducts) {
                $result .= ', conducts: ' . scalar(@conducts);
            }
            if (defined $self->realtime) {
                $result .= ', T:' . $self->turns
                    . ' real: ' . concise(duration_exact($self->realtime));
            }
        }
        else {
            if ($self->curlvl == -10) {
                $result .= 'Heaven';
            }
            elsif ($self->curlvl < 0) {
                $result .= plane($self->curlvl);
            }
            else {
                $result .= sprintf 'level %d (%s)', $self->curlvl,
                            ucfirst $self->dungeon;
            }

            if ($self->curlvl != $self->maxlvl) {
                $result .= ', max depth: ' . $self->maxlvl;
            }
        }
    }

    if ($verbosity > 3 && $self->lifesaves) {
        $result .= ', died ' . ntimes($self->lifesaves);
    }

    if ($verbosity > 4) {
        if ($self->start->ymd eq $self->end->ymd) {
            $result .= ', on ' . $self->start->ymd;
        }
        else {
            $result .= ', between ' . $self->start->ymd . ' and ' . $self->end->ymd;
        }
    }

    if ($verbosity > 5) {
        $result .= ' on NH v' . $self->version;
    }

    return $result;
}

1;
