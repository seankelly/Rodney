package Rodney::Command::Rot13;
use strict;
use warnings;
use parent 'Rodney::Command';

sub run {
    my $self = shift;
    my $args = shift;

    $args->{args} =~ tr[a-zA-Z][n-za-mN-ZA-M];
    return "rot13: $args->{args}";
}

1;

