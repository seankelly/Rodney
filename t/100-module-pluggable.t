#!perl -T
use strict;
use warnings;
use Test::More;
use Rodney::Dispatcher;

my @packages = map { 'TEST' . $_ } 1..3;
plan tests => scalar @packages;

for my $package (@packages) {
    my $namespace = "Rodney::Command::$package";
    eval "do { package $namespace; sub run { return \$_[1] } }";
}

my $dispatcher = Rodney::Dispatcher->new;
my %packages = map { $_ => 1 } $dispatcher->commands;

for (@packages) {
    my $namespace = "Rodney::Command::$_";
    ok($packages{$namespace}, "Found $_");
}
