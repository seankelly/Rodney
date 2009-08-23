package Rodney::Schema::Player;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('player');
__PACKAGE__->add_columns(qw/id name/);
__PACKAGE__->set_primary_key(qw/id/);
__PACKAGE__->has_many(games => 'Rodney::Schema::Game', 'player_id');

sub load_name {
    my $class = shift;
    my $name  = shift;
}

1;
