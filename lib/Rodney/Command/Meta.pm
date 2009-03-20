#!/usr/bin/env perl
package Rodney::Command::Meta;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;

    if ($self->can('games_callback')) {
        my %argscopy = %$args;
        push @{ $args->{games_callback} },
            [
                $self->can('games_callback'),
                \%argscopy,
            ];
    }

    $args->{body} = $args->{subcommand} || $args->{args};
    Rodney->dispatch($args) || $self->cant_redispatch($args);
}

sub cant_redispatch { "Invalid command." }

sub is_command { 0 }

1;

