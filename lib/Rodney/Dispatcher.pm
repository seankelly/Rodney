#!/usr/bin/env perl
package Rodney::Dispatcher;
use strict;
use warnings;
use Rodney::Command::Recent;
use Rodney::Command::Noscum;
use Rodney::Command::Asconly;
use Rodney::Command::Gamesby;
use Rodney::Command::Rot13;
use Rodney::Command::Ascensions;
use Rodney::Command::Num;
use Rodney::Command::Grep;

sub on;

on qr{^!g(?:ames(?:by)?)?\b}i => sub {
    Rodney::Command::Gamesby->run(@_)
};

on qr{^!asc(?:ensions?)?\b}i => sub {
    Rodney::Command::Ascensions->run(@_)
};

on qr{^!num\b}i => sub {
    Rodney::Command::Num->run(@_)
};

on qr{^!grep\s*(.*)?}i => sub {
    Rodney::Command::Grep->run(@_, text => $1)
};

on qr{^!rot13\s+(.*)}i => sub {
    Rodney::Command::Rot13->run(@_, text => $1)
};

# meta commands

on qr{^!r\s+(.*)}i => sub {
    Rodney::Command::Recent->run(@_, $1)
};

on qr{^!r(\w+)\b\s*(.*)}i => sub {
    Rodney::Command::Recent->run(@_, "!$1 $2")
};

on qr{^!noscum\s+(.*)}i => sub {
    Rodney::Command::Noscum->run(@_, $1)
};

on qr{^!noscum(\w+)\b\s*(.*)}i => sub {
    Rodney::Command::Noscum->run(@_, "!$1 $2")
};

on qr{^!asconly\s+(.*)}i => sub {
    Rodney::Command::Asconly->run(@_, $1)
};

on qr{^!asconly(\w+)\b\s*(.*)}i => sub {
    Rodney::Command::Asconly->run(@_, "!$1 $2")
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

