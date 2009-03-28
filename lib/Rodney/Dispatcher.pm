package Rodney::Dispatcher;
use Moose;
use Module::Pluggable
    require => 1,
    search_path => 'Rodney::Command',
    sub_name => 'commands';
use Path::Dispatcher;

has dispatcher => (
    is      => 'ro',
    isa     => 'Path::Dispatcher',
    default => sub { Path::Dispatcher->new },
);

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
    elsif (ref $_[0] eq '' && @_ > 1 && @_ % 2 == 0) {
        my %hash = (@_);
        $arghash = \%hash;
    }
    else {
        die 'Invalid arguments to dispatch';
    }


    my @commands = $self->_find_commands($arghash->{body});
    my $index = 1;
    my $base_args = $self->_build_base_args($arghash);
    my $result;
    for my $command (@commands) {
        $index++;
    }
}

sub _build_base_args {
    my %base_args;

    %base_args = (
        sql => {
            bug => {
                select => 'select object',
                table  => 'table object',
            },
            game => {
                select => 'select object',
                table  => 'table object',
            },
            learndb => {
                select => 'select object',
                table  => 'table object',
            },
            player => {
                select => 'select object',
                table  => 'table object',
            },
            seen => {
                select => 'select object',
                table  => 'table object',
            },
        },
        stdin => undef,
        %$arghash,
    );

    delete %base_args{body};

    return \%base_args;
}

sub _find_commands {
    my $self = shift;
    my $cmd_string = shift;

    my $prefix = Rodney->config->prefix;
    my $pipe_cmd = $prefix . $prefix;

    return unless $cmd_string =~ s/^($prefix)//;
    my @commands = split $pipe_cmd, $cmd_string;

    return @commands;
}

sub BUILD {
    my $self = shift;

    for my $command ($self->commands) {
        my @cmds = eval "\@${command}::COMMANDS";
        if (@cmds) {
            for my $cmd (@cmds) {
                $self->dispatcher->add_rule(
                    Path::Dispatcher::Rule::Tokens->new(
                        tokens => [ $cmd ],
                        block  => sub {
                            # $command contains the package
                            return $command;
                        },
                    )
                );
            }
        }
    }
}

no Moose;
1;
