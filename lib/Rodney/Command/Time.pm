#!/usr/bin/env perl
package Rodney::Command::Time;
use strict;
use warnings;
use parent 'Rodney::Command';

# for vagueness fun
use DateTime::Event::Sunrise;
use Astro::MoonPhase;

sub help {
    return 'Gives the phase of the moon.';
}

our $vagueness = 0;

sub time {
}

sub pom {
    my $moonsub = sub {
        my $moonage = shift;
        my @table = (@_);
        return $table[0] if $moonage == 0;

        my @ages = qw/7 14 21/;
        my $i = 1;
        for my $age (@ages) {
            return $table[$i] if $moonage < $age;
            return $table[$i+1] if $moonage == $age;
            $i += 2;
        }
        return $table[7];
    };

    my ($phase, $illum, $age) = phase();

    if ($vagueness == 0) {
        return sprintf 'The Moon is %d%% full.',
               int($illum * 100 + 0.5);
    }
    elsif ($vagueness == 1) {
        my @table = (
            'New moon', 'Waxing crescent', 'First quarter',
            'Waxing gibbous', 'Full moon!!', 'Waning gibbous',
            'Last quarter', 'Waning crescent'
        );
        return $moonsub->($age, @table);
    }
    elsif ($vagueness == 2) {
        my @table = ("Can't see it", "Little bit", 'Halfway', "Almost there", "Bright light!", "Bit dark", "Partly dark", "Mostly dark");
        return $moonsub->($age, @table);
    }
}

sub run {
    my $self = shift;
    my $args = shift;

    $args->{body} =~ /^!(\w+)/;
    my $cmd = lc $1;

    $self->can($cmd)->($args) if $self->can($cmd);
}

1;

