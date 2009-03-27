package Rodney::Command::Grep;
use strict;
use warnings;
use parent 'Rodney::Command::Meta';

my $sort;
my $error;
my $offset;

my %conducts = (
    foodless     => 1,
    vegan        => 2,
    vegetarian   => 4,
    atheist      => 8,
    weaponless   => 16,
    pacifist     => 32,
    illiterate   => 64,
    polypileless => 128,
    polyselfless => 256,
    wishless     => 512,
    artiwishless => 1024,
    genoless     => 2048,
);

my %conduct_aliases = (
    weapless     => 16,
    illit        => 64,
    polyless     => 384,
    genocideless => 2048,
);

my %achieve = (
    bell        => 1,    # obtained Bell
    gehennom    => 2,    # entered Gehennom
    candelabrum => 4,    # obtained candelabrum
    book        => 8,    # obtained Book
    invocation  => 16,   # performed ritual
    amulet      => 32,   # obtained amulet
    planes      => 64,   # reached Planes
    astral      => 128,  # reached Astral
    ascended    => 256,
    mines       => 512,  # completed Mines
    sokoban     => 1024, # completed Sokoban
    medusa      => 2048, # killed Medusa
);

my %achieve_aliases = (
    ritual => 16,
    ascend => 256,
);

sub help {
    my $self = shift;
    my $args = shift;

    return 'Available columns: ' . join ', ', Rodney::Game->readable_attributes
        if $args->{text} && $args->{text} =~ /^(?:fields?|columns?)$/;

    return 'Syntax is: !grep PERSON /DEATH/'
        if $args->{text} eq 'usage';

    return 'Available conducts: ' . join(', ', keys %conducts)
        . '; aliases: ' . join(', ', keys %conduct_aliases)
        if $args->{text} =~ /^conducts?/;

    return 'Available achievements: ' . join(', ', keys %achieve)
        . '; aliases: ' . join(', ', keys %achieve_aliases)
        if $args->{text} =~ /^achieve(?:ments)?/;

    return 'Greps the database for games matching the arguments. Available subtopics: fields usage';
}

sub games_callback {
    my $self = shift;
    my $games = shift;
    my $args = shift;

    $error = 0;
    $sort = 0;
    $offset = 0;

    $args->{args} = $args->{text};
    my $grep = Grep($games, $args);
    return $grep if $grep;
}

sub cant_redispatch {
    my $self = shift;
    my $args = shift;

    $args->{args} = $args->{text};
    my $games = $self->games($args);
    my $target = $self->target($args);

    return $error if $error;


    my $result;
    my @results;
    my $count = $games->count;

    # in case several thousand or more rows will be returned, limit to
    # just the first 25
    $games->set_page_info(
        per_page => 25
    ) if $count > 25 && $offset == 0;

    while (my $g = $games->next) {
        if ($self->target_is_server($args)) {
            push @results, $g->id;
        }
        else {
            push @results, $g->gamenum;
        }
    }

    if ($count == 1) {
        $result = $games->first->to_string(100, count => $count);
    }
    elsif (($sort && $count > 0) || $offset) {
        $offset = 1 if $offset == 0;
        $result = $games->first->to_string(100, count => $count, offset => $offset);
    }
    elsif ($count == 0) {
        $result = 'No games found.';
    }
    elsif ($count > 1) {
        $result = sprintf '%d games found: #%s',
                    $count,
                    join ', #', @results;
        $result .= ', ...' if $count > 25;
    }

    return $result;
}

