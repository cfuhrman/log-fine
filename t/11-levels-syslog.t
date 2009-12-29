#!perl -T

#
# $Id$
#

use Test::More tests => 41;

use Log::Fine::Levels::Syslog qw( :macros :masks );

{

        my $levels = Log::Fine::Levels::Syslog->new();

        # levels should be a *::Syslog object
        isa_ok($levels, "Log::Fine::Levels::Syslog");

        # validate methods
        can_ok($levels, $_)
            foreach (
                    qw/ new bitmaskAll levelToValue maskToValue valueToLevel /);

        my @levels = $levels->logLevels();
        my @masks  = $levels->logMasks();

        ok(scalar @levels > 0);
        ok(scalar @masks > 0);

        # variable for holding bitmask
        my $bitmask = 0;

        for (my $i = 0; $i < scalar @levels; $i++) {
                ok($i == $levels->levelToValue($levels[$i]));
                ok(&{ $levels[$i] } eq $i);
                ok(&{ $masks[$i] }  eq $levels->maskToValue($masks[$i]));

                $bitmask |= $levels->maskToValue($masks[$i]);
        }

        ok($bitmask == $levels->bitmaskAll());
        ok($levels->MASK_MAP($_) =~ /\d/) foreach (@masks);

}
