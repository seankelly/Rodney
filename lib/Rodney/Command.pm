#!/usr/bin/env perl
package Rodney::Command;
use strict;
use warnings;
use Rodney::Game;

=head2 canonicalize_name name

=cut

sub canonicalize_name {
    my $self = shift;
    my $name = shift;

    $name =~ tr[a-zA-Z0-9][]cd;
    return substr($name, 0, 10) unless @_;
    return $name;
}

=head2 target Args

Figures out the most likely target for the command, given the command arg-hash.

=cut

sub target {
    my $self = shift;
    my $args = shift;

    return "nethack.alt.org" if $self->target_is_server($args);

    # this can't be just "\b\w+\b" because "-Mal" is not a nick
    return $self->canonicalize_name($1, @_)
        if $args->{args} =~ /(?:^| )(\w+)(?: |$)/;
    return $self->canonicalize_name($args->{who}, @_);
}

=head2 target_is_server Args

Figures out whether the target is "the entire server." If so, target will return
a special value.

=cut

sub target_is_server {
    my $self = shift;
    my $args = shift;

    return 0 if $args->{server_denied};

    return $args->{args} =~ /\s*\*\s*/;
}

=head2 games Args

Gets a GameCollection based on Args. You should use this instead of Rodney::GameCollection->new because of meta-commands (like !r).

=cut

sub games {
    my $self = shift;
    my $args = shift;

    my $nick = $self->target($args);
    my $NAO = $self->target_is_server($args);

    my $games = Rodney::GameCollection->new(handle => $args->{handle});

    if ($NAO) {
        $games->unlimit;
    }
    else {
        $games->limit(
            column => 'player',
            value => $nick,
        );
    }

    for (@{ $args->{games_callback} || [] }) {
        $args->{games_modified}++;
        $_->($self, $games, $args);
    }

    return $games;
}

=head 2 help

Override this for command specific help.

=cut

sub help {
    return 'No help for this command.';
}

1;

