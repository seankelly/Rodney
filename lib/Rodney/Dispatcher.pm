#!/usr/bin/env perl
package Rodney::Dispatcher;
use strict;
use warnings;
use Rodney::Command::Gamesby;
use Rodney::Command::Rot13;
use Rodney::Command::Ascensions;

sub on;

on qr{^!gamesby\b}i => sub {
    Rodney::Command::Gamesby->run(@_)
};

on qr{^!asc(?:ensions?)?\b}i => sub {
    Rodney::Command::Ascensions->run(@_)
};

on qr{^!rot13\s+(.*)}i => sub {
    Rodney::Command::Rot13->run(@_, text => $1)
};

my @rules;
sub on {
    my ($re, $code) = @_;
    push @rules, [$re, $code];
}

sub dispatch {
    my $self = shift;
    my $args = shift;
    local $_ = $args->{body};

    for my $rule (@rules) {
        my ($re, $code) = @$rule;
        if ($_ =~ $re) {
            return $code->($args);
            last;
        }
    }

    return;
}

1;

