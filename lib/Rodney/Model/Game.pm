package Rodney::Model::Game;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use DateTime::Format::ISO8601;

has_table(Rodney::Model::Schema->Schema()->table('game'));

has_one(Rodney::Model::Schema->Schema()->table('player'));

for my $col (qw/start end/) {
    transform $col
        => inflate {
            DateTime::Format::ISO8601->parse_datetime($_[1])
        }
        => deflate {
            defined $_[1] && blessed $_[1]
                ? DateTime::Format::ISO8601->format_datetime($_[1])
                : $_[1]
        };
}

no Fey::ORM::Table;
1;
