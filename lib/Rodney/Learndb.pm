package Rodney::Learndb;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column term =>
        type is 'varchar',
        is mandatory;

    column entry =>
        type is 'integer',
        is mandatory;

    column author =>
        type is 'varchar',
        is mandatory;

    column updated =>
        type is 'integer',
        is mandatory;

    column definition =>
        type is 'varchar',
        is mandatory;
};

sub add {
    my $self = shift;
    my %args = (
        updated => time,
        @_,
    );

    my $entry = Rodney::Learndb->new(handle => $args{handle});

    $entry->create(
        term       => $args{term},
        entry      => $args{entry},
        author     => $args{author},
        updated    => $args{updated},
        definition => $args{definition},
    );
}

sub to_string {
    my $self = shift;
    return sprintf "%s[%d]: %s",
           $self->term,
           $self->entry,
           $self->definition;
}

sub TABLE_NAME { 'learndb' }

package Rodney::LearndbCollection;
use parent 'Jifty::DBI::Collection';


# then add the Undo part
package Rodney::LearndbUndo;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column entryid =>
        type is 'integer',
        references Rodney::Learndb by 'id',
        is mandatory;

    column who =>
        type is 'varchar',
        is mandatory;

    column updated =>
        type is 'integer',
        default is time,
        is mandatory;

    column definition =>
        type is 'varchar',
        is mandatory;
};

sub TABLE_NAME { 'learndb_undo' }

package Rodney::LearndbUndoCollection;
use parent 'Jifty::DBI::Collection';

1;

