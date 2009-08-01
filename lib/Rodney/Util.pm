package Rodney::Util;
use strict;
use warnings;
use List::MoreUtils 'any';

use Sub::Exporter -setup => {
    exports => [
        qw/plural ntimes once stats fstats plane races roles genders/,
        qw/alignments parse_arguments/,
    ]
};

=head2 plural count, singular[, plural]

Returns a string of the form "N foos". The plural is optional, if it's absent
an "s" will be appended to the singular.

=cut

sub plural {
    my $count = shift;
    my $singular = shift;
    my $plural = shift || "${singular}s";

    return $count == 1 ? "1 $singular" : "$count $plural";
}

=head2 ntimes count

Returns a string of the form "once", "twice", "thrice", or "N times".

=cut

sub ntimes {
    my $count = shift;

    return "once"   if $count == 1;
    return "twice"  if $count == 2;
    return "thrice" if $count == 3;
    return "$count times";
}

=head2 once count

Returns a string of the form "once", "twice", "thrice", or "N".

=cut

sub once {
    my $count = shift;

    return "once"   if $count == 1;
    return "twice"  if $count == 2;
    return "thrice" if $count == 3;
    return $count;
}

=head2 stats hash

Returns a string of the form "9xFoo 4xBar 4xBaz"

=cut

sub stats {
    my %stats = @_;

    my @parts = map  { "$stats{$_}x$_" }
                sort { $stats{$b} <=> $stats{$a} || $a cmp $b }
                keys %stats;

    return join ' ', @parts;
}

=head2 fstats hash

Returns a string of the form "Foo(float) Bar(float) Baz(float)"

=cut

sub fstats {
    my %stats = @_;

    my @parts = map { sprintf("%s(%.4f)", $_, $stats{$_})}
                sort { $stats{$b} <=> $stats{$a} || $a cmp $b }
                keys %stats;

    return join ' ', @parts;

}

=head2 plane

Returns which plane corresponds to the given level.

=cut

sub plane {
    my $level = shift;
    my $verbosity = shift || 2;
    my @planes = qw/Astral Water Fire Air Earth/;
    my $name = $planes[$level];
    $name .= ' Plane' if $verbosity == 2;
    return $name;
}

=head2 roles

Returns the list of roles

=cut

sub roles {
    return qw/Arc Bar Cav Hea Kni Mon Pri Ran Rog Sam Tou Val Wiz/;
}

=head2 races

Returns the list of races

=cut

sub races {
    return qw/Hum Dwa Elf Gno Orc/;
}

=head2 genders

Returns the list of genders

=cut

sub genders {
    return qw/Mal Fem/;
}

=head2 races

Returns the list of alignments

=cut

sub alignments {
    return qw/Law Neu Cha/;
}

sub _find_quoted {
    my ($self, $string, $start) = (@_);

    my %end = (
        '<' => '>',
        '{' => '}',
        '(' => ')',
        '[' => ']',
    );

    my $end = $end{$start} || $start;

    $string =~ s/^$start(.*?)(?<!\\)$end//g;

    my $quoted = $1;

    return unless defined $quoted;

    # Replace escaped end characters with the end char.
    $quoted =~ s/\\$end/$end/g;

    return ($string, $quoted);
}

sub parse_arguments {
    my $args = shift;

    my @arguments;

    while ($args =~ s#^\s*(?:/([^/]+(?<!\\))/(\w+)?|(\w+)([!<>=/:]+)?)##) {
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
            my $first = substr($args, 0, 1);
            my @quotes = ("'", '"', '/', '{', '[', '(', '<');

            if (any { $first eq $_ } @quotes) {
                ($args, $value) = Rodney::Util->_find_quoted($args, $first);
            }
            else {
                $args =~ s/^(\S+)//;
                $value = $1;
            }
            $arg{value} = $value;
        }

        push @arguments, \%arg;
    }

    return \@arguments;
}

1;
