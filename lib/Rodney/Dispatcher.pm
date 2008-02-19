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
use Rodney::Command::Help;
use Rodney::Command::Seen;
use Rodney::Command::Where;
use Rodney::Command::Roles;
use Rodney::Command::Player;
use Rodney::Command::Date;
use Rodney::Command::Zscore;
use Rodney::Command::Monsterify;
use Rodney::Command::Rng;

sub on;

on qr{^!g(?:ames(?:by)?)?\b\s*}i => "Rodney::Command::Gamesby";
on qr{^!asc(?:ensions?)?\b\s*}i  => "Rodney::Command::Ascensions";
on qr{^!num\b\s*}i               => "Rodney::Command::Num";
on qr{^!rot13\b\s*}i             => "Rodney::Command::Rot13";
on qr{^!help\b\s*}i              => "Rodney::Command::Help";
on qr{^!seen\b\s*}i              => "Rodney::Command::Seen";
on qr{^!where\b\s*}i             => "Rodney::Command::Where";
on qr{^!roles?\b\s*}i            => "Rodney::Command::Roles";
on qr{^!pl(?:r|ayerlink)\b\s*}i  => "Rodney::Command::Player";
on qr{^!date\b\s*}i              => "Rodney::Command::Date";
on qr{^!time\b\s*}i              => "Rodney::Command::Date";
on qr{^!zscore\b\s*}i            => "Rodney::Command::Zscore";
on qr{^!monsterify\b\s*}i        => "Rodney::Command::Monsterify";
on qr{^!rng\b\s*}i               => "Rodney::Command::Rng";

# meta commands
on qr{^!r(?:ecent)?\s+}i => "Rodney::Command::Recent";
on qr{^!noscum\s+}i      => "Rodney::Command::Noscum";
on qr{^!asconly\s+}i     => "Rodney::Command::Asconly";
on qr{^!grep\s+(?:(.+)((?<!\?|<)!\w+\b.*)$|(.+)$)}i => sub {
    my @a = ("Rodney::Command::Grep");
    if (defined($1)) {
        @a = (@a, text => $1);
    }
    else {
        @a = (@a, text => $3);
    }
    if (defined($2)) {
        @a = (@a, subcommand => $2);
    }
    return @a;
};

on qr{^!r(?:ecent)?(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Recent", subcommand => "!$1 $2");
};

on qr{^!noscum(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Noscum", subcommand => "!$1 $2");
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

