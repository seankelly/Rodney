#!perl -T
use strict;
use warnings;
use Test::More;
use Rodney::Command;

my @packages = map { 'TEST' . $_ } 1..3;
plan tests => scalar @packages;

for my $package (@packages) {
    my $namespace = "Rodney::Plugin::$package";
    eval <<"PACKAGE"
    do {
        package $namespace;
        use Moose;
        with 'Rodney::Role::Command';
        sub run {}
        sub command {}
    };
PACKAGE
}

my %packages = map { $_ => 1 } Rodney::Command->commands;

for (@packages) {
    my $namespace = "Rodney::Plugin::$_";
    ok($packages{$namespace}, "Found $_");
}
