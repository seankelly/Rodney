#!/usr/bin/env perl
package Rodney::Command::Help;
use strict;
use warnings;
use parent 'Rodney::Command';

use Rodney::Dispatcher;

sub help {
    return 'Gives help for a command.';
}

sub run {
    my $self = shift;
    my $args = shift;

    my ($package, %args) = Rodney::Dispatcher->dispatch($args);
    return unless $package;
    $package->help({%$args, %args});
}

1;

