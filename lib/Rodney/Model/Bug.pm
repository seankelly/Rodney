package Rodney::Model::Bug;
use Rodney::Model::Schema;
use Fey::ORM::Table;

has_table(Rodney::Model::Schema->Schema()->table('bug'));
