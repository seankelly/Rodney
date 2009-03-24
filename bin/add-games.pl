#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use NetHack::Logfile 'parse_logline';
use Text::XLogfile 'parse_xlogline';
use Rodney::Model::Game;
use Rodney::Model::Player;
use DateTime::Format::ISO8601;
use DateTime::Format::Epoch;

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

# because we just get a number of the dungeon,
# map it to something human readable
my @dungeon = qw(dungeon gehennom mines quest sokoban ludios vlad planes);

# counts the number of bits set in a word
# this is for the conducts column
sub bits_set {
    my $conduct = shift;

    return unless defined $conduct;

    my $conducts = 0;
    $conducts += !!(2**$_ & $conduct) for 0..11;

    return $conducts;
}

# create epoch object for parsing xlogfile times
my $epoch = DateTime::Format::Epoch->new(
    epoch => DateTime->new(year => 1970, day => 1, month => 1)
);

my $iso8601 = DateTime::Format::ISO8601->new;

sub parse_time {
    my %date = (@_);

    my $dt;
    if (defined $date{epoch}) {
        $dt = $epoch->parse_datetime($date{epoch});
    }
    else {
        my ($year, $month, $day) = $date{ymd} =~ /^(\d{4})(\d\d)(\d\d)$/;
        $dt = DateTime->new(
            year   => $year,
            month  => $month,
            day    => $day,
            hour   => 0,
            minute => 0,
            second => 0,
        );
    }

    return $iso8601->format_datetime($dt);
}

# this stores the number of games a player has played
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
    $converted{start}    = parse_time(epoch => $converted{starttime}, ymd => $converted{birthdate});
    $converted{end}      = parse_time(epoch => $converted{endtime}, ymd => $converted{deathdate});
    delete @converted{qw/starttime birthdate endtime deathdate/};

    my $player = Rodney::Model::Player->new(name => $converted{player});
    if (!defined $player) {
        $player = Rodney::Model::Player->insert(name => $converted{player});
    }

    $converted{gamenum} = ++$gamenum{$converted{player}};
    $converted{player_id} = $player->id;

    Rodney::Model::Game->insert(%converted);
}
