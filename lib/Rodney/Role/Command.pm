package Rodney::Role::Command;
use Moose::Role;
use List::MoreUtils 'any';
use Rodney::Util 'find_quoted';

# command method returns a list of commands.
# run is what's used to run the command.
requires qw/command run/;

# This originally was in Rodney::Util but honestly, it's only going
# to be used by commands. Makes sense to move it to the right place.
sub parse_arguments {
    my $self = shift;
    my $string = shift;

    my @arguments;

    while ($string =~ s#^\s*(?:/([^/]+(?<!\\))/(\w+)?|(\w+)([!<>=/:]+)?)##) {
        # $1 = regex
        # $2 = regex option (optional)
        # $3 = column
        # $4 = operator (optional)

        my %arg;
        if (defined $4) {
            %arg = (
                column   => $3,
                operator => $4,
            );
        }
        else {
            %arg = (
                column    => undef,
                operator  => undef,
                value     => $1 || $3,
            );

            if (defined $1) {
                %arg = (
                    %arg,
                    re_option => $2,
                    operator  => '~',
                );
            }

        }

        # Only search for argument if an operator was provided.
        if (defined $4) {
            # For simplicity, allow pretty much any open "quote"
            # character to start the string.

            my $value;
            my $first = substr($string, 0, 1);
            my @quotes = ("'", '"', '/', '{', '[', '(', '<');

            if (any { $first eq $_ } @quotes) {
                ($string, $value) = find_quoted($string, $first);
            }
            else {
                $string =~ s/^(\S+)//;
                $value = $1;
            }
            $arg{value} = $value;
        }

        push @arguments, \%arg;
    }

    return \@arguments;
}

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


no Moose::Role;

1;
