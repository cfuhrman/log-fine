#!perl -T

#
# $Id$
#

use Test::Simple tests => 25;

use Data::Dumper;
use Log::Fine::Levels;

# Log Levels
use constant LOG_LEVELS => [qw( EMER ALRT CRIT ERR WARN NOTI INFO DEBG )];

{

        # create a basic level package
        my $lfl = Log::Fine::Levels->new();

        # validate object
        ok($lfl->isa("Log::Fine::Levels"));

        # create a ref to our levels
        my $lvls = LOG_LEVELS;

        # Grab keys
        my @keys = sort $lfl->getLevels();

        # make sure levels are the same
        ok($_ eq shift @keys) foreach (sort @{$lvls});

        # Test out level values
        for (my $i = 0; $i < scalar @{$lvls}; $i++) {
                my $lvl = $lfl->getLvlFromVal($i);
                my $val = $lfl->$lvl;
                ok($val == $i);
                ok($val == $lfl->getValFromLvl($lvl));
        }

}

