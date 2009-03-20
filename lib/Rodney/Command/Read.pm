#!/usr/bin/env perl
package Rodney::Command::Read;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Chance of reading a spellbook';
}

sub run {
    my $self = shift;
    my $args = shift;

    my $speaker = $args->{who};

    my @xl = 1..30;
    my @sl = 1..7;
    my @in = 3..25;

    my ($xl, $sl, $in);

    $xl = $1 if $args->{args} =~ s/(?:[ex]l?|exp?) [ :=]? (\d+)//xi;
    $sl = $1 if $args->{args} =~ s/(?:[sb]l?|\+)   [ :=]? (\d+)//xi;
    $in = $1 if $args->{args} =~ s/(?:i(?:nt?)?)   [ :=]? (\d+)//xi;

    my $defined = 0;
    ++$defined if defined($xl);
    ++$defined if defined($sl);
    ++$defined if defined($in);

    if ($defined == 0) {
        return 'Syntax is: !read XL<experience level> SL<spellbook level> Int<intelligence>. Leave one out to act over its range. Sample usage: !read XL9 Int10.'
    }
    elsif ($defined < 2) {
        return "$speaker: You need to specify at least two of: intelligence, experience level, and spellbook level.";
    }

    if (defined($xl) && ($xl < $xl[0] || $xl > $xl[-1]))
    {
        return "$speaker: Experience level out of range. $xl[0] <= XL <= $xl[-1]";
    }
    elsif (defined($sl) && ($sl < $sl[0] || $sl > $sl[-1]))
    {
        return "$speaker: Spellbook level out of range. $sl[0] <= SL <= $sl[-1]";
    }
    elsif (defined($in) && ($in < $in[0] || $in > $in[-1]))
    {
        return "$speaker: Intelligence out of range. $in[0] <= In <= $in[-1]";
    }

    my $variable;
    my @chances;

    if (!defined($xl))
    {
        $variable = 'Exp level: ';
        @chances = map {$_ . ':' . calc($_, $sl, $in) . '%'} @xl;
    }
    elsif (!defined($sl))
    {
        $variable = 'Book level: ';
        @chances = map {$_ . ':' . calc($xl, $_, $in) . '%'} @sl;
    }
    elsif (!defined($in))
    {
        $variable = 'Intelligence: ';
        @chances = map {$_ . ':' . calc($xl, $sl, $_) . '%'} @in;
    }
    else
    {
        $variable = 'Chance to read:';
        @chances = calc($xl, $sl, $in) . '%';
    }

    shift @chances while @chances > 1 && $chances[1] =~ /:(0|100)%/;
    pop   @chances while @chances > 1 && $chances[-2] =~ /:(0|100)%/;

    return $variable . ' ' . join(', ', @chances);
}

sub calc
{
    my ($xl, $sl, $in) = @_;
    my $chance = ($in + 4 + int($xl/2) - 2*$sl);
    $chance = 0 if $chance < 0;
    $chance = 20 if $chance > 20;
    return $chance * 5;
}

1;

