#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Rodney::Bug;
use LWP::Simple;

use Jifty::DBI::Handle;
my $handle = Jifty::DBI::Handle->new;
$handle->connect(
    driver => 'SQLite',
    database => 'nethack',
);

my $bug_content = get('http://www.nethack.org/v343/bugs.html') . get('http://www.nethack.org/v343/spoiler.html');
die "Couldn't get bugs" unless defined $bug_content;


while ($bug_content =~ s{
<tr>\s*

<td>
<a\ name="[^"]+">
  ([^<]+?)
  \s*
</a>
\s*
(?:</td>)?
<td>
<a\ href="[^"]+">
  ([^<]+?)
  \s*
</a>
\s*

(?:</td>)?
<td>
([^<]+?)
\s*

(?:</td>)?
<td>
.*?

(?:</td>)?(?:</tr>)?
}{}xms) {
    my ($id, $status, $text) = ($1, $2, $3);
    $text =~ s/\n/ /g;

    my %create = (
        bugid       => $id,
        status      => $status,
        description => $text,
    );

    my $bug = Rodney::Bug->new(handle => $handle);
    $bug->create(%create);
}
