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

do {
    package Rodney::Command::TEST1;
    our @COMMANDS = qw/TEST1/;

    # generate some text
    sub run {
        my $self = shift;
        my $args = shift;
        if ($args->{body} =~ /(\d+)/) {
            my @lorem = split ' ', $lorem, $1;
            return @lorem;
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
            push @output, tr/a-zA-Z/n-za-mN-ZA-M/;
        }
        return @output;
    }
};

my $dispatcher = Rodney::Dispatcher->new;


use DDS;

my $args = {
    body => "!TEST1",
};
my $result = $dispatcher->dispatch($args);
is($result, $lorem, "testing if command is run and args passed");
