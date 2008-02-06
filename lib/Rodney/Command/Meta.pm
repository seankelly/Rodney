#!/usr/bin/env perl
package Rodney::Command::Meta;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;

    if ($self->can('games_callback')) {
        push @{ $args->{games_callback} },
            $self->can('games_callback');
    }

    $args->{body} = $args->{subcommand};
    Rodney->dispatch($args) || "Invalid command.";
}

1;

