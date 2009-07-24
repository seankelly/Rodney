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

    # single value arguments
    [ 'foobar', [ { column => undef, operator => undef, value => 'foobar' } ] ],

    # regex arguments
    [ '/foobar/', [ { column => undef, operator => '~', value => 'foobar', re_option => undef } ] ],
    [ '/taeb/i', [ { column => undef, operator => '~', value => 'taeb', re_option => 'i' } ] ],
    [ '/\btaeb|beat\b/', [ { column => undef, operator => '~', value => '\btaeb|beat\b', re_option => undef } ] ],
    [ '/\btaeb|beat\b/i', [ { column => undef, operator => '~', value => '\btaeb|beat\b', re_option => 'i' } ] ],
);

plan tests => scalar @tests;

for my $test (@tests) {
    my ($arg, $expected) = @{ $test };
    my $got = parse_arguments($arg);
    is_deeply($got, $expected, $arg);
}
