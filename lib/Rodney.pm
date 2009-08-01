package Rodney;
use Moose;
use MooseX::NonMoose;
extends 'Bot::BasicBot';
use MooseX::ClassAttribute;

use Heap::Simple;
use Module::Refresh;
use Rodney::Config;
use Rodney::Dispatcher;

class_has config => (
    is       => 'ro',
    isa      => 'Rodney::Config',
    default  => sub { Rodney::Config->new },
);

has dispatcher => (
    is       => 'ro',
    isa      => 'Rodney::Dispatcher',
    default  => sub { Rodney::Dispatcher->new },
    handles  => [ qw/dispatch/ ],
);

has queue => (
    is       => 'ro',
    isa      => 'Heap::Simple',
    default  => sub { Heap::Simple->new },
);

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
    if (defined(Rodney->config->password)) {
        $self->say(
            who => 'nickserv',
            channel => 'msg',
            body => 'identify ' . Rodney->config->nick . ' ' . Rodney->config->password
        );
    }
}

sub help {
    return 'I recommend trying !help';
}

# Overriding Bot::BasicBot's AUTOLOAD because I want to know when
# it is used so I can avoid using it.
sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    $AUTOLOAD =~ s/.*.:://;
    die "AUTOLOAD called: ${self}->$AUTOLOAD(@_)"
}

sub FOREIGNBUILDARGS {
    my %bot_args = (
        server   => Rodney->config->server,
        channels => Rodney->config->channels,
        nick     => Rodney->config->nick,
        @_,
    );

    return %bot_args;
}

__PACKAGE__->meta->make_immutable;

no Moose;
no MooseX::ClassAttribute;

1;
