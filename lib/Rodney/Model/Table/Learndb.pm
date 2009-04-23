package Rodney::Model::Table::Learndb;
use Rodney::Model::Schema;
use Fey::ORM::Table;
use DateTime::Format::ISO8601;

has_table(Rodney::Model::Schema->Schema()->table('learndb'));

transform 'updated'
    => inflate {
        DateTime::Format::ISO8601->parse_datetime($_[1])
    }
    => deflate {
        defined $_[1] && blessed $_[1]
            ? DateTime::Format::ISO8601->format_datetime($_[1])
            : $_[1]
    };


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

no Fey::ORM::Table;
1;
