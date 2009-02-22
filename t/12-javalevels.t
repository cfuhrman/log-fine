#!perl -T

#
# $Id$
#

use Test::Simple tests => 22;

use Data::Dumper;
use Log::Fine::Levels;

{

        # Set up levels
        my $javalevels = {
                           "SEVERE"  => 0,
                           "WARNING" => 1,
                           "INFO"    => 2,
                           "CONFIG"  => 3,
                           "FINE"    => 4,
                           "FINER"   => 5,
                           "FINEST"  => 6
        };

        my @javakeys = keys %{$javalevels};
        my $lfl = Log::Fine::Levels->new(levels => $javalevels);

        # validate object
        ok($lfl->isa("Log::Fine::Levels"));

        # create a ref to our levels
        my $lvls = \@javakeys;

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

