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

on qr{^!g(?:ames(?:by)?)?\b}i => "Rodney::Command::Gamesby";
on qr{^!asc(?:ensions?)?\b}i => "Rodney::Command::Ascensions";
on qr{^!num\b}i => "Rodney::Command::Num";

on qr{^!grep(\s+(.*))?$}i => sub {
    ("Rodney::Command::Grep", text => $2);
};

on qr{^!rot13\s+(.*)}i => sub {
    ("Rodney::Command::Rot13", text => $1);
};

# meta commands

on qr{^!r\s+(.*)}i => sub {
    ("Rodney::Command::Recent", subcommand => $1);
};

on qr{^!r(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Recent", subcommand => "!$1 $2");
};

on qr{^!noscum\s+(.*)}i => sub {
    ("Rodney::Command::Noscum", subcommand => $1);
};

on qr{^!noscum(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Noscum", subcommand => "!$1 $2");
};

on qr{^!asconly\s+(.*)}i => sub {
    ("Rodney::Command::Asconly", subcommand => $1);
};

on qr{^!asconly(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Asconly", subcommand => "!$1 $2");
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
            return (ref($code) ? $code->($args) : $code),
                   args => $';
        }
    }

    return;
}

1;

