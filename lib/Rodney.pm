#!perl
package Rodney;
use strict;
use warnings;
use parent 'Bot::BasicBot';
use Module::Refresh;
use Jifty::DBI::Handle;

use Rodney::Dispatcher;
use Rodney::Seen;
use Rodney::Config;

sub new {
    my $class = shift;
    Rodney::Config->init;

    my %args = (
        server   => Rodney::Config->server,
        channels => Rodney::Config->channels,
        nick     => Rodney::Config->nick,
        @_,
    );

    my $self = $class->SUPER::new(%args);

    $self->{handle} = Jifty::DBI::Handle->new;
    $self->{handle}->connect(
        driver   => Rodney::Config->database->{driver},
        database => Rodney::Config->database->{database},
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
        message => "saying '$args->{body}'.",
    );

    my $ret = eval { $self->dispatch($args) };
    warn $@ if $@;

    return $ret;
}

sub chanjoin {
    my $self = shift;
    my $args = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $args->{who},
        message => "joining $args->{channel}.",
    );
}

sub chanpart {
    my $self = shift;
    my $args = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $args->{who},
        message => "leaving $args->{channel}.",
    );
}

sub nick_change {
    my $self = shift;
    my $args = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $args->{from},
        message => "changing nick to $args->{to}.",
    );
}

sub connected {
    my $self = shift;
    if (defined(Rodney::Config->password)) {
        $self->say(
            who => 'nickserv',
            channel => 'msg',
            body => 'identify ' . Rodney::Config->nick . ' ' . Rodney::Config->password
        );
    }
}

sub dispatch {
    my $self = shift;
    my $args = shift;

    Module::Refresh->refresh;

    my ($package, %args) = Rodney::Dispatcher->dispatch($args);
    return unless $package;

    $package->run({ %$args, subcommand => '', %args });
}

1;

