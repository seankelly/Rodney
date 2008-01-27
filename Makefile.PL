# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'Rodney';
all_from       'lib//Rodney.pm';

requires       '';

build_requires 'Test::More';

auto_install;
WriteAll;

