#!/usr/bin/env perl
package Rodney::Util;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw/plural ntimes once stats fstats plane/;

=head2 plural count, singular[, plural]

Returns a string of the form "N foos". The plural is optional, if it's absent
an "s" will be appended to the singular.

=cut

sub plural {
    my $count = shift;
    my $singular = shift;
    my $plural = shift || "${singular}s";

    return $count == 1 ? "1 $singular" : "$count $plural";
}

=head2 ntimes count

Returns a string of the form "once", "twice", "thrice", or "N times".

=cut

sub ntimes {
    my $count = shift;

    return "once"   if $count == 1;
    return "twice"  if $count == 2;
    return "thrice" if $count == 3;
    return "$count times";
}

=head2 once count

Returns a string of the form "once", "twice", "thrice", or "N".

=cut

sub once {
    my $count = shift;

    return "once"   if $count == 1;
    return "twice"  if $count == 2;
    return "thrice" if $count == 3;
    return $count;
}

=head2 stats hash

Returns a string of the form "9xFoo 4xBar 4xBaz"

=cut

sub stats {
    my %stats = @_;

    my @parts = map  { "$stats{$_}x$_" }
                sort { $stats{$b} <=> $stats{$a} || $a cmp $b }
                keys %stats;

    return join ' ', @parts;
}

=head2 fstats hash

Returns a string of the form "Foo(float) Bar(float) Baz(float)"

=cut

sub fstats {
    my %stats = @_;

    my @parts = map { sprintf("%s(%.4f)", $_, $stats{$_})}
                sort { $stats{$b} <=> $stats{$a} || $a cmp $b }
                keys %stats;

    return join ' ', @parts;

}

=head2 planes

Returns which plane corresponds to the given level.

=cut

sub plane {
    my $level = shift;
    my $verbosity = shift || 2;
    my @planes = qw/Astral Water Fire Air Earth/;
    my $name = $planes[$level] || 'Foo';
    $name .= ' Plane' if $verbosity == 2;
    return $name;
}

1;

