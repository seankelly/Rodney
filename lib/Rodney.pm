#!perl
package Rodney;
use strict;
use warnings;
use parent 'Bot::BasicBot';
use Module::Refresh;
use Jifty::DBI::Handle;

use Rodney::Dispatcher;
use Rodney::Seen;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{handle} = Jifty::DBI::Handle->new;
    $self->{handle}->connect(
        driver => 'SQLite',
        database => 'nethack',
    );

    return $self;
}

sub said {
    my $self = shift;
    my $args = shift;

    print "<$args->{who}> $args->{body}\n";
    $args->{handle} = $self->{handle};

    Rodney::Seen->seen(
        handle  => $args->{handle},
        nick    => $args->{who},
        message => "$args->{who} saying '$args->{body}'.",
    );

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

