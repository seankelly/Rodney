package Rodney::Dispatcher;
use strict;
use warnings;

#sub dispatch {
#    my $self = shift;
#    my $args = shift;
#    local $_ = $args->{body};
#
#    for my $rule (@rules) {
#        my ($re, $code) = @$rule;
#        if ($_ =~ $re) {
#            return (ref($code) ? $code->($args) : $code),
#                   args => $';
#        }
#    }
#
#    return;
#}

=head2 dispatch Arg-hash

Executes commands, if present, in the arg-hash. The arg-hash
should be in the format
    
    body    => String from message.
    who     => Nickname for the string.
    channel => Channel in which the string was sent. Use '?' for private messages.

This can be passed as a hash ref or as a hash itself.

=cut

sub dispatch {
    my $self = shift;
    my $arghash;
    if (ref $_[0] eq 'HASH') {
        $arghash = shift;
    }
    elsif (ref $_[0] eq '') {
        my %hash = (@_);
        $arghash = \%hash;
    }

    # XXX: Should it be Rodney->config->foo?
    # FIXME: make the following work
    my $prefix = Rodney->config->prefix;
    my $pipe_cmd = $prefix . $prefix;

    # check if there is a command
    return unless $arghash->{body} =~ /^$prefix/;

    my @commands = split $pipe_cmd, $arghash->{body};
    for my $command (@commands) {
    }
}

1;

