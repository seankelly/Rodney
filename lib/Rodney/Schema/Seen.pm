package Rodney::Schema::Seen;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('seen');
__PACKAGE__->add_columns(
    id       => {},
    nick     => {},
    lastseen => { data_type => 'datetime' },
    message  => {},
    channel  => {},
);
__PACKAGE__->set_primary_key(qw/id/);

1;
