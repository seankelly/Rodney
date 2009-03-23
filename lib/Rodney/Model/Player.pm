package Rodney::Model::Player;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use Fey::Object::Iterator;

has_table(Rodney::Model::Schema->Schema()->table('player'));

has_many(Rodney::Model::Schema->Schema()->table('game'));

no Fey::ORM::Table;
1;
