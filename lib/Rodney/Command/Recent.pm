#!/usr/bin/env perl
package Rodney::Command::Recent;
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
            column => 'enddate',
            value => year_ago(),
            operator => '>=',
        );
    };

    $args->{body} = $subcmd;
    Rodney->dispatch($args) || "Invalid command.";
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

