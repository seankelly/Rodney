#!/usr/bin/env perl -wT
use strict;
use warnings;

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
);

plan tests => scalar @tests;

for my $test (@tests) {
    my $expect = $test->[1];
    my $got = transform($test->[0]);
    cmp_ok($got, 'eq', $expect, $test->[1]);
}

sub transform {
    my $string = shift;

    my $start = substr($string, 0, 1);

    my %end = (
        '<' => '>',
        '{' => '}',
        '(' => ')',
        '[' => ']',
    );

    my $end = $end{$start} || $start;

    my $re = qr/^$start(.*?)(?<!\\)$end/;
    $string =~ $re;

    my $quoted = $1;
    $quoted =~ s/\\$end/$end/g;

    return $quoted;
}