sub regex {
    my $message = shift;
    my @regex;
    my @sort;
    my %bitfields; # this is currently for achieve and conduct
    # this matches
    # num:N => $2 $3
    # min|max:column => $2 $3
    # conduct:list => $2 $3
    # achieve:list => $2 $3
    # column/regex/flags => $3 $5 $6 $4
    # column<=>N => $3 $7 $8
    while ($message =~ s#({(?:\s*(num|min|max|conduct|achieve):\s*)?\s*([!\w,]+)(?:\s*(!)?/([^/]*)/\s*([ri]*)|\s*([<=>])\s*(-?\d+))?\s*})##) {
        if (defined($2)) {
            if ($2 eq 'conduct' || $2 eq 'achieve') {
                my @list = split ',', lc($3);
                for (@list) {
                    $bitfields{$_} = $2;
                }
            }
            # column, min|max|num
            else {
                push @sort, [lc ($3), $2];
            }
        }
        elsif (defined($7) && defined($8)) {
            # column, operator, compared to what
            push @sort, [lc ($3), $7, $8];
        }
        next if !defined($5);
        my $type = lc($3);
        my $regex = $5;
        # column, regex, modifiers, negated, entire thing
        push @regex, [$type, $regex, $6, $4, $1];
    }
    if ($message =~ s#((!)?/([^/]*)/([ir]*))##) {
        push @regex, ['death', $3, $4, $2, $1];
    }

    if (@regex == 0 && @sort == 0 && length($message) > 0) {
        my $first = substr $message, 0, 1;
        if ($first eq '!') {
            # doesn't matter if sort is included
            # just need regex pointing to an empty array
            return (regex => []) if length $message == 1;
            $message = substr $message, 1;
        }
        else {
            $first = undef;
        }
        @regex = ['death', $message, "", $first, "/$message/"];
        $message = '';
    }

    return (sort => \@sort, regex => \@regex, bitfields => \%bitfields);
}

# just limits the collection
# DOES silently fail in meta-command mode
sub Grep {
    my $games = shift;
    my $args  = shift;

    # first check that something was given...
    unless (defined $args->{args} && $args->{args}) {
        return ($error = 'Syntax is: !grep PERSON /DEATH/');
    }

    my %regex = regex($args->{args});
    unless (@{$regex{regex}} > 0) {
        return ($error = 'Syntax is: !grep PERSON /DEATH/');
    }

    # next check that the fields are valid
    for (@{$regex{regex}},@{$regex{sort}}) {
        my $c = Rodney::Game->column($_->[0]);
        next if $c || $_->[1] eq 'num';
        return ($error = 'Invalid field: ' . $_->[0]);
    }

    # now do the limiting based on the regex
    for (@{$regex{regex}}) {
        $games->limit(
            column   => $_->[0],
            value    => $_->[1],
            # this is ugly, I know!
            operator => ($_->[3] ? '!' : '')
                        . ($_->[2] =~ /i/ ? '~*' : '~'),
            entry_aggregator => 'and',
        ) if length($_->[1]) > 0;
    }

    for my $field (keys %{ $regex{bitfields} }) {
        my $column = $regex{bitfields}->{$field};
        my $negate = $field =~ s/^!//;
        my $hash = $column eq 'conduct' ? \%conducts : \%achieve;
        my $alias = $column eq 'conduct' ? \%conduct_aliases : \%achieve_aliases;
        my $clauseid = $column . '-' . $field;
        my $bit = $hash->{$field} || $alias->{$field};
        next unless $bit;
        my $equal = $negate ? 0 : $bit;
        $games->limit(
            subclause => $clauseid,
            column    => $column,
            value     => $bit,
            operator  => '&',
            entry_aggregator => '=',
        );
        $games->limit(
            subclause => $clauseid,
            column    => '',
            value     => $equal,
            operator  => '',
            alias     => '',
            entry_aggregator => '=',
        );
    }

    # and then sorting..
    if (@{$regex{sort}} > 0) {
        my @sort;
        for (@{$regex{sort}}) {
            if ($_->[1] eq 'num') {
                $offset = $_->[0];
                $games->set_page_info(
                    current_page => $offset,
                    per_page     => 1,
                );
                next;
            }
            # column <=> foo
            if (defined($_->[2]) && Rodney::Game->column($_->[0])->is_numeric) {
                $games->limit(
                    column   => $_->[0],
                    operator => $_->[1],
                    value    => $_->[2],
                    entry_aggregator => 'and',
                );
            }
            # min and max
            else {
                $sort = 1;
                push @sort, {
                    column => $_->[0],
                    order  => ($_->[1] eq 'min') ? 'asc' : 'desc',
                };
            }
        }
        $games->add_order_by(@sort);
    }
    else {
        $games->add_order_by(
            column => 'id',
            order  => 'asc',
        ) unless $games->_order_clause;
    }

    # return 0 for success
    return 0;
}

# so commands can know that grep can be used either way
sub is_command { 1 }

1;

