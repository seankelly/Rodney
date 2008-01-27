#!/usr/bin/env perl
package Rodney::Command;
use strict;
use warnings;

=head2 target Args

Figures out the most likely target for the command, given the command arg-hash.

=cut

sub target {
    my $self = shift;
    my $args = shift;

    # this can't be just "\b\w+\b" because "-Mal" is not a nick
    return $1 if $args->{message} =~ /(?:^| )(\w+)(?: |$)/;
    return $args->{who};
}

=head2 games Args

Gets a GameCollection based on Args. You should use this instead of Rodney::GameCollection->new because of meta-commands (like !r).

=cut

sub games {
    my $self = shift;
    my $args = shift;

    return bless [], 'Rodney::GameCollection';
}

=head2 plural count, singular[, plural]

Returns a string of the form "N foos". The plural is optional, if it's absent
an "s" will be appended to the singular.

=cut

sub plural {
    my $self = shift;
    my $count = shift;
    my $singular = shift;
    my $plural = shift || "${singular}s";

    return $count == 1 ? $singular : $plural;
}

1;

