#!/usr/bin/env perl -wT
use strict;
use warnings;
use Rodney::Util 'find_quoted';
use Test::More;

my @tests = (
    [ '"blah"',                  'blah' ],
    [ "'blah'",                  'blah' ],
    [ '"bl ah "',                'bl ah ' ],
    [ '"blah" "ignore this"',    'blah' ],
    [ '"blah" \'ignore this\'',  'blah' ],
    [ "'blah' 'other stuff'",    'blah' ],
    [ '"bl\"ah" other stuff',    'bl"ah' ],
    [ "'bl\\'ah' other stuff",   "bl'ah" ],
    [ '/foo\\/bar/ other stuff', 'foo/bar' ],
    [ '!foobar! other stuff',    'foobar' ],
    [ '#foobar# other stuff',    'foobar' ],
    [ '{foobar} other stuff',    'foobar' ],
    [ '<foo\>bar> other stuff',  'foo>bar' ],
    [ '<foo<bar> other stuff',   'foo<bar' ],
    [ "'bl\\\\'ah' other stuff", "bl\\'ah" ],
    # failing quotes
    [ "'foo bar", undef ],
);

plan tests => scalar @tests;

for my $test (@tests) {
    my $expect = $test->[1];
    my $got = find_quoted($test->[0], substr($test->[0], 0, 1));
    is($got, $expect, $test->[1]);
}
