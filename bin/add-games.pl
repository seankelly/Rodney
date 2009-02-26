#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use NetHack::Logfile 'parse_logline';
use Text::XLogfile 'parse_xlogline';
use Rodney::Model::Game;
use Rodney::Model::Player;

# convert some of the field names to something better
my %convert = (
    name => 'player',
    points => 'score',
    deathdnum => 'dungeon',
    deathlev => 'curlvl',
    hp => 'curhp',
    deathdate => 'enddate',
    birthdate => 'startdate',
    align => 'alignment',
    death => 'death',
    gender0 => 'startgender',
    align0 => 'startalignment',
);

my @dungeon = qw(dungeon gehennom mines quest sokoban ludios vlad planes);

use Jifty::DBI::Handle;
my $handle = Jifty::DBI::Handle->new;
$handle->connect(
    driver => 'SQLite',
    database => 'nethack',
);

while (<>) {
    my $game;
    $game = parse_xlogline($_);
    $game = parse_logline($_) unless defined $game;
    die "Unable to parse logline '$_'" unless defined $game;

    my %converted = map { ($convert{$_}||$_) => $game->{$_} } keys %{ $game };

    $converted{ascended} = $converted{death} eq 'ascended' ? 1 : 0;
    $converted{dungeon}  = $dungeon[$converted{dungeon}];

    my $player = Rodney::Player->new(handle => $handle);
    $player->load_by_cols(name => $converted{player});
    $player->id or do {
        my $newplayer = Rodney::Player->new(handle => $handle);
        $newplayer->create(name => $converted{player});
    };

    my $game_obj = Rodney::Game->new(handle => $handle);
    $game_obj->create(%converted);
}

