#!perl -T
use strict;
use warnings;
use Test::More;

use Rodney::Util 'parse_arguments';

my @tests = (
    # single argument tests
    [ 'col=1', [ { column => 'col', operator => '=', value => 1 } ] ],
    [ 'col=foo', [ { column => 'col', operator => '=', value => 'foo' } ] ],
    [ 'col="foo"', [ { column => 'col', operator => '=', value => 'foo' } ] ],
    [ 'col="foo bar"', [ { column => 'col', operator => '=', value => 'foo bar' } ] ],
    [ "col='foo bar'", [ { column => 'col', operator => '=', value => 'foo bar' } ] ],
    [ 'col:1', [ { column => 'col', operator => ':', value => 1 } ] ],
    [ 'col:foo', [ { column => 'col', operator => ':', value => 'foo' } ] ],
    [ 'col!=1', [ { column => 'col', operator => '!=', value => 1 } ] ],
    [ 'col!=foo', [ { column => 'col', operator => '!=', value => 'foo' } ] ],
    [ "col!='foo bar'", [ { column => 'col', operator => '!=', value => 'foo bar' } ] ],

    # multiple argument tests
    [ 'foo<1 bar:2 xyzzy="a string"', [
            { column => 'foo', operator => '<', value => 1 },
            { column => 'bar', operator => ':', value => 2 },
            { column => 'xyzzy', operator => '=', value => "a string" },
        ]
    ],
);

plan tests => scalar @tests;

for my $test (@tests) {
    my ($arg, $expected) = @{ $test };
    my $got = parse_arguments($arg);
    is_deeply($got, $expected, $arg);
}
