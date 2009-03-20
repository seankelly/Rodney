package Rodney::Command::Outfoxed;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Lists the highest-scoring death directly attributable to a fox.';
}

sub run {
    my $self = shift;
    my $args = shift;

    $args->{server_denied} = 1;

    my $games = $self->games($args);
    my $target = $self->target($args);

    $games->limit(
        column => 'death',
        value  => "(?:killed by a(?:n invisible)?(?: hallucinogen-distorted)? fox(?: called .*?)?(?:, while helpless)?|poisoned by a rotted fox corpse|choked on a (?:tin of fox meat|fox corpse)|killed by kicking a (?:tin of fox meat|fox corpse))(?: \(with the Amulet\))?",
        operator => '~',
    );

    # order by score unless another ordering is specified
    $games->add_order_by(
        column => 'score',
        order  => 'desc',
    ) unless $games->_order_clause;

    if ($games->first) {
        return $games->first->to_string(100, count => $games->count);
    }
    else {
        return "$target has not been outfoxed.";
    }
}

1;

