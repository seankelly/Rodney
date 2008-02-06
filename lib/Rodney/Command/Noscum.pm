#!/usr/bin/env perl
package Rodney::Command::Noscum;
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
            column   => 'score',
            value    => 1000,
            operator => '>=',
        );
        $games->limit(
            column   => 'death',
            value    => 'quit',
            operator => '!=',
        );
        $games->limit(
            column   => 'death',
            value    => 'escaped',
            operator => '!=',
        );
    };

    $args->{body} = $subcmd;
    Rodney->dispatch($args) || "Invalid command.";
}

1;

