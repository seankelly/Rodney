package Rodney::Schema::Learndb;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('learndb');
__PACKAGE__->add_columns(
    id         => {},
    deleted    => {},
    outdated   => {},
    term       => {},
    entry      => {},
    author     => {},
    updated    => { data_type => 'datetime' },
    definition => {},
);
__PACKAGE__->set_primary_key(qw/id/);


sub normal_term {
    my $self = shift;
    my $term;
    ($term = $self->term) =~ tr/ /_/;
    return $term;
}

sub to_string {
    my $self = shift;
    return sprintf "%s[%d]: %s",
           $self->normal_term,
           $self->entry,
           $self->definition;
}

1;
