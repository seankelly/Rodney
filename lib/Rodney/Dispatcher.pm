package Rodney::Dispatcher;
use Moose;
use Module::Pluggable
    require     => 1,
    search_path => 'Rodney::Command',
    sub_name    => 'commands';
use Module::Pluggable
    require     => 1,
    search_path => 'Rodney::Model',
    except      => 'Rodney::Model::Schema',
    sub_name    => 'tables';
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
        my $match = $self->dispatcher->dispatch($command);

        if ($match->has_matches) {
            my $args = $base_args;
            $args->{body} = $command;

            # set stdin properly for the command
            $args->{stdin} = undef;
            if ($result) {
                my $ref = ref $result;
                if ($ref eq 'ARRAY') {
                    $args->{stdin} = $result;
                }
                elsif ($ref eq '' ) {
                    $args->{stdin} = [ $result ];
                }
            }

            eval {
                $result = $match->run($args);
            };
            # if a command dies, return the error
            return $@ if $@;
        }
        else {
            return if $index == 1;
            # XXX: maybe move this up and only dispatch on $c then?
            my ($c, @args) = split ' ', $command;
            return "Invalid command: $c.";
        }
        $index++;
    }

    return $result;
}

sub _build_base_args {
    my $self = shift;
    my $arghash = shift;
    my %base_args;

    %base_args = (
        sql => { },
        stdin => undef,
        %$arghash,
    );

    for my $table ($self->tables) {
        my $base;
        ($base = $table) =~ s/.*:://;
        $base_args{sql}->{$base} = {
            select => $table->SchemaClass->SQLFactoryClass->new_select,
            table  => $table,
        };
    }

    delete $base_args{body};

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
                            return $command->run(@_);
                        },
                    )
                );
            }
        }
    }
}

no Moose;
1;
