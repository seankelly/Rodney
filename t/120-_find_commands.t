#!perl -T
use strict;
use warnings;
use Test::More;
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

my %commands = (
    'normal chatter about worldly topics' => 0,
    '!foo' => 1,
    '!foo !!bar' => 2,
    '!foo!!bar' => 2,
    'more normal channel with exclamation points! huzzah!! w00t' => 0,
);
plan tests => scalar keys %commands;

my $dispatcher = Rodney::Dispatcher->new;

for my $cmd (keys %commands) {
    my $should_be = $commands{$cmd};
    my @res = $dispatcher->_find_commands($cmd);
    is(scalar @res, $should_be, "testing '$cmd'");
}
