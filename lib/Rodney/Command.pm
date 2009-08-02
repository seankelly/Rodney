package Rodney::Command;
use Module::Pluggable
    require     => 1,
    search_path => 'Rodney::Plugin',
    sub_name    => 'plugins';
use Moose;

=head2 commands

Returns a list of modules that are commands.

=cut

sub commands {
    grep { $_->does('Rodney::Role::Command') } shift->plugins;
}


__PACKAGE__->meta->make_immutable;

1;

