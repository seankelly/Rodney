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

# helper methods
####################

# returns number of entries for a term
sub _entries {
    my $handle = shift;
    my $term = shift;

    my $collection = Rodney::LearndbCollection->new(handle => $handle);

    _setup($collection, $term);

    return $collection->count;
}

# tests to see if the term (and possibly entry) exist
sub _exists {
    my $handle = shift;
    my $term = shift;
    my $entry = shift;

    my $collection = Rodney::LearndbCollection->new(handle => $handle);

    _setup($term, $entry);

    return $collection->count;
}

sub _normalize {
    my $arg = shift;

    # term = $1, entry = $2
    $arg =~ /^(.*?)(?:\[(\d+)\])?$/;
    return ($1, $2);
}

sub _setup {
    my $collection = shift;
    my $term = shift;
    my $entry = shift;
    my $operator = shift;

    $collection->unlimit;

    $collection->limit(
        column => 'term',
        value  => $term,
    );

    my %entry = (
        column => 'entry',
        value  => $entry,
    );

    $entry{operator} = $operator if defined $operator;

    $collection->limit(%entry) if defined $entry;
}

# "public" methods
####################

sub add {
    my $self = shift;
    my %args = (
        updated => time,
        @_,
    );

    my $entry = Rodney::Learndb->new(handle => $args{handle});

    $args{entry} = _entries($args{handle}, $args{term}) + 1;

    $entry->create(
        term       => $args{term},
        entry      => $args{entry},
        author     => $args{author},
        updated    => $args{updated},
        definition => $args{definition},
    );
}

sub del {
    my $self = shift;
    my %args = (@_);

    return unless defined $args{term} && defined $args{handle};

    my $collection = Rodney::LearndbCollection->new(handle => $args{handle});

    _setup($collection, $args{term}, $args{entry});

    if (defined $args{entry}) {
        return 'Entry not found.' if $collection->count == 0;
        return 'Too many entries matched.' if $collection->count > 1;

        my $text = $collection->first->to_string;
        $collection->first->delete;

        _setup($collection, $args{term}, $args{entry}, '>');

        while (my $next = $collection->next) {
            $next->set_entry($next->entry - 1);
        }

        return $text;
    }
    else {
        # delete entire term
        return 'Term not found.' if $collection->count == 0;
        my $deleted = 0;

        while (my $entry = $collection->next) {
            $deleted++ if $entry->delete;
        }

        return 'Deleted ' . $deleted . ' entries.';
   }
}

sub info {
    my $self = shift;
    my %args = (@_);
}

sub query {
    my $self = shift;
    my %args = (@_);

    my $collection = Rodney::LearndbCollection->new(handle => $args{handle});

    _setup($collection, $args{term}, $args{entry});
    return if $collection->count == 0;

    if (defined $args{entry}) {
        return ($collection->first->to_string);
    }
    else {
        $collection->order_by(
            column => 'entry',
            order  => 'asc',
        );

        my @results;
        while (my $entry = $collection->next) {
            push @results, $entry->to_string;
        }

        return @results;
    }
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

