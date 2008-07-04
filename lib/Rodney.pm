#!perl
package Rodney;
use strict;
use warnings;
use parent 'Bot::BasicBot';
use Module::Refresh;
use POE;
use Jifty::DBI::Handle;
use Heap::Simple;

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

    # create a max priority queue
    $self->{message_queue} = Heap::Simple->new(
        order    => '>',
        elements => 'Any',
    );

    $self->{tick_enabled} = 0;

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

    # handle if $ret is not an array ref
    unless (ref($ret) eq 'ARRAY') {
        $self->enqueue({
            who     => $args->{who},
            channel => $args->{channel},
            address => 0,
            body    => $ret,
        });
        return;
    }

    for (@{ $ret }) {
        my %msg = (
            who     => $args->{who},
            channel => $args->{channel},
            address => 0,
            body    => $_,
        );
        $self->enqueue(\%msg);
    }
}

sub enqueue {
    my $self = shift;
    my $data = shift;
    my $priority = shift || 1;

    $self->{message_queue}->key_insert($priority, $data);

    unless ($self->{tick_enabled}) {
        $self->schedule_tick(1);
        $self->{tick_enabled} = 1;
    }
}

sub tick {
    my $self = shift;

    if ($self->{message_queue}->count) {
        my $msg = $self->{message_queue}->extract_top;
        $self->say(%$msg);
    }

    return 2 if $self->{message_queue}->count;

    $self->{tick_enabled} = 0;
    return 0;
}

sub chanjoin {
    my $self = shift;
    my $args = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $args->{who},
        message => "joining $args->{channel}.",
    );

    return undef;
}

sub chanpart {
    my $self = shift;
    my $args = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $args->{who},
        message => "leaving $args->{channel}.",
    );

    return undef;
}

sub chanquit {
    my $self = shift;
    my $args = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $args->{who},
        message => $args->{body}
                   ? "quitting with message: $args->{body}."
                   : "quitting without a message.",
    );
}

sub nick_change {
    my $self = shift;
    my $from = shift;
    my $to   = shift;

    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $from,
        message => "changing nick to $to.",
    );
    Rodney::Seen->seen(
        handle  => $self->{handle},
        nick    => $to,
        message => "changing nick from $from.",
    );

    return undef;
}

sub got_names {
    my $self = shift;
    my $args = shift;
    for my $nick (keys %{ $args->{names} }) {
        Rodney::Seen->seen(
            handle  => $self->{handle},
            nick    => $nick,
            message => "when I joined $args->{channel}.",
        );
    }
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

