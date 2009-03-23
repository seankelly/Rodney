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
    align => 'alignment',
    death => 'death',
    gender0 => 'startgender',
    align0 => 'startalignment',
);

my @dungeon = qw(dungeon gehennom mines quest sokoban ludios vlad planes);

sub bits_set {
    my $conduct = shift;

    return unless defined $conduct;

    my $conducts = 0;
    $conducts += !!(2**$_ & $conduct) for 0..11;

    return $conducts;
}

my %gamenum;

while (<>) {
    my $game;
    $game = parse_xlogline($_);
    $game = parse_logline($_) unless defined $game;
    die "Unable to parse logline '$_'" unless defined $game;

    my %converted = map { ($convert{$_}||$_) => $game->{$_} } keys %{ $game };

    $converted{ascended} = $converted{death} eq 'ascended' ? 1 : 0;
    $converted{dungeon}  = $dungeon[$converted{dungeon}];
    $converted{conduct}  = hex($converted{conduct}) if $converted{conduct};
    $converted{conducts} = bits_set($converted{conduct});
    $converted{achieve}  = hex($converted{achieve}) if $converted{achieve};
    $converter{start}    = 0;
    $converter{end}      = 0;
    $converter{realtime} = 0;

    my $player = Rodney::Model::Player->new(name => $converted{player});
    if (!defined $player) {
        $player = Rodney::Model::Player->insert(name => $converted{player});
    }

    $converted{gamenum} = ++$gamenum{$converted{player}};
    $converted{player_id} = $player->id;

    Rodney::Model::Game->insert(%converted);
}
