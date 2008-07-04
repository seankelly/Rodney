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

    setup($learndb, $term);

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

    my @arguments = @{ $args->{arguments} };
    my $term = $arguments[1];
    my $definition = join(' ', @arguments[2..$#arguments]);

    my $id = Rodney::Learndb->add(
        handle     => $args->{handle},
        term       => $term,
        author     => $args->{who},
        definition => $definition,
    );

    my $entry = Rodney::Learndb->load_by_cols(id => $id, _handle => $args->{handle});

    return sprintf 'Term %s[%d] successfully added.',
           $entry->term,
           $entry->entry
           if $id;

    return 'Entry not created';
}

sub del {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    my ($term, $entry) = normalize($args->{arguments}->[1]);

    Rodney::Learndb->del(
        handle => $args->{handle},
        term   => $term,
        entry  => $entry,
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

    my ($term, $entry) = normalize($args->{arguments}->[1]);

    setup($learndb, $term, $entry);

    if (defined $entry) {
        return 'Entry not found.' if $learndb->count == 0;

        my $dbentry = $learndb->first;

        return sprintf '%s[%d] was created by %s and last updated %s.',
               $term,
               $entry,
               $dbentry->author,
               scalar gmtime($dbentry->updated);
    }
    else {
        return 'Term not found.' if $learndb->count == 0;

        my @info;
        while (my $dbentry = $learndb->next) {
            push @info, $dbentry->author;
        }

        return sprintf '%s has contributions by: %s.',
               $term,
               join(', ', @info);
    }
}

sub swap {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    my ($termA, $entryA) = normalize($arguments[1]);
    my ($termB, $entryB) = normalize($arguments[2]);
}

sub run {
    my $self = shift;
    my $args = shift;

    return unless $args->{args};
    my @args = split ' ', $args->{args};
    $args->{arguments} = \@args;

    return unless $self->can($args[0]);

    my $learndb = Rodney::LearndbCollection->new(handle => $args->{handle});

    $self->can($args[0])->($self, $args, $learndb, $bot);
}

1;

