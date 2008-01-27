#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use NetHack::Logfile 'parse_logline';
use Rodney::Game;
use Rodney::Player;

my %convert = (
    name => 'player',
    version => 'version',
    points => 'score',
    deathdnum => 'dungeon',
    deathlev => 'curlvl',
    maxlvl => 'maxlvl',
    hp => 'curhp',
    maxhp => 'maxhp',
    deaths => 'deaths',
    deathdate => 'enddate',
    birthdate => 'startdate',
    uid => 'uid',
    role => 'role',
    race => 'race',
    gender => 'gender',
    align => 'alignment',
    death => 'death',
);

my @dungeon = qw(dungeon gehennom mines quest sokoban ludios vlad planes);

use Jifty::DBI::Handle;
my $handle = Jifty::DBI::Handle->new;
$handle->connect(
    driver => 'SQLite',
    database => 'nethack',
);

while (<>) {
    my $game = parse_logline($_);
    my %converted = map { $convert{$_} => $game->{$_} } keys %$game;

    $converted{ascended} = $converted{death} eq 'ascended' ? 1 : 0;

    my $player = Rodney::Player->new(handle => $handle);
    $player->load_by_cols(name => $converted{player});
    $player->id or do {
        my $newplayer = Rodney::Player->new(handle => $handle);
        $newplayer->create(name => $converted{player});
    };

    my $game_obj = Rodney::Game->new(handle => $handle);
    $game_obj->create(%converted);
}

