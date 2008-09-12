package Rodney::Learndb;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column deleted =>
        type is 'boolean',
        default is 'f',
        is mandatory;

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

    $collection->limit(
        column => 'deleted',
        value  => 'f',
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

    # normalize term to strip trailing spaces and convert _ to spaces
    $args{term} =~ s/ +$//;
    $args{term} =~ tr/_/ /;

    $args{entry} = _entries($args{handle}, $args{term}) + 1;

    $entry->create(
        term       => $args{term},
        entry      => $args{entry},
        author     => $args{author},
        updated    => $args{updated},
        definition => $args{definition},
    );
}

sub _delete {
    my $self = shift;
    $self->set_deleted('t');
}

sub del {
    my $self = shift;
    my %args = (@_);

    return unless defined $args{term} && defined $args{handle};

    my $collection = Rodney::LearndbCollection->new(handle => $args{handle});

    $args{term} =~ tr/_/ /;

    _setup($collection, $args{term}, $args{entry});

    if (defined $args{entry}) {
        return 'Entry not found.' if $collection->count == 0;
        return 'Too many entries matched.' if $collection->count > 1;

        my $text = $collection->first->to_string;
        $collection->first->set_updated(time);
        $collection->first->_delete;

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
            $deleted++;
            $entry->set_updated(time);
            $entry->_delete;
        }

        return 'Deleted ' . $deleted . ' entries.';
   }
}

sub info {
    my $self = shift;
    my %args = (@_);

    my $collection = Rodney::LearndbCollection->new(handle => $args{handle});

    $args{term} =~ tr/_/ /;

    _setup($collection, $args{term}, $args{entry});

    if (defined $args{entry}) {
        return 'Entry not found.' if $collection->count == 0;

        my $dbentry = $collection->first;

        my $date = scalar gmtime($dbentry->updated);
        $date =~ s/  / /;
        return sprintf '%s[%d] was created by %s and last updated %s.',
               $dbentry->term,
               $dbentry->entry,
               $dbentry->author,
               $date;
    }
    else {
        return 'Term not found.' if $collection->count == 0;

        my @info;
        while (my $dbentry = $collection->next) {
            push @info, $dbentry->author;
        }

        return sprintf '%s has contributions by: %s.',
               $args{term},
               join(', ', @info);
    }

}

sub query {
    my $self = shift;
    my %args = (@_);

    my $collection = Rodney::LearndbCollection->new(handle => $args{handle});

    $args{term} =~ tr/_/ /;

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

sub undelete {
    my $self = shift;
    my %args = (@_);

    my $collection = Rodney::LearndbCollection->new(handle => $args{handle});

    $args{term} =~ tr/_/ /;

    my $entries = _entries($args{handle}, $args{term});

    # override default
    $collection->unlimit;

    $collection->limit(
        column => 'term',
        value  => $args{term},
    );

    $collection->limit(
        column => 'deleted',
        value  => 't',
    );

    $collection->limit(
        column => 'entry',
        value  => $args{entry},
    ) if defined $args{entry};

    $collection->order_by(
        column => 'entry',
        value  => 'asc',
    );

    my $undeleted = 0;
    while (my $entry = $collection->next) {
        $undeleted++;
        $entry->set_deleted('f');
        $entry->set_entry(++$entries);
        $entry->set_updated(time);
    }

    return $undeleted;
}

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

sub TABLE_NAME { 'learndb' }

package Rodney::LearndbCollection;
use parent 'Jifty::DBI::Collection';


# then add the Undo part
package Rodney::Learndb::Undo;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column entryid =>
        type is 'integer',
        references Rodney::Learndb by 'id',
        is mandatory;

    column term =>
        type is 'varchar',
        is mandatory;

    column entry =>
        type is 'integer',
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

sub add {
    my $self = shift;
    my %args = (@_);
}

sub undo {
    my $self = shift;
    my %args = (@_);
}

sub TABLE_NAME { 'learndb_undo' }

package Rodney::Learndb::UndoCollection;
use parent 'Jifty::DBI::Collection';

1;

