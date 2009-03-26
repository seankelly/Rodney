package Rodney::Config;
use Moose;
use YAML;
use Hash::Merge 'merge';

has contents => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

sub BUILD {
    my $self = shift;

    # change this so can specify it at runtime
    my @config = "etc/config.yml";

    my %seen;

    Hash::Merge::set_behavior('RIGHT_PRECEDENT');

    while (my $file = shift @config) {
        next if $seen{$file}++;
        next if !-f $file;

        my $config = YAML::LoadFile($file);
        $self->contents(merge($self->contents, $config));

        # if this config specified other files, load them too
        if ($config->{other_config}) {
            my $c = $config->{other_config};
            if (ref($c) eq 'ARRAY') {
                push @config, @$c;
            }
            elsif (ref($c) eq 'HASH') {
                push @config, keys %$c;
            }
            else {
                push @config, $c;
            }
        }
    }
}

# yes autoload is bad. but, I am lazy
our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s{.*::}{};

    if (@_) {
        $self->contents->{$AUTOLOAD} = shift;
    }
    return $self->contents->{$AUTOLOAD};
}

no Moose;
1;
