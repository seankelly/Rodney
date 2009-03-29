#!perl -T
use strict;
use warnings;
use Test::More tests => 2;
use Rodney::Dispatcher;

do {
    package Rodney::Command::TEST;
    use strict;
    use warnings;
    our @COMMANDS = qw/TEST1 TEST2 TEST3/;

    sub run {
        shift;
        my $cmd = shift;
        return $cmd;
    }
};

my $dispatcher = Rodney::Dispatcher->new;

my $command = 'TEST' . (int(rand(scalar @Rodney::Command::TEST::COMMANDS))+1);

my $d = $dispatcher->dispatcher->dispatch($command);
ok($d->has_matches, "matches against $command");

my $res = $d->run();
is($res->run($command), $command, 'returns right result');