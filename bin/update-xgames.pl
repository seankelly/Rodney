#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Text::XLogfile 'parse_xlogline';
use POSIX;
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
    driver => 'Pg',
    database => 'nethack',
);

my $games = Rodney::GameCollection->new(handle => $handle);
$games->unlimit;
my $count = $games->count;

$games->order_by(
    column => 'id',
    order  => 'desc',
);

$games->rows_per_page(10);

# grab last ten games in the db
my @games;
while (my $g = $games->next) {
    unshift @games, {
        score     => $g->score,
        endtime   => $g->endtime,
        starttime => $g->starttime,
        realtime  => $g->realtime,
        maxhp     => $g->maxhp,
    };
}

# spin through all but last 10 games
my $id = 1;
while (<>) {
    last if $id == $count - 10;
    $id++;
}

# match last ten games in the db with last ten games
# before new data in the logfile
my $error = 0;
while (<>) {
    my $game = parse_xlogline($_);
    my %converted = map { $convert{$_} => $game->{$_} } keys %$game;

    my $match = shift @games;
    for my $key (keys %{ $match }) {
        unless ($converted{$key} == $match->{$key}) {
            warn $converted{$key}, " != ", $match->{$key};
            $error = 1;
        }
    }
    $id++;
    last if $id == $count;
}

die "match error" if $error;

# add new games
while (<>) {
    my $game = parse_xlogline($_);
    my %converted = map { $convert{$_} => $game->{$_} } keys %$game;

    $converted{ascended} = $converted{death} eq 'ascended' ? 1 : 0;
    $converted{dungeon}  = $dungeon[$converted{dungeon}];
    $converted{conduct}  = hex($converted{conduct}) if $converted{conduct};
    $converted{achieve}  = hex($converted{achieve}) if $converted{achieve};

    my $player = Rodney::Player->new(handle => $handle);
    $player->load_by_cols(name => $converted{player});
    if ($player->id) {
        # load player's last gamenum
        my $game = Rodney::Game->new(handle => $handle);
        $game->limit(
            column => 'player',
            value  => $converter{player},
        );
        $game->order_by(
            column => 'gamenum',
            order  => 'desc',
        );
        $game->rows_per_page(1);
        $gamenum{$converted{player}} = $game->next->gamenum;
    }
    else {
        my $newplayer = Rodney::Player->new(handle => $handle);
        $newplayer->create(name => $converted{player});
    };

    $converted{gamenum} = ++$gamenum{$converted{player}};

    my $game_obj = Rodney::Game->new(handle => $handle);
    $game_obj->create(%converted);
}

