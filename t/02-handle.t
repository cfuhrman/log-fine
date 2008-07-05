#!perl -T

#
# $Id$
#

use Test::More tests => 132;

use Data::Dumper;
use Log::Fine qw( :macros :masks );
use Log::Fine::Handle;
use Log::Fine::Handle::String;

{

        # set up masks
        my $masks = {
                      EMER => LOGMASK_EMERG,
                      ALRT => LOGMASK_ALERT,
                      CRIT => LOGMASK_CRIT,
                      ERR  => LOGMASK_ERR,
                      WARN => LOGMASK_WARNING,
                      NOTI => LOGMASK_NOTICE,
                      INFO => LOGMASK_INFO,
                      DEBG => LOGMASK_DEBUG
        };

        # first we create a handle
        my $handle = Log::Fine::Handle::String->new();

        # validate handle
        ok($handle->isa("Log::Fine::Handle"));

        # validate default attributes
        ok($handle->{mask} == Log::Fine::Handle->DEFAULT_LOGMASK);
        ok($handle->{formatter}->isa("Log::Fine::Formatter"));
        ok(ref $handle->{formatter} eq "Log::Fine::Formatter::Basic");

        # we need two handles for testing mask combinations
        my $hand1 = Log::Fine::Handle::String->new();
        my $hand2 = Log::Fine::Handle::String->new();

        # validate different mask combinations
        foreach my $i (keys %{$masks}) {

                # check to make sure masks line up properly
                ok(2 << eval "$i" == $masks->{$i});

                # set the level as appropriate
                $hand1->{mask} = $masks->{$i};
                $hand2->{mask} = 0;

                # perform some other tests
                foreach my $j (keys %{$masks}) {

                        # test to see if we're properly loggable
                        $hand1->{mask} |= $masks->{$j};
                        ok($hand1->isLoggable(eval "$i"));

                        # skip if $i is $j
                        next if ($i eq $j);

                        # test to make sure we don't log when our mask
                        # isn't set as appropriate
                        $hand2->{mask} |= $masks->{$j};
                        ok(not $hand2->isLoggable(eval "$i"));

                }
        }
}
