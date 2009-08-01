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

no Moose::Role;

1;
