#!perl -T

#
# $Id$
#

use Test::More tests => 56;

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

        # make sure levels are in ascending order by val;
        my $val = 0;
        my $map = Log::Fine::Levels::Syslog::LVLTOVAL_MAP;
        foreach my $level (@levels) {
                next if $map->{$level} == 0;
                ok($map->{$level} > $val);
                $val = $map->{$level};
        }

        # make sure masks are ascending order by val
        $val = 0;
        $map = Log::Fine::Levels::Syslog::MASK_MAP;
        foreach my $mask (@masks) {
                next if $map->{$mask} == 0;
                ok($map->{$mask} > $val);
                $val = $map->{$mask};
        }

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
