package Rodney::Game;
use strict;
use warnings;
use DateTime;
use Rodney::Util qw/ntimes plane/;
use Time::Duration;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column player =>
        refers_to Rodney::Player by 'name',
        type is 'varchar',
        is mandatory;

    column gamenum =>
        type is 'integer',
        is mandatory;

    column version =>
        type is 'varchar',
        is mandatory;

    column score =>
        default is 0,
        type is 'integer',
        is mandatory;

    column dungeon =>
        valid_values are qw(dungeon gehennom mines quest sokoban ludios vlad planes),
        is mandatory;

    column curlvl =>
        type is 'integer',
        is mandatory;

    column maxlvl =>
        type is 'integer',
        is mandatory;

    column curhp =>
        type is 'integer',
        is mandatory;

    column maxhp =>
        type is 'integer',
        is mandatory;

    column deaths =>
        type is 'integer',
        is mandatory;

    column enddate =>
        type is 'varchar',
        is mandatory;

    column endtime =>
        type is 'integer';

    column startdate =>
        type is 'varchar',
        is mandatory;

    column starttime =>
        type is 'integer';

    column realtime =>
        type is 'integer';

    column turns =>
        type is 'integer';

    column uid =>
        type is 'integer',
        is mandatory;

    column role =>
        valid_values are qw(Arc Bar Cav Hea Kni Mon Pri Ran Rog Sam Tou Val Wiz),
        is mandatory;

    column race =>
        valid_values are qw(Hum Dwa Elf Gno Orc),
        is mandatory;

    column gender =>
        valid_values are qw(Mal Fem),
        is mandatory;

    column startgender =>
        valid_values are qw(Mal Fem);

    column alignment =>
        valid_values are qw(Law Neu Cha),
        is mandatory;

    column startalignment =>
        valid_values are qw(Law Neo Cha);

    column death =>
        type is 'varchar',
        is mandatory;

    column conduct =>
        type is 'integer';

    column achieve =>
        type is 'integer';

    # stuff we can easily calculate for efficiency/sanity
    column ascended =>
        type is 'boolean',
        default is 'f',
        is mandatory;
};

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

sub started {
    my $self = shift;
    $self->_inflate_date($self->startdate);
}

sub ended {
    my $self = shift;
    $self->_inflate_date($self->ended);
}

sub is_scum {
    my $self = shift;
    $self->score < 1000 && ($self->quit || $self->escaped);
}

sub conducts {
    my $self = shift;
    return () unless defined $self->conduct;

    my @conducts = ( "foodless", "vegan", "vegetarian", "atheist", "weaponless",
        "pacifist", "illiterate", "polypileless", "polyselfless",
        "wishless", "artifact wishless", "genocideless" );
    my @achieved;

    for (my $i = 0; $i <= $#conducts; $i++) {
        push @achieved, $conducts[$i]
            if $self->conduct & (1 << $i);
    }

    return @achieved;
}

sub _inflate_date {
    my $self = shift;
    my $date = shift;

    my ($y, $m, $d) = $date =~ m{^(\d\d\d\d)(\d\d)(\d\d)$}
        or die "Invalid date format: $date";

    return DateTime->new(
        year      => $y,
        month     => $m,
        day       => $d,
        hour      => 0,
        minute    => 0,
        second    => 0,
        time_zone => 'floating',
    );
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
        if ($self->startdate == $self->enddate) {
            $result .= ', on ' . $self->startdate;
        }
        else {
            $result .= ', between ' . $self->startdate . ' and ' . $self->enddate;
        }
    }

    if ($verbosity > 5) {
        $result .= ' on NH v' . $self->version;
    }

    return $result;
}

package Rodney::GameCollection;
use parent 'Jifty::DBI::Collection';

1;

