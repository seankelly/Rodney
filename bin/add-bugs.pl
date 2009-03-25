#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use LWP::Simple;
use Rodney::Model::Bug;
use HTML::TreeBuilder;

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

        my $Bug = Rodney::Model::Bug->new(bugid => $id);
        unless (defined $Bug) {
            # This is to ameliorate confusion between
            # 'fixed' and 'Fixed'.
            $status = 'NextVersion' if $status eq 'Fixed';
            Rodney::Model::Bug->insert(
                bugid       => $id,
                status      => $status,
                description => $desc,
            );
        }
    }

    $tree->delete;
}
