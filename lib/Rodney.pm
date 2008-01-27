#!perl
package Rodney;
use strict;
use warnings;
use parent 'Bot::BasicBot';
use Rodney::Dispatcher;
use Module::Refresh;
use Jifty::DBI::Handle;

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

