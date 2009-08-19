#!/usr/bin/env perl
use strict;
use warnings;
use NetHack::Logfile 'parse_logline';
use Text::XLogfile 'parse_xlogline';
use Rodney::Config;
use Rodney::Schema;
use DateTime;
use Scalar::Util 'looks_like_number';

my $config = Rodney::Config->new;
my $db_config = $config->database;
my $schema = Rodney::Schema->connect(
    "dbi:$db_config->{driver}:dbname=$db_config->{database}",
    $db_config->{username},
    $db_config->{password},
    {
        quote_char => '"',
        name_sep   => '.',
    }
);

my $game_rs = $schema->resultset('Game');
my $player_rs = $schema->resultset('Player');

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

sub parse_time {
    my %date = (@_);

    my $dt;
    if (defined $date{epoch}) {
        $dt = DateTime->from_epoch(epoch => $date{epoch});
    }
    else {
        my ($year, $month, $day) = $date{ymd} =~ /^(\d{4})(\d\d)(\d\d)$/;
        $dt = DateTime->new(
            year      => $year,
            month     => $month,
            day       => $day,
            hour      => 0,
            minute    => 0,
            second    => 0,
            time_zone => 'UTC',
        );
    }

    return $dt->iso8601 . '+00';
}

# Match last games in database with those in the file.
sub match_last_games {
    my $check_games = 10;
    my $rs = $game_rs->search(undef,
        {
            order_by => { -desc => 'id' },
            rows     => $check_games,
        }
    );

    my @games;
    my $g;
    unshift @games, {
        score     => $g->score,
        curhp     => $g->curhp,
        starttime => $g->start->epoch,
        endtime   => $g->end->epoch,
        player    => $g->player->name,
    } while $g = $rs->next;

    my @cmp = qw/score curhp starttime endtime player/;

    # Now spin through games in the file.
    my $count = $game_rs->search(undef)->count;
    my $id = 0;
    my $error = 0;
    while (<>) {
        $id++;
        next if $id <= $count - $check_games;
        last if $id == $count;

        my $game = parse_game($_);
        my $expected = shift @games;
        for my $key (@cmp) {
            if (looks_like_number($game->{$key})) {
                if ($expected->{$key} != $game->{$key}) {
                    warn $expected->{$key}, '!= ' ,$game->{$key};
                    $error = 1;
                }
            }
            elsif ($expected->{$key} ne $game->{$key}) {
                warn $expected->{$key}, 'ne ' ,$game->{$key};
                $error = 1;
            }
        }

    }

    die "Error in matching last games" if $error;
}

sub parse_game {
    my $input = shift;
    my $game;
    $game = parse_xlogline($input);
    $game = parse_logline($input) unless defined $game;
    die "Unable to parse logline '$input'" unless defined $game;

    my %converted = map { ($convert{$_}||$_) => $game->{$_} } keys %{ $game };

    return \%converted;
}

match_last_games;

# this stores the number of games a player has played
my %gamenum;
my %player_id;

while (<>) {
    my $game = parse_game($_);

    $game->{ascended} = $game->{death} eq 'ascended' ? 1 : 0;
    $game->{dungeon}  = $dungeon[$game->{dungeon}];
    $game->{conduct}  = hex($game->{conduct}) if $game->{conduct};
    $game->{conducts} = bits_set($game->{conduct});
    $game->{achieve}  = hex($game->{achieve}) if $game->{achieve};
    $game->{start}    = parse_time(epoch => $game->{starttime}, ymd => $game->{birthdate});
    $game->{end}      = parse_time(epoch => $game->{endtime}, ymd => $game->{deathdate});

    unless ($gamenum{$game->{player}}) {
        # Load of create the player.
        my $player = $player_rs->search(
            { name => $game->{player} }
        )->first;
        if (!defined $player) {
            $player = $player_rs->create({ name => $game->{player} });
        }

        # Start with 0 games because of the pre-increment.
        $gamenum{$game->{player}} = 0;
        $player_id{$game->{player}} = $player->id;
    }

    $game->{gamenum}   = ++$gamenum{$game->{player}};
    $game->{player_id} = $player_id{$game->{player}};

    delete @{$game}{qw/starttime birthdate endtime deathdate player/};
    $game_rs->create($game);
}
