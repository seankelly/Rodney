#!/usr/bin/env perl
package Rodney::Command::Monsterify;
use strict;
use warnings;
use parent 'Rodney::Command';

my %monster_letters =
(
  ' ' => ['ghost', 'shade'],
  '&' => ['Asmodeus', 'Baalzebub', 'Death', 'Demogorgon', 'Dispater', 'Famine', 'Geryon', 'Juiblex', 'Minion of Huhetotl', 'Nalzok', 'Orcus', 'Pestilence', 'Yeenoghu', 'balrog', 'barbed devil', 'bone devil', 'djinni', 'erinys', 'hezrou', 'horned devil', 'ice devil', 'incubus', 'marilith', 'nalfeshnee', 'pit fiend', 'sandestin', 'succubus', 'vrock', 'water demon'],
  "'" => ['clay golem', 'flesh golem', 'glass golem', 'gold golem', 'iron golem', 'leather golem', 'paper golem', 'rope golem', 'stone golem', 'straw golem', 'wood golem'],
  ':' => ['baby crocodile', 'chameleon', 'crocodile', 'gecko', 'iguana', 'lizard', 'newt', 'salamander'],
  ';' => ['electric eel', 'giant eel', 'jellyfish', 'kraken', 'piranha', 'shark'],
  '@' => ['Arch Priest', 'Ashikaga Takauji', 'Croesus', 'Dark One', 'Elvenking', 'Grand Master', 'Green-elf', 'Grey-elf', 'Hippocrates', 'King Arthur', 'Lord Carnarvon', 'Lord Sato', 'Master Assassin', 'Master Kaen', 'Master of Thieves', 'Medusa', 'Neferet the Green', 'Norn', 'Oracle', 'Orion', 'Pelias', 'Shaman Karnov', 'Thoth Amon', 'Twoflower', 'Wizard of Yendor', 'Woodland-elf', 'abbot', 'acolyte', 'aligned priest', 'apprentice', 'apprentice', 'archeologist', 'attendant', 'barbarian', 'captain', 'caveman', 'cavewoman', 'chieftain', 'doppelganger', 'elf', 'elf-lord', 'guard', 'guide', 'healer', 'high priest', 'human', 'hunter', 'knight', 'lieutenant', 'monk', 'neanderthal', 'ninja', 'nurse', 'page', 'priest', 'priestess', 'prisoner', 'ranger', 'rogue', 'roshi', 'samurai', 'sergeant', 'shopkeeper', 'soldier', 'student', 'thug', 'tourist', 'valkyrie', 'warrior', 'watch captain', 'watchman', 'wizard'],
  'A' => ['Aleax', 'Angel', 'Archon', 'couatl', 'ki-rin'],
  'B' => ['bat', 'giant bat', 'raven', 'vampire bat'],
  'C' => ['forest centaur', 'mountain centaur', 'plains centaur'],
  'D' => ['Chromatic Dragon', 'Ixoth', 'baby black dragon', 'baby blue dragon', 'baby gray dragon', 'baby green dragon', 'baby orange dragon', 'baby red dragon', 'baby silver dragon', 'baby white dragon', 'baby yellow dragon', 'black dragon', 'blue dragon', 'gray dragon', 'green dragon', 'orange dragon', 'red dragon', 'silver dragon', 'white dragon', 'yellow dragon'],
  'E' => ['air elemental', 'earth elemental', 'fire elemental', 'stalker', 'water elemental'],
  'F' => ['brown mold', 'green mold', 'lichen', 'red mold', 'shrieker', 'violet fungus', 'yellow mold'],
  'G' => ['gnome', 'gnome king', 'gnome lord', 'gnomish wizard'],
  'H' => ['Cyclops', 'Lord Surtur', 'ettin', 'fire giant', 'frost giant', 'giant', 'hill giant', 'minotaur', 'stone giant', 'storm giant', 'titan'],
  'I' => ['invisible monster'],
  'J' => ['jabberwock'],
  'K' => ['Keystone Kop', 'Kop Kaptain', 'Kop Lieutenant', 'Kop Sergeant'],
  'L' => ['arch-lich', 'demilich', 'lich', 'master lich'],
  'M' => ['dwarf mummy', 'elf mummy', 'ettin mummy', 'giant mummy', 'gnome mummy', 'human mummy', 'kobold mummy', 'orc mummy'],
  'N' => ['black naga', 'black naga hatchling', 'golden naga', 'golden naga hatchling', 'guardian naga', 'guardian naga hatchling', 'red naga', 'red naga hatchling'],
  'O' => ['ogre', 'ogre king', 'ogre lord'],
  'P' => ['black pudding', 'brown pudding', 'gray ooze', 'green slime'],
  'Q' => ['quantum mechanic'],
  'R' => ['disenchanter', 'rust monster'],
  'S' => ['cobra', 'garter snake', 'pit viper', 'python', 'snake', 'water moccasin'],
  'T' => ['Olog-hai', 'ice troll', 'rock troll', 'troll', 'water troll'],
  'U' => ['umber hulk'],
  'V' => ['Vlad the Impaler', 'vampire', 'vampire lord'],
  'W' => ['Nazgul', 'barrow wight', 'wraith'],
  'X' => ['xorn'],
  'Y' => ['ape', 'carnivorous ape', 'monkey', 'owlbear', 'sasquatch', 'yeti'],
  'Z' => ['dwarf zombie', 'elf zombie', 'ettin zombie', 'ghoul', 'giant zombie', 'gnome zombie', 'human zombie', 'kobold zombie', 'orc zombie', 'skeleton'],
  'a' => ['fire ant', 'giant ant', 'giant beetle', 'killer bee', 'queen bee', 'soldier ant'],
  'b' => ['acid blob', 'gelatinous cube', 'quivering blob'],
  'c' => ['chickatrice', 'cockatrice', 'pyrolisk'],
  'd' => ['coyote', 'dingo', 'dog', 'fox', 'hell hound', 'hell hound pup', 'jackal', 'large dog', 'little dog', 'warg', 'winter wolf', 'winter wolf cub', 'wolf'],
  'e' => ['flaming sphere', 'floating eye', 'freezing sphere', 'gas spore', 'shocking sphere'],
  'f' => ['housecat', 'jaguar', 'kitten', 'large cat', 'lynx', 'panther', 'tiger'],
  'g' => ['gargoyle', 'gremlin', 'winged gargoyle'],
  'h' => ['bugbear', 'dwarf', 'dwarf king', 'dwarf lord', 'hobbit', 'master mind flayer', 'mind flayer'],
  'i' => ['homunculus', 'imp', 'lemure', 'manes', 'quasit', 'tengu'],
  'j' => ['blue jelly', 'ochre jelly', 'spotted jelly'],
  'k' => ['kobold', 'kobold lord', 'kobold shaman', 'large kobold'],
  'l' => ['leprechaun'],
  'm' => ['giant mimic', 'large mimic', 'small mimic'],
  'n' => ['mountain nymph', 'water nymph', 'wood nymph'],
  'o' => ['Mordor orc', 'Uruk-hai', 'goblin', 'hill orc', 'hobgoblin', 'orc', 'orc shaman', 'orc-captain'],
  'p' => ['glass piercer', 'iron piercer', 'rock piercer'],
  'q' => ['baluchitherium', 'leocrotta', 'mastodon', 'mumak', 'rothe', 'titanothere', 'wumpus'],
  'r' => ['giant rat', 'rabid rat', 'rock mole', 'sewer rat', 'woodchuck'],
  's' => ['Scorpius', 'cave spider', 'centipede', 'giant spider', 'scorpion'],
  't' => ['lurker above', 'trapper'],
  'u' => ['black unicorn', 'gray unicorn', 'horse', 'pony', 'warorse', 'white unicorn'],
  'v' => ['dust vortex', 'energy vortex', 'fire vortex', 'fog cloud', 'ice vortex', 'steam vortex'],
  'w' => ['baby long worm', 'baby purple worm', 'long worm', 'purple worm'],
  'x' => ['grid bug', 'xan'],
  'y' => ['black light', 'yellow light'],
  'z' => ['zruty'],
);

sub help {
    return "Converts the characters of the argument into monster names";
}

sub run {
    my $self = shift;
    my $args = shift;

    my @chars = split //, $args->{args};

    my $output;
    foreach (@chars) {
        if (my @m = @{ $monster_letters{$_} || []}) {
            $output .= $m[int rand @m] . " ";
        }
    }
    return $output ? $output : "Not a valid monster-string";
}

1;
