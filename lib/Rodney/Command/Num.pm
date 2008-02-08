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

    if ($self->target_is_server($args))
    {
        if ($num)
        {
            $games->limit(
                column => 'id',
                value  => $num
            );
        }
        else
        {
            $games->unlimit();
        }
    }
    else
    {
        $games->set_page_info(
            current_page => $num,
            per_page     => 1,
        ) if $num;
    }
    # ROFL HAHA
    # yeah, sort it by id
    $games->order_by(
        column => 'id',
        order  => 'asc',
    );

    if ($num)
    {
        if ($games->first)
        {
            $result = $games->first->to_string(100);
        }
        else
        {
            $result = 'Game not found.';
        }
    }
    elsif ($games->count > 1)
    {
        $result = sprintf 'Found %d games for %s.',
                          $games->count,
                          $nick
                          ;
    }
    else
    {
        $result = 'No games found.';
    }
    return $result;
}

1;

