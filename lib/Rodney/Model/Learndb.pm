package Rodney::Model::Learndb;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use DateTime::Format::ISO8601;

has_table(Rodney::Model::Schema->Schema()->table('learndb'));

transform 'updated'
    => inflate {
        defined $_[1]
            ? DateTime::Format::ISO8601->parse_datetime($_[1])
            : $_[1]
    }
    => deflate {
        defined $_[1] && blessed $_[1]
            ? DateTime::Format::ISO8601->format_datetime($_[1])
            : $_[1]
    };

no Fey::ORM::Table;
1;
