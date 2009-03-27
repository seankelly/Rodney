package Rodney::Command::Learndb;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Help text for STUB';
}

# helper methods
sub normalize {
    return if (caller(1))[3] =~ /::run$/;

    my $arg = shift;
    # term = $1, entry = $2
    $arg =~ /^(.*?)(?:\[(\d+)\])?$/;
    return ($1, $2);
}

sub setup {
    return if (caller(1))[3] =~ /::run$/;

    my $learndb = shift;
    my $term = shift;
    my $entry = shift;
    my $operator = shift;

    $learndb->unlimit;

    $learndb->limit(
        column => 'term',
        value  => $term,
    );

    my %entry = (
        column => 'entry',
        value  => $entry,
    );

    $entry{operator} = $operator if defined $operator;

    $learndb->limit(%entry) if defined $entry;
}

# commands
sub add {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    return if $args->{channel} eq 'msg';

    my @arguments = @{ $args->{arguments} };
    my $term = shift @arguments;
    my $definition = join(' ', @arguments);

    my $id = Rodney::Learndb->add(
        handle     => $args->{handle},
        term       => $term,
        author     => $args->{who},
        definition => $definition,
    );

    my $entry = Rodney::Learndb->load_by_cols(id => $id, _handle => $args->{handle});

    return sprintf 'Term %s[%d] successfully added.',
           $entry->normal_term,
           $entry->entry
           if $id;

    return 'Entry not created';
}

sub del {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    return if $args->{channel} eq 'msg';

    my ($term, $entry) = normalize($args->{arguments}->[0]);

    Rodney::Learndb->del(
        handle => $args->{handle},
        term   => $term,
        entry  => $entry,
        who    => $args->{who},
    );
}

sub edit {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
}

sub info {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    my ($term, $entry) = normalize($args->{arguments}->[0]);

    return Rodney::Learndb->info(
        handle => $args->{handle},
        term   => $term,
        entry  => $entry,
    );
}

sub query {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    my @args = @{ $args->{arguments} };

    my ($term, $entry) = normalize(join(' ', @args));

    my @results = Rodney::Learndb->query(
        handle => $args->{handle},
        term   => $term,
        entry  => $entry,
    );

    return sprintf '%s%s not found in the dictionary.',
        $term,
        defined $entry ? "[$entry]" : '',
        if @results == 0;

    \@results;
}

sub replace {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    return if $args->{channel} eq 'msg';

    my ($term, $entry) = normalize($args->{arguments}->[0]);
    my @args = @{ $args->{arguments} };
    shift @args;
    my $newdef = join ' ', @args;

    my $res = Rodney::Learndb->replace(
        handle     => $args->{handle},
        who        => $args->{who},
        term       => $term,
        entry      => $entry,
        definition => $newdef,
    );

    return $res if defined $res;

    $args->{arguments} = [ $args->{arguments}->[0] ];
    return $self->query($args, $learndb);
}

sub search {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    my $string = join ' ', @{ $args->{arguments} };
    my $query = $string;

    $query =~ s/%//;
    $query =~ tr/ /%/;
    $query =~ tr/_/ /;

    $learndb->unlimit;
    # first search titles..
    $learndb->limit(
        column   => 'term',
        value    => $query,
        operator => 'MATCHES',
    );
    $learndb->column(
        column   => 'term',
        function => 'DISTINCT',
    );

    my $count = $learndb->count;

    return sprintf '%d results for "%s". Please narrow your search.',
                   $count, $string
        if $count > 25;

    if ($count > 0) {
        my @terms;

        while (my $term = $learndb->next) {
            push @terms, $term->normal_term;
        }

        return sprintf '%d results for "%s": %s',
                       $count, $string,
                       join(', ', @terms);
    }

    $learndb->unlimit;
    # second search definitions
    $learndb->limit(
        column   => 'definition',
        value    => $query,
        operator => 'MATCHES',
    );

    $count = $learndb->count;
    if ($count == 0) {
        return 'fail';
    }
    elsif ($count <= 25) {
        my @terms;

        while (my $term = $learndb->next) {
            push @terms, $term->normal_term;
        }

        return sprintf '%d results for "%s": %s',
                       $count, $string,
                       join(', ', @terms);
    }
    else {
        return 'too many!';
    }
}

sub swap {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    return if $args->{channel} eq 'msg';

    my ($termA, $entryA) = normalize($args->{arguments}->[0]);
    my ($termB, $entryB) = normalize($args->{arguments}->[1]);

    return if ($termA eq $termB) && ($entryA eq $entryB);

    setup($learndb, $termA);
    return "'$termA' not found in my dictionary." if $learndb->count == 0;

    setup($learndb, $termB);
    return "'$termB' not found in my dictionary." if $learndb->count == 0;

    if (!defined($entryA) && !defined($entryB)) {
    }
}

sub undel {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    return if $args->{channel} eq 'msg';

    my ($term, $entry) = normalize($args->{arguments}->[0]);

    my $undeleted = Rodney::Learndb->undelete(
        handle => $args->{handle},
        term   => $term,
        entry  => $entry,
    );

    return 'No entries to undelete.' if $undeleted == 0;
    return "Restored $undeleted entries.";
}

sub run {
    my $self = shift;
    my $args = shift;

    if ($args->{body} =~ /^\?(\W+)\s*(.+)/) {
        $args->{args} = "$1 $2";
    }

    return unless $args->{args};
    my @args = split ' ', $args->{args};

    my %alias = (
        '?' => 'query',
        '>' => 'query',
        '<' => 'query',
        '!' => 'info',
        '*' => 'search',
    );
    my $cmd = $alias{$args[0]} || $args[0];

    my %method = (
        query => 'msg',
        '?'   => 'msg',
    );
    my $chan = $method{$args[0]} || $args->{channel},

    shift @args;
    $args->{arguments} = \@args;


    return unless $self->can($cmd);

    my $learndb = Rodney::LearndbCollection->new(handle => $args->{handle});

    my $res = $self->can($cmd)->($self, $args, $learndb);

    return 'That entry is too long.'
        if ref($res) eq 'ARRAY'
        && scalar @{ $res } > 2
        && $chan ne 'msg';

    my $msg = {
        channel => $chan,
        who     => $args->{who},
        body    => $res,
    };

    return $msg;
}

1;

