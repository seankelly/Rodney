package Rodney;
use strict;
use warnings;
use parent 'Bot::BasicBot';
use Module::Refresh;
use Heap::Simple;

use Rodney::Dispatcher;
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

    print sprintf "<%s/%s> %s\n",
        $args->{who},
        $args->{channel} ne 'msg' ? $args->{channel} : '?',
        $args->{body};

    # XXX: dispatch goes here
    my $ret = undef;

    return unless $ret;

    if (ref($ret) eq '' || ref($ret) eq 'ARRAY') {
        $self->msg(
            who     => $args->{who},
            channel => $args->{channel},
            address => 0,
            body    => $ret,
        );
    }
    elsif (ref($ret) eq 'HASH') {
        $self->msg(
            who     => $ret->{who},
            channel => $ret->{channel},
            address => 0,
            body    => $ret->{body},
        );
    }

    return;
}

sub msg {
    my $self = shift;
    my %args;
    if (ref($_[0]) eq 'HASH') {
        %args = %{ $_[0] };
    }
    else {
        %args = (@_);
    }

    my $priority = $args{channel} =~ /^#/
                   ? 10
                   : 5;

    $self->enqueue(\%args, $priority);
}

sub enqueue {
    my $self = shift;
    my $data = shift;
    my $priority = shift || 1;

    $self->{message_queue}->key_insert($priority, $data);

    unless ($self->{tick_enabled}) {
        $self->{tick_enabled} = 1;
        $self->schedule_tick(.1);
    }
}

sub tick {
    my $self = shift;

    if ($self->{message_queue}->count) {
        my $key = $self->{message_queue}->top_key;
        my $msg = $self->{message_queue}->extract_top;

        if (ref($msg->{body}) eq 'ARRAY') {
            my %msg = %$msg;
            my $body = delete $msg{body};
            my $tosend = shift @{ $body };
            $msg->{body} = $body;
            $msg{body} = $tosend;
            $self->say(%msg);
            $self->enqueue($msg, $key) if scalar @{ $body } > 0;
        }
        else {
            $self->say(%$msg);
        }
    }

    return 2 if $self->{message_queue}->count;

    $self->{tick_enabled} = 0;
    return 0;
}

sub chanjoin {
    my $self = shift;
    my $args = shift;

    return;
}

sub chanpart {
    my $self = shift;
    my $args = shift;

    return;
}

sub userquit {
    my $self = shift;
    my $args = shift;
}

sub nick_change {
    my $self = shift;
    my $from = shift;
    my $to   = shift;

    return;
}

sub got_names {
    my $self = shift;
    my $args = shift;
    for my $nick (keys %{ $args->{names} }) {
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

sub help {
    return 'I recommend trying !help';
}

1;

