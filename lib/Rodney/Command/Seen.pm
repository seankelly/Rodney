package Rodney::Command::Seen;
use strict;
use warnings;
use parent 'Rodney::Command';

use Time::Duration;

sub seens {
    package Rodney::SeenCollection;
    use parent 'Jifty::DBI::Collection';
    my $self = shift;
    my $args = shift;

    my $seen = Rodney::SeenCollection->new(handle => $args->{handle});
    return $seen;
}

sub help {
    return 'Last time I saw someone.';
}

sub run {
    my $self = shift;
    my $args = shift;

    $args->{handle}->clear_sql_statement_log;
    my $nick;
    $args->{args} =~ /^(\w+)/;
    $nick = $1 if $1;

    return 'Seen who?' unless $nick;

    my $seen = $self->seens($args);

    $seen->limit(
        column => 'nick',
        value  => $nick
    );

    if ($seen->first) {
        return sprintf "I last saw %s %s %s",
            $seen->first->nick,
            ago(time() - $seen->first->lastseen),
            $seen->first->message
            ;
    }
    return "Haven't seen $nick.";
}

1;

