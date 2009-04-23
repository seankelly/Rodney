package Rodney::Model::Table::Player;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use Fey::Object::Iterator;

has_table(Rodney::Model::Schema->Schema()->table('player'));

has_many(Rodney::Model::Schema->Schema()->table('game'));

sub load_name {
    my $class = shift;
    my $name  = shift;

    my $schema = $class->SchemaClass()->Schema();

    my $select = $class->SchemaClass()->SQLFactoryClass()->new_select();

    my ($player_table) = $schema->table('player');
    my $lower_col = Fey::Literal::Function->new(
        'lower', $player_table->column('name')
    );
    my $lower_name = Fey::Literal::Function->new(
        'lower', Fey::Literal::String->new($name)
    );

    $select->select($player_table)
           ->from($player_table)
           ->where($lower_col, '=', $lower_name);

    my $dbh = $class->_dbh($select);

    return Fey::Object::Iterator->new(
        classes => 'Rodney::Model::Table::Player',
        dbh     => $dbh,
        select  => $select,
    );
}

no Fey::ORM::Table;
1;
