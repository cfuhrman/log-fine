#!perl -T

#
# $Id$
#

use Test::More tests => 20;

use Log::Fine::Levels;

{

        my $levels = Log::Fine::Levels->new();

        # levels should be a *::Syslog object
        isa_ok($levels, "Log::Fine::Levels::Syslog");
        can_ok($levels, "new");

        my @levels = $levels->logLevels();
        my @masks  = $levels->logMasks();
        ok(scalar @levels > 0);
        ok(scalar @masks > 0);

        for (my $i = 0; $i < scalar @levels; $i++) {
                ok($i == $levels->levelToValue($levels[$i]));
        }

        ok($levels->MASK_MAP($_) =~ /\d/) foreach (@masks);

}
