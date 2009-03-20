#!/usr/bin/env perl
package Rodney::Command::Halp;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    my @responses = (
        'Halp me!', 'sad unicorn',
    );
    return $responses[int(rand(@responses))];
}

sub run {
    return '--:<';
}

1;

