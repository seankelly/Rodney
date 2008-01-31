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
    return substr($name, 0, 10);
}

=head2 target Args

Figures out the most likely target for the command, given the command arg-hash.

=cut

sub target {
    my $self = shift;
    my $args = shift;

    # this can't be just "\b\w+\b" because "-Mal" is not a nick
    return $self->canonicalize_name($1)
        if $args->{body} =~ /(?:^| )(\w+)(?: |$)/;
    return $self->canonicalize_name($args->{who});
}

=head2 games Args

Gets a GameCollection based on Args. You should use this instead of Rodney::GameCollection->new because of meta-commands (like !r).

=cut

sub games {
    my $self = shift;
    my $args = shift;

    my $games = Rodney::GameCollection->new(handle => $args->{handle});

    for (@{ $args->{games_callback} || [] }) {
        $args->{games_modified}++;
        $_->($self, $games);
    }

    return $games;
}

1;

