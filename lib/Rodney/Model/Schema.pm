package Rodney::Model::Schema;
use Fey::DBIManager;
use Fey::DBIManager;
use Fey::Loader;
use Fey::ORM::Schema;

my $source = Fey::DBIManager::Source->new(dsn => 'dbi:Pg:dbname=nethack2');

my $schema = Fey::Loader->new(dbh => $source->dbh)->make_schema();

has_schema $schema;

__PACKAGE__->DBIManager()->add_source($source);

no Fey::ORM::Schema;
1;
