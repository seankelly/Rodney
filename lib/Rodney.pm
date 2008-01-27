#!perl
package Rodney;
use strict;
use warnings;
use parent 'Bot::BasicBot';
use Rodney::Dispatcher;
use Module::Refresh;

sub said {
    my $self = shift;
    my $args = shift;

    print "<$args->{who}> $args->{body}\n";

    my $ret = eval { $self->dispatch($args) };
    warn $@ if $@;

    return $ret;
}

sub dispatch {
    my $self = shift;
    my $args = shift;

    Module::Refresh->refresh;

    return Rodney::Dispatcher->dispatch($args);
}

1;

