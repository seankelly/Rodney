package Rodney::Command::Bug;
use Moose;
extends 'Rodney::Command';

use Rodney::Model::Table::Bug;

our @COMMANDS = qw/bug bugs/;

sub help {
    return 'Help text for the bugdb';
}

sub run {
    my $self = shift;
    my $args = shift;
}

1;

