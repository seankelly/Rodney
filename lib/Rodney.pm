#!perl
package Rodney;
use parent 'Bot::BasicBot';

sub said {
    my ($self, $args) = @_;
    print "<$args->{who}> $args->{body}\n";
    return '';
}

1;

