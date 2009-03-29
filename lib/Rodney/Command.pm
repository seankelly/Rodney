package Rodney::Command;
use Moose;

=head2 get_input Args

=cut

sub get_input {
    my $self = shift;
    my $args = shift;

    my $stdin = $args->{stdin};
    return unless defined $stdin;

    if (ref $stdin eq 'ARRAY') {
        return @$stdin if wantarray;
    }
    else {
        die "get_input called with invalid stdin.";
    }
    return $stdin;
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


=head2 help

Override this for command specific help.

=cut

sub help {
    return 'I need help text written for me!';
}

1;

