package Rodney::Schema::Bug;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('bug');
__PACKAGE__->add_columns(qw/bugid status description/);
__PACKAGE__->set_primary_key('bugid');

1;
