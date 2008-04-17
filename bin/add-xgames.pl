#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Text::XLogfile 'parse_xlogline';
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
    starttime => 'starttime',
    endtime => 'endtime',
    realtime => 'realtime',
    gender0 => 'startgender',
    align0 => 'startalignment',
    conduct => 'conduct',
    achieve => 'achieve',
    turns => 'turns',
);

my @dungeon = qw(dungeon gehennom mines quest sokoban ludios vlad planes);
my %gamenum;

use Jifty::DBI::Handle;
my $handle = Jifty::DBI::Handle->new;
$handle->connect(
    driver => 'SQLite',
    database => 'nethack',
);

while (<>) {
    my $game = parse_xlogline($_);
    my %converted = map { $convert{$_} => $game->{$_} } keys %$game;

    $converted{ascended} = $converted{death} eq 'ascended' ? 1 : 0;
    $converted{dungeon}  = $dungeon[$converted{dungeon}];
    $converted{conduct}  = hex($converted{conduct}) if $converted{conduct};
    $converted{achieve}  = hex($converted{achieve}) if $converted{achieve};

    my $player = Rodney::Player->new(handle => $handle);
    $player->load_by_cols(name => $converted{player});
    $player->id or do {
        my $newplayer = Rodney::Player->new(handle => $handle);
        $newplayer->create(name => $converted{player});
    };

    $converted{gamenum} = ++$gamenum{$converted{player}};

    my $game_obj = Rodney::Game->new(handle => $handle);
    $game_obj->create(%converted);
}

