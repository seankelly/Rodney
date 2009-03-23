package Rodney::Model::Player;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use Fey::Object::Iterator;

has_table(Rodney::Model::Schema->Schema()->table('player'));

has_many(Rodney::Model::Schema->Schema()->table('game'));

sub lookup {
    my $class = shift;
    my @lookups = @_;

    my $schema = $class->SchemaClass()->Schema();
    my $select = $class->SchemaClass()->SQLFactoryClass()->new_select();

    my ($player_table) = $schema->tables('player');

    my $search = $select->select($player_table)->from($player_table);

    for my $key (@lookups) {
        next unless ref $key eq 'HASH';
        my $col = $player_table->column((keys %{ $key })[0]);
        next unless defined $col;
    }

    return unless defined $select->where_clause();

    return Fey::Object::Iterator->new(
        classes => $class->meta()->ClassForTable($player_table),
        dbh     => $class->_dbh($select),
        select  => $select,
    );
}

no Fey::ORM::Table;
1;
