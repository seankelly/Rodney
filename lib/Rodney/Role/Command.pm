package Rodney::Role::Command
use Moose::Role;

# Command method returns a list of commands.
# Run is what's used to run the command.
requires qw/command run/;

no Moose::Role;

1;
