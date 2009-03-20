package Rodney::Command::Vlad;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return "Lists the possible levels of Vlad's Tower, based on what information you give it. By default, the argument (a number) is interpreted as the level of the Valley. If a 'c' exists in the argument, the number is interpreted as the level of the Castle.";
}

sub run {
    my $self = shift;
    my $args = shift;
    my $message = $args->{args};
    my $from_castle = $message =~ s/C//ig;
    my ($level) = $message =~ /(\d+)/;
    my $valley = $level + $from_castle;
    if ($valley < 26 || $valley > 30)
    {
      return "If you want help, quit being a goof.";
    }

    return sprintf 'Vlad\'s is between %d and %d, inclusive.',
                   $valley + 8, $valley + 12;
}

1;

