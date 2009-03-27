package Rodney;
use Moose;
use MooseX::ClassAttribute;
extends 'Bot::BasicBot', 'Moose::Object';

use Heap::Simple;
use Module::Refresh;
use Rodney::Config;
use Rodney::Dispatcher;

class_has config => (
    is       => 'ro',
    isa      => 'Rodney::Config',
    default  => sub { Rodney::Config->new },
);

has queue => (
    is       => 'ro',
    isa      => 'Heap::Simple',
    default  => sub { Heap::Simple->new },
);

around new => sub {
    my $orig  = shift;
    my $class = shift;

    my %bot_args = (
        server   => Rodney->Config->server,
        channels => Rodney->Config->channels,
        nick     => Rodney->Config->nick,
        @_,
    );

    my $self = $class->$orig(%bot_args);

    return $self;
};

sub said {
    my $self = shift;
    my $args = shift;

    print sprintf "<%s/%s> %s\n",
        $args->{who},
        $args->{channel} ne 'msg' ? $args->{channel} : '?',
        $args->{body};

    # XXX: dispatch goes here
    my $ret = undef;

    return;
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

no Moose;
no MooseX::ClassAttribute;
1;
