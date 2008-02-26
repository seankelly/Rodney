#!/usr/bin/env perl
package Rodney::Command::Cmdlist;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Returns list of all commands';
}

sub run {
    my $self = shift;
    my $args = shift;

    my @packages = qw/Ascensions Gamesby Min Recent Asconly Grep Monsterify Rng
            Where Help Noscum Roles Zscore Max Num Rot13 Date Player Seen/;

    my %commands;

    for (@packages) {
        my $package = 'Rodney::Command::' . $_;
        if ($package->can('cant_redispatch')) {
            $commands{$_} = 'm';
            $commands{$_} .= 'r' if $package->is_command;
        }
        else {
            $commands{$_} = 'r';
        }
    }

    my @result = map { lc $_ . '{' . $commands{$_} . '}' } sort keys %commands;
    return join(', ', @result);
}

1;
