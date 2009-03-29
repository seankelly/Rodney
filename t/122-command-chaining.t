#!perl -T
use strict;
use warnings;
use Test::More tests => 1;
use Rodney::Dispatcher;

do {
    package Rodney;
    use Moose;
    use MooseX::ClassAttribute;
    use Rodney::Config;

    class_has config => (
        is      => 'ro',
        isa     => 'Rodney::Config',
        default => sub { Rodney::Config->new },
    );
};

my $lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
my $new_lorem;
($new_lorem = $lorem) =~ tr/a-zA-Z/n-za-mN-ZA-M/;

do {
    package Rodney::Command::TEST1;
    our @COMMANDS = qw/TEST1/;

    # generate some text
    sub run {
        my $self = shift;
        my $args = shift;
        my @opts = split ' ', $args->{body};
        if (@opts > 1 && $opts[1] =~ /(\d+)/) {
            my @lorem = split ' ', $lorem, $1;
            return \@lorem;
        }
        return $lorem;
    }

    package Rodney::Command::TEST2;
    use Moose;
    extends 'Rodney::Command';
    our @COMMANDS = qw/TEST2/;

    # rot13 the text
    sub run {
        my $self = shift;
        my $args = shift;
        my @input = $self->get_input($args);
        my @output;
        for (@input) {
            my $new;
            ($new = $_) =~ tr/a-zA-Z/n-za-mN-ZA-M/;
            push @output, $new;
        }
        return join ' ', @output;
    }
};

my $dispatcher = Rodney::Dispatcher->new;


use DDS;

my $args = {
    body => "!TEST1 !!TEST2",
};
my $result = $dispatcher->dispatch($args);
is($result, $new_lorem, "output is passed to second command and transformed");
