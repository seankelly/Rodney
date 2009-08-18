#!/usr/bin/env perl
use strict;
use warnings;
use LWP::Simple;
use Rodney::Config;
use Rodney::Schema;
use HTML::TreeBuilder;

my $config = Rodney::Config->new;
my $db_config = $config->database;

my $schema = Rodney::Schema->connect(
    "dbi:$db_config->{driver}:dbname=$db_config->{database}",
    $db_config->{username},
    $db_config->{password}
);

my $bug_rs = $schema->resultset('Bug');

my @urls = (
    'http://www.nethack.org/v343/bugs.html',
    'http://www.nethack.org/v343/spoiler.html',
);

for my $url (@urls) {
    my $content = get($url);
    die "Could not get $url" unless defined $content;

    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);
    $tree->eof;


    my @bugs = $tree->look_down(
        _tag => 'tr',
        sub { my @tags = $_[0]->find('td'); @tags >= 3 },
    );

    for my $bug (@bugs) {
        my ($id, $status, $desc) = $bug->find('td');
        $id = $id->as_text;
        $status = $status->as_text;
        $desc = $desc->as_text;

        my $Bug = $bug_rs->find({ bugid => $id });
        unless (defined $Bug) {
            # This is to ameliorate confusion between
            # 'fixed' and 'Fixed'.
            $status = 'NextVersion' if $status eq 'Fixed';
            $bug_rs->create({
                bugid       => $id,
                status      => $status,
                description => $desc,
            });
        }
    }

    $tree->delete;
}
