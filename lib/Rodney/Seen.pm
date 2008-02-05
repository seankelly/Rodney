#!/usr/bin/env perl
package Rodney::Seen;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column nick =>
        type is 'varchar',
        is mandatory;

    column time =>
        type is 'integer',
        is mandatory;

    column message =>
        type is 'varchar',
        is mandatory;
};

sub seen {
    my $self = shift;
    my %args = (
        time => time,
        @_,
    );


    my $seen = Rodney::Seen->new(handle => $args{handle});

    $seen->load_by_cols(nick => $args{nick});
    unless ($seen->nick) {
        return $seen->create(
            nick => $args{nick},
            time => $args{time},
            message => $args{message},
        );
    };

    $seen->set_time($args{time});
    $seen->set_message($args{message});
}

1;

