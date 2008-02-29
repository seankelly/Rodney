#!/usr/bin/env perl
package Rodney::Command::Hsn;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    my $self = shift;
    my $args = shift;

    my $speaker = $args->{who};
    return "Lists highest-scoring games. If the game is on the high-score table, its position is also given. You can use '!hsn $speaker +3' to get a player's fourth highest score. '!hsn #X' lists the Xth highest score over all of NAO.";
}

sub run {
    my $self = shift;
    my $args = shift;

    my $message = $args->{message};
    $args->{args} = $args->{message};

    # don't use ->target unless +N is used..

    my $offset = 0;
    my $server = 0;

    if ($message =~ s/\+(\d+)//) {
        $offset = $1 + 1;
    }
    elsif ($message =~ /#(\d+)/) {
        $offset = $1;
        $server = 1;
    }

    my $games = $self->games($args, default => ($server ? 'server' : 'nick'));
    my $target = $self->target($args, default => ($server ? 'server' : 'nick'));

    use DDS;
    warn $target;
    warn $offset;

    $games->add_order_by(
        column => 'score',
        order  => 'desc',
    );

    $games->set_page_info(
        current_page => $offset,
        per_page     => 1,
    );

    my $count = $games->count;

    if ($games->first) {
        return $games->first->to_string(100, $offset, $count);
    }
    else {
        return "$target only has $count games";
    }
}

1;

