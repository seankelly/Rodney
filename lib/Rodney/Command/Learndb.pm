#!/usr/bin/env perl
package Rodney::Command::Learndb;
use strict;
use warnings;
use parent 'Rodney::Command';

use Rodney::Learndb;

use DDS;

sub help {
    return 'Help text for STUB';
}

# helper methods
sub entries {
    # this is to prevent it being called from run because
    # the arguments aren't passed correctly
    # otherwise I wouldn't care
    return if (caller(1))[3] =~ /::run$/;
    my $learndb = shift;
    my $term = shift;

    $learndb->unlimit;
    $learndb->limit(
        column => 'term',
        value  => $term,
    );

    return $learndb->count + 1;
}

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

    $learndb->unlimit;

    $learndb->limit(
        column => 'term',
        value  => $term,
    );
    $learndb->limit(
        column => 'entry',
        value  => $entry,
    ) if defined $entry;
}

# commands
sub add {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
    my @arguments = @_;

    my $term = $arguments[1];
    my $definition = join(' ', @arguments[2..$#arguments]);

    my $entries = entries($learndb, $term);

    my $id = Rodney::Learndb->add(
        handle     => $args->{handle},
        term       => $term,
        entry      => $entries,
        author     => $args->{who},
        definition => $definition,
    );

    my $entry = Rodney::Learndb->load_by_cols(id => $id, _handle => $args->{handle});

    return $entry->to_string if $entry;

    return 'Entry not created';
}

sub del {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
    my @arguments = @_;

    my ($term, $entry) = normalize($arguments[1]);

    $learndb->unlimit;

    if (defined $entry) {
        $learndb->limit(
            column => 'term',
            value  => $term,
        );
        $learndb->limit(
            column => 'entry',
            value  => $entry,
        );

        return 'Entry not found.' if $learndb->count == 0;
        return 'Too many entries matched.' if $learndb->count > 1;

        my $text = $learndb->first->to_string;
        $learndb->first->delete;

        $learndb->unlimit;
        $learndb->limit(
            column => 'term',
            value  => $term,
        );
        $learndb->limit(
            column   => 'entry',
            value    => $entry,
            operator => '>',
        );

        while (my $next = $learndb->next) {
            $next->set_entry($next->entry - 1);
        }

        return $text;
    }
    else {
        # delete entire term
        $learndb->limit(
            column => 'term',
            value  => $term,
        );

        my $deleted = 0;

        while (my $entry = $learndb->next) {
            $deleted++ if $entry->delete;
        }

        return 'Deleted ' . $deleted . ' entries.';
    }
}

sub edit {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
    my @arguments = @_;
}

sub info {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
    my @arguments = @_;

    my ($term, $entry) = normalize($arguments[1]);

    if (defined $entry) {
    }
    else {
    }
}

sub swap {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
    my @arguments = @_;

    my ($termA, $entryA) = normalize($arguments[1]);
    my ($termB, $entryB) = normalize($arguments[2]);
}

sub run {
    my $self = shift;
    my $args = shift;

    return unless $args->{args};
    my @args = split ' ', $args->{args};

    return unless $self->can($args[0]);

    my $learndb = Rodney::LearndbCollection->new(handle => $args->{handle});

    $self->can($args[0])->($self, $args, $learndb, @args);
}

1;

