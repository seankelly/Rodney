package Rodney::Game;
use strict;
use warnings;
use DateTime;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column player =>
        refers_to Rodney::Player by 'name',
        type is 'varchar',
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

    column startdate =>
        type is 'varchar',
        is mandatory;

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

    column alignment =>
        valid_values are qw(Law Neu Cha),
        is mandatory;

    column death =>
        type is 'varchar',
        is mandatory;

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

package Rodney::GameCollection;
use parent 'Jifty::DBI::Collection';

1;

