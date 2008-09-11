#!/usr/bin/env perl
package Rodney::Command::Min;
use strict;
use warnings;
use parent 'Rodney::Command::Meta';

sub help {
    return 'Sorts the games by the given column, ascending.';
}

sub games_callback {
    my $self = shift;
    my $games = shift;
    my $args = shift;

    return unless defined $args->{text};
    $args->{text} =~ /:(\w+)/;
    return unless defined $1;
    return unless Rodney::Game->column($1);
    my $field = $1;

    # order column by field, ascending
    $games->add_order_by(
        column => $field,
        order  => 'asc',
    );
}

1;

