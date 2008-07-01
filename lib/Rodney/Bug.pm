package Rodney::Bug;
use strict;
use warnings;

use Jifty::DBI::Schema;
use Jifty::DBI::Record schema {
    column bugid =>
        type is 'varchar',
        max_length is 10,
        is mandatory;

    column description =>
        type is 'varchar',
        is mandatory;

    column status =>
        type is 'varchar',
        max_length is 15,
        is mandatory;
};

package Rodney::BugCollection;
use parent 'Jifty::DBI::Collection';

1;

