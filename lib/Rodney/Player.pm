package Rodney::Player;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column name =>
        type is 'varchar',
        is mandatory;
};

1;
