package Rodney::Command::Bugdb;
use strict;
use warnings;
use parent 'Rodney::Command';

sub help {
    return 'Help text for the bugdb';
}

sub count {
    my $self = shift;
    my $args = shift;

    my $bugs = Rodney::BugCollection->new(handle => $args->{handle});
    $bugs->unlimit;

    return $bugs->count . ' bugs on the buglist at http://www.nethack.org/v343/bugs.html';
}

sub grep {
}

sub run {
    my $self = shift;
    my $args = shift;

    return $self->count($args) unless $args->{args};

    my @args = split ' ', $args->{args};
    if ($args[0] =~ /^grep$/i) {
    }
    elsif ($args[0] =~ /^count$/i) {
        return $self->count($args);
    }
    else {
        my $bugs = Rodney::BugCollection->new(handle => $args->{handle});
        $bugs->unlimit;

        $bugs->limit(
            column => 'bugid',
            value  => $args[0],
        );

        if ($bugs->count == 1) {
            my $bug = $bugs->next;
            return sprintf "%s (%s): %s",
                   $bug->bugid,
                   $bug->status,
                   $bug->description;
        }
        $bugs->unlimit;
        $bugs->limit(
            column   => 'description',
            value    => join('%', @args),
            operator => 'MATCHES',
        );

        if ($bugs->count == 0) {
            return "No matching bugs on the list.";
        }
        elsif ($bugs->count == 1) {
            my $bug = $bugs->next;
            return sprintf "%s (%s): %s",
                   $bug->bugid,
                   $bug->status,
                   $bug->description;
        }
        elsif ($bugs->count <= 25) {
            my @list;
            while (my $bug = $bugs->next) {
                push @list, $bug->bugid;
            }
            return 'Matching bugs: ' .
                   join(', ', @list);
        }
        else {
            return $bugs->count . ' bugs matched.';
        }
    }
}

1;

