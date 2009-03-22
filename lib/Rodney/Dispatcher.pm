package Rodney::Dispatcher;
use strict;
use warnings;

sub on;

on qr{^!g(?:ames(?:by)?)?\b\s*}i => "Rodney::Command::Gamesby";
on qr{^!asc(?:ensions?)?\b\s*}i  => "Rodney::Command::Ascensions";
on qr{^!num\b\s*}i               => "Rodney::Command::Num";
on qr{^!rot13\b\s*}i             => "Rodney::Command::Rot13";
on qr{^!help\b\s*}i              => "Rodney::Command::Help";
on qr{^!halp\b\s*}i              => "Rodney::Command::Halp";
on qr{^!seen\b\s*}i              => "Rodney::Command::Seen";
on qr{^!where\b\s*}i             => "Rodney::Command::Where";
on qr{^!roles?\b\s*}i            => "Rodney::Command::Roles";
on qr{^!pl(?:r|ayerlink)\b\s*}i  => "Rodney::Command::Player";
on qr{^!date\b\s*}i              => "Rodney::Command::Date";
on qr{^!time\b\s*}i              => "Rodney::Command::Date";
on qr{^!zscore\b\s*}i            => "Rodney::Command::Zscore";
on qr{^!monsterify\b\s*}i        => "Rodney::Command::Monsterify";
on qr{^!rng\b\s*}i               => "Rodney::Command::Rng";
on qr{^!read\b\s*}i              => "Rodney::Command::Read";
on qr{^!outfoxed\b\s*}i          => "Rodney::Command::Outfoxed";
on qr{^!hsn\b\s*([^!]*)}i        => sub {
    ("Rodney::Command::Hsn", message => $1);
}; 
on qr{^!pom\b\s*}i               => "Rodney::Command::Time";
on qr{^!cmdlist\b\s*}i           => "Rodney::Command::Cmdlist";
on qr{^!bugs?\b\s*}i             => "Rodney::Command::Bugdb";
on qr{^!learn\b\s*}i             => "Rodney::Command::Learndb";
on qr{^\?.+}i                    => "Rodney::Command::Learndb";
on qr{^!ascstreak\b\s*}i         => "Rodney::Command::Ascstreak";
on qr{^!bribe\b\s*}i             => "Rodney::Command::Bribe";
on qr{^!vlad\b\s*}i              => "Rodney::Command::Vlad";

# meta commands
on qr{^!r(?:ecent)?\s+}i => "Rodney::Command::Recent";
on qr{^!noscum\s+}i      => "Rodney::Command::Noscum";
on qr{^!asconly\s+}i     => "Rodney::Command::Asconly";
on qr{^!grep(?:\s+(?:(.+)((?<!\?|<|:|,)!\w+\b.*)$|(.+)$))?}i => sub {
    my @a = ("Rodney::Command::Grep");
    if (defined($1)) {
        push @a, (text => $1);
    }
    else {
        push @a, (text => (defined $3 ? $3 : ''));
    }
    if (defined($2)) {
        push @a, (subcommand => $2);
    }
    return @a;
};

on qr{^!r(?:ecent)?(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Recent", subcommand => "!$1 $2");
};

on qr{^!noscum(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Noscum", subcommand => "!$1 $2");
};

on qr{^!asconly(\w+)\b\s*(.*)}i => sub {
    ("Rodney::Command::Asconly", subcommand => "!$1 $2");
};

on qr{^!max(?:\b\s*([^!]+)(.*)|$)}i => sub {
    ("Rodney::Command::Max",
        text => $1, subcommand => (defined($2) ? $2 : '!num #1'));
};

on qr{^!min(?:\b\s*([^!]+)(.*)|$)}i => sub {
    ("Rodney::Command::Min",
        text => $1, subcommand => (defined($2) ? $2 : '!num #1'));
};
on qr{^!since(?:\s*([^!]+)(.*)|$)}i       => sub {
    ( "Rodney::Command::Since",
        text => $1, subcommand => (defined($2) ? $2 : '!gamesby'));
};

my @rules;
sub on {
    my ($re, $code) = @_;
    push @rules, [$re, $code];
}

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

