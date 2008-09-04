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

    return if $args->{channel} eq 'msg';

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

    return if $args->{channel} eq 'msg';

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

    my ($term, $entry) = normalize($args->{arguments}->[1]);

    my @results = Rodney::Learndb->query(
        handle => $args->{handle},
        term   => $term,
        entry  => $entry,
    );

    return "${term}[$entry] not found in the dictionary." if @results == 0;

    \@results;
}

sub search {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;
}

sub swap {
    my $self = shift;
    my $args = shift;
    my $learndb = shift;

    return if $args->{channel} eq 'msg';

    my ($termA, $entryA) = normalize($args->{arguments}->[1]);
    my ($termB, $entryB) = normalize($args->{arguments}->[2]);

    return if ($termA eq $termB) && ($entryA eq $entryB);

    setup($learndb, $termA);
    return "'$termA' not found in my dictionary." if $learndb->count == 0;

    setup($learndb, $termB);
    return "'$termB' not found in my dictionary." if $learndb->count == 0;

    if (!defined($entryA) && !defined($entryB)) {
    }
}

sub run {
    my $self = shift;
    my $args = shift;

    if ($args->{body} =~ /^\?(\W+)\s*(.+)/) {
        $args->{args} = "$1 $2";
    }

    return unless $args->{args};
    my @args = split ' ', $args->{args};
    $args->{arguments} = \@args;

    my %alias = (
        '?' => 'query',
        '>' => 'query',
        '<' => 'query',
        '!' => 'info',
        '*' => 'search',
    );

    my $cmd = $alias{$args[0]} || $args[0];

    return unless $self->can($cmd);

    my $learndb = Rodney::LearndbCollection->new(handle => $args->{handle});

    my $res = $self->can($cmd)->($self, $args, $learndb);

    my %method = (
        query => 'msg',
        '?'   => 'msg',
    );

    my $msg = {
        channel => $method{$args[0]} || $args->{channel},
        who     => $args->{who},
        body    => $res,
    };

    return $msg;
}

1;

