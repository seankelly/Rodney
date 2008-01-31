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
    my $NAO   = $args->{body} =~ s/\*//;
    my $games = $self->games($args);

    if ($NAO)
    {
        $nick = 'nethack.alt.org';
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
        # limit to just $nick
        $games->limit(
            column => 'player',
            value  => $nick
        );
        $games->set_page_info(
            current_page => $num,
            per_page     => 1,
        ) if $num;
    }

    if ($num)
    {
        $result = 'Found the game! (demunge here)';
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
        $result = 'No game found.';
    }
    return $result;
}

1;

