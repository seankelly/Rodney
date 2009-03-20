package Rodney::Command::Bribe;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    my $self = shift;
    my $args = shift;

    return "Calculates the chances of bribing a mercenary based on your experience level, charisma, visible gold, and mercenary type. Note that visible gold is calculated _after_ you throw the gold, which is somewhat counterintuitive. This may be fixed in the future. For now just have out exactly what you need to throw.";
}

sub gold_needed {
    my ($X, $vg, $xl, $Y, $ch) = @_;
    return 1 + $X + int(($vg + $xl*$Y)/$ch);
};

sub run {
    my $self = shift;
    my $args = shift;

    my $text = $args->{args};

    my %X_for = (
      soldier    => 100,
      sergeant   => 250,
      lieutenant => 500,
      captain    => 750,
    );

    my @xl = 1..30;
    my @ch = 3..25;
    my ($xl, $ch);
    my $type = 'soldier';
    my $vg = 0;

    $xl   =    $1  if $text =~ s/(?:[EX]L?|Exp?)      [ =:]? (\d+)//xi;
    $vg   =    $1  if $text =~ s/(?:g(?:old)?|vg?|\$) [ =:]? (\d+)//xi;
    $ch   =    $1  if $text =~ s/C(?:ha?)?            [ =:]? (\d+)//xi;
    $type = lc($1) if $text =~ s/(soldier|sergeant|lieutenant|captain)//xi;

    my $X = $X_for{$type};

    return "Syntax is !bribe XL <experience level> VG <visible gold> CHA <charisma> <soldier|sergeant|lieutenant|captain> -- defaults: vg=0, soldier"
        if (!defined($xl) || !defined($vg) || !defined($ch));

    return "Experience level out of range. $xl[0] <= XL <= $xl[-1]"
        if ($xl < $xl[0] || $xl > $xl[-1]);

    return "Scrooge!"
        if ($vg >= 1_000_000);

    return "Charisma out of range. $ch[0] <= Ch <= $ch[-1]"
        if ($ch < $ch[0] || $ch > $ch[-1]);

    my %amount;

    for my $rn2 (0..4) {
        my $gold = gold_needed($X, $vg, $xl, $rn2, $ch);
        my $line = sprintf '%d%%:%d', int(20 * ($rn2 + 1) * 2/3), $gold;
        $amount{$gold} = $line;
    }

    return "To bribe a $type with XL $xl, cha $ch, visible \$$vg:  " . 
        join ', ', map { $amount{$_} } sort keys %amount;
}

1;

