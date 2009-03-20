package Rodney::Command::Recent;
use strict;
use warnings;
use parent 'Rodney::Command::Meta';

sub games_callback {
    my ($self, $games) = @_;
    $games->limit(
        column => 'enddate',
        value => year_ago(),
        operator => '>=',
    );
}

sub year_ago {
    my (undef, undef, undef, $d, $m, $y) = gmtime;
    $y += 1900;
    $m++;

    return sprintf '%04d%02d%02d',
        $y - 1,
        $m,
        $d;
}

1;

