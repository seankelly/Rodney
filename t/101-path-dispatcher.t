#!perl -T
use strict;
use warnings;
use Test::More tests => 6;
use Rodney::Dispatcher;

do {
    package Rodney::Plugin::TEST;
    use Moose;
    with 'Rodney::Role::Command';

    sub command { qw/TEST1 TEST2 TEST3/ };

    sub run {
        shift;
        my $args = shift;
        return $args->{body};
    }
};

my $dispatcher = Rodney::Dispatcher->new;

my @commands = Rodney::Plugin::TEST->command;

for my $command (@commands) {
    my $d = $dispatcher->dispatcher->dispatch($command);
    ok($d->has_matches, "matches against $command");

    my $res = $d->run({ body => $command});
    is($res, $command, 'returns right result');
}
