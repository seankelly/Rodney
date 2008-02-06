#!/usr/bin/env perl
package Rodney::Command::Grep;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;

    my $games = $self->games($args);

    $self->Grep($args, $games);
}

sub regex {
    my $message = shift;
    my @regex;
    my @sort;
    while ($message =~ s!({(?:\s*(min|max):\s*)?\s*(\w+)(?:\s*/([^/]*)/\s*([ri]*))?\s*})!!) {
        #if (defined($2) && @sort == 0) {
        if (defined($2)) {
            push @sort, [lc ($3), $2];
            #$sort_field = lc($3);
            #$sort_order = $2;
        }
        next if !defined($4);
        my $type = lc($3);
        my $regex = $4;
        push @regex, [$type, $regex, $5, $1];
    }
    if ($message =~ s#((!)?/([^/]*)/([ir]*))##) {
        push @regex, ['death', $3, $4, $2, $1];
    }

    if (@regex == 0 && @sort == 0 && length($message) > 0) {
        my $first = substr $message, 0, 1;
        if ($first eq '!') {
            # doesn't matter if sort is included
            # just need regex pointing to an empty array
            return (regex => []) if length $message == 1;
            $message = substr $message, 1;
        }
        else {
            $first = undef;
        }
        @regex = ['death', $message, "", $first, "/$message/"];
        $message = '';
    }

    return (sort => \@sort, regex => \@regex);
}

sub Grep {
    #use Data::Dumper;
    my $self  = shift;
    my $args  = shift;
    my $games = shift;

    # first check that something was given...
    return "Syntax is: !grep PERSON /DEATH/" unless $args->{text};

    my $sort;

    my %fields = map { $_ => 1 }
        qw/version score dungeon curlvl maxlvl curhp maxhp deaths enddate
        startdate role race gender alignment nick death ascended uid/;

    my $nick = $self->target($args);
    my %regex = regex($args->{text});
    return "Syntax is: !grep PERSON /DEATH/" unless @{$regex{regex}} > 0;
    #print Dumper(\%regex);

    # next check that the fields are valid
    for (@{$regex{regex}},@{$regex{sort}}) {
        next if $fields{$_->[0]};
        return 'Invalid field: ' . $_->[0];
    }

    $games->limit(
        column => 'player',
        value  => $nick,
    ) unless $NAO;
    $games->order_by(
        column => 'id',
        order  => 'asc',
    );

    # now do the limiting based on the regex
    for (@{$regex{regex}}) {
        $games->limit(
            column   => $_->[0],
            value    => $_->[1],
            # this is ugly, I know!
            operator => ($_->[3] ? '!' : '')
                        . ($_->[2] =~ /i/ ? '~*' : '~'),
        );
    }
    # and then sorting..
    if (@{$regex{sort}} > 0) {
        # make sure it continues to sort by id
        my @sort = ( {
                column => 'id',
                order  => 'asc',
            });
        $sort = 1;
        for (@{$regex{sort}}) {
            push @sort, {
                column => $_->[0],
                order  => ($_->[1] eq 'min') ? 'asc' : 'desc',
            };
        }
        $games->order_by(@sort);
    }

    my $result;
    my @results;
    my $count = $games->count;

    # in case several thousand or more rows will be returned, limit to
    # just the first 25
    $games->set_page_info(
        per_page => 25
    ) if $count > 25;

    while (my $g = $games->next) {
        push @results, $g->id;
    }

    if ($count == 1 || ($sort && $count > 0)) {
        $result = $games->first->to_string(100);
    }
    elsif ($count == 0) {
        $result = 'No games found.';
    }
    elsif ($count > 1) {
        $result = sprintf '%d games found: #%s',
                    $count,
                    join ', #', @results;
        $result .= ', ...' if $count > 25;
    }

    return $result;
}

1;

