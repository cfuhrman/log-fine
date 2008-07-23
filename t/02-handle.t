#!perl -T

#
# $Id$
#

use Test::Simple tests => 96;

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

        # we need three handles for testing mask combinations
        my $hand1 = Log::Fine::Handle::String->new();
        my $hand2 = Log::Fine::Handle::String->new();
        my $hand3 = Log::Fine::Handle::String->new();

        # validate different mask combinations
        my @keys = keys %{$masks};

        for (my $i = 0; $i < scalar @keys; $i++) {

                # check to make sure masks line up properly
                ok(2 << eval "$keys[$i]" == $masks->{ $keys[$i] });

                # set the level as appropriate
                $hand1->{mask} = $masks->{ $keys[$i] };
                $hand3->{mask} = 0;

                # now iterate through subsequent combinations
                for (my $j = $i + 1; $j < scalar @keys; $j++) {

                        # now test to see if we're properly loggable
                        $hand1->{mask} |= $masks->{ $keys[$j] };
                        $hand2->{mask} =
                            $masks->{ $keys[$i] } | $masks->{ $keys[$j] };

                        ok($hand1->isLoggable(eval "$keys[$i]"));
                        ok($hand2->isLoggable(eval "$keys[$i]"));

                        # test to make sure we don't log when our mask
                        # isn't set as appropriate
                        $hand3->{mask} |= $masks->{ $keys[$j] };
                        ok(not $hand3->isLoggable(eval "$keys[$i]"));

                }

        }

}
