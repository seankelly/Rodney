package Rodney::Command::Rng;
use strict;
use warnings;
use parent 'Rodney::Command';
use Rodney::Util qw/races roles genders alignments/;

sub run {
    my $self = shift;
    my $args = shift;
    my $msg = $args->{args};

    my @words = split / /, $msg;
    if ($msg eq '@coin') {
        @words = ('heads', 'tails');
    }
    elsif ($msg eq '@dice') {
        @words = ('1', '2', '3', '4', '5', '6');
    }
    elsif ($msg eq '@tf' || $msg eq '@tf') {
        @words = ('true', 'false', 'yes', 'no');
    }
    elsif ($msg eq '@race' || $msg eq '@races') {
        @words = races();
    }
    elsif ($msg eq '@role' || $msg eq '@roles' ||
           $msg eq '@class' || $msg eq '@classes') {
        @words = roles();
    }
    elsif ($msg eq '@gender' || $msg eq '@genders' ||
           $msg eq '@sex' || $msg eq '@sexes') {
        @words = genders();
    }
    elsif ($msg eq '@align' || $msg eq '@aligns' ||
           $msg eq '@alignment' || $msg eq '@alignments') {
        @words = alignments();
    }
    elsif ($msg eq '@char' || $msg eq '@chars') {
        my @ra = races();
        my @ro = roles();
        my @g = genders();
        my @a = alignments();
        return sprintf("%s %s %s %s", $ra[rand @ra], $ro[rand @ro], $g[rand @g],
                                      $a[rand @a]);
    }

    return $words[rand @words];
}

1;
