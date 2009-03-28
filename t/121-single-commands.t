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

my @packages = map { 'TEST' . $_ } 1..3;
plan tests => scalar @packages;

for my $package (@packages) {
    my $namespace = "Rodney::Command::$package";
    eval "do { package $namespace; our \@COMMANDS = qw/$package/; sub run { return \$_[1]->{body} } }";
}

my $dispatcher = Rodney::Dispatcher->new;


use DDS;

for (@packages) {
    my $args = {
        body => "!$_",
    };
    my $result = $dispatcher->dispatch($args);
    is($result, $_, "testing if command is run and args passed");
}
