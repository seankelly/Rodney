#!/usr/bin/env perl
package Rodney::Command;
use strict;
use warnings;
use Rodney::Game;

=head2 dispatch Arg-hash

Executes commands, if present, in the arg-hash. The arg-hash
should be in the format
    
    body    => String from message.
    who     => Nickname for the string.
    channel => Channel in which the string was sent. Use '?' for private messages.

This can be passed as a hash ref or as a hash itself.

=cut

sub dispatch {
    my $self = shift;
    my $arghash;
    if (ref $_[0] eq 'HASH') {
        $arghash = shift;
    }
    elsif (ref $_[0] eq '') {
        my %hash = (@_);
        $arghash = \%hash;
    }

    # XXX: Should it be Rodney->config->foo?
    # FIXME: make the following work
    my $prefix = Rodney->config->prefix;
    my $pipe_cmd = $prefix . $prefix;

    # check if there is a command
    return unless $arghash->{body} ~= /^$prefix/;

    my @commands = split $pipe_cmd, $arghash->{body};
    for my $command (@commands) {
    }
}

=head2 canonicalize_name name

=cut

sub canonicalize_name {
    my $self = shift;
    my $name = shift;
    my %opts = (
        full => 0,
    );

    $name =~ tr[a-zA-Z0-9][]cd;
    return substr($name, 0, 10) unless $opts{full};
    return $name;
}

=head2 target Args

Figures out the most likely target for the command, given the command arg-hash.

=cut

sub target {
    my $self = shift;
    my $args = shift;
    my %opts = (
        default => 'nick',
        @_
    );

    return "nethack.alt.org" if $self->target_is_server($args);

    # this can't be just "\b\w+\b" because "-Mal" is not a nick
    return $self->canonicalize_name($1, %opts)
        if $args->{args} =~ /(?:^| )(\w+)(?: |$)/;
    return 'nethack.alt.org'
        if $opts{default} eq 'server' && !$args->{server_denied};
    return $self->canonicalize_name($args->{who}, %opts);
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
    my %opts = (
        @_
    );

    my $nick = $self->target($args, %opts);
    # XXX: fix so target caches the target and stuff..
    my $NAO = $nick eq 'nethack.alt.org';

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
        my ($code, $_args) = @{ $_ };
        $code->($self, $games, $_args);
    }

    return $games;
}

=head2 help

Override this for command specific help.

=cut

sub help {
    return 'I need help text written for me!';
}

1;

