#!/usr/bin/env perl
package Rodney::Command::Date;
use strict;
use warnings;
use parent 'Rodney::Command';
use DateTime;
use DateTime::Format::Strptime;

sub run {
    my $self = shift;
    my $args = shift;

    $self->date();
}

sub date {
    my $formatter = DateTime::Format::Strptime->new(
        pattern => "%a %b %d %T %Z %Y");
    my $dt = DateTime->now(formatter => $formatter);

    return "$dt";
}

1;
