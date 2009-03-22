package Rodney::Model::Game;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use DateTime::Format::Pg;

has_table(Rodney::Model::Schema->Schema()->table('game'));

has_one(Rodney::Model::Schema->Schema()->table('player'));

for my $col (qw/start end/) {
    transform $col
        => inflate {
            defined $_[1]
                ? DateTime::Format::Pg->parse_datetime($_[1])
                : $_[1]
        }
        => deflate {
            defined $_[1] && blessed $_[1]
                ? DateTime::Format::Pg->format_datetime($_[1])
                : $_[1]
        };
}

no Fey::ORM::Table;
1;
