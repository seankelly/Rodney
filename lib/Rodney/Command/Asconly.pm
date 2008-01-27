#!/usr/bin/env perl
package Rodney::Command::Asconly;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;
    my $subcmd = shift;

    push @{ $args->{games_callback} }, sub {
        my ($self, $games) = @_;
        $games->limit(
            column   => 'ascended',
            value    => 1,
        );
    };

    $args->{body} = $subcmd;
    Rodney::Dispatcher->dispatch($args) || "Invalid command.";
}

1;

