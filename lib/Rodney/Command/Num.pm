#!/usr/bin/env perl
package Rodney::Command::Num;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;
    my $result;

    my $nick  = $self->target($args);
    my $num   = $1 if $args->{body} =~ s/\s*#(\d+)\s*//;
    my $games = $self->games($args);

    if ($self->target_is_server($args)) {
        if ($num) {
            $games->limit(
                column => 'id',
                value  => $num
            );
        }
        else {
            $games->unlimit();
        }
    }
    else {
        $games->set_page_info(
            current_page => $num,
            per_page     => 1,
        ) if $num;
    }
    # ROFL HAHA
    # yeah, sort it by id
    # but only if currently unsorted
    $games->add_order_by(
        column => 'id',
        order  => 'asc',
    ) unless $games->_order_clause;

    my $count = $games->count;

    if ($num) {
        if ($games->first) {
            if ($self->target_is_server($args)) {
                $result = $games->first->to_string(100);
            }
            else {
                $result = $games->first->to_string(100, offset => $num, count => $count);
            }
        }
        else {
            $result = 'Game not found.';
        }
    }
    elsif ($count > 0) {
        $result = $games->last->to_string(100, offset => $count, count => $count);
    }
    else {
        $result = 'No games found.';
    }
    return $result;
}

1;

