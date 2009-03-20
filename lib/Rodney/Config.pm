package Rodney::Config;
use strict;
use warnings;
use YAML;
use Hash::Merge 'merge';

our %contents;

sub init {
    my @config = "etc/config.yml";

    my %seen;

    Hash::Merge::set_behavior('RIGHT_PRECEDENT');

    while (my $file = shift @config) {
        next if $seen{$file}++;
        next if !-f $file;

        my $config = YAML::LoadFile($file);
        %contents = %{ merge(\%contents, $config) };

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
    $AUTOLOAD =~ s{.*::}{};
    return $contents{$AUTOLOAD};
}

1;

