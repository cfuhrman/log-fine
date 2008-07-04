#!perl -T

#
# $Id$
#

use Test::More tests => 76;

use Data::Dumper;
use Log::Fine qw( :macros :masks );
use Log::Fine::Handle;
use Log::Fine::Handle::String;

{

        # Log masks are derived from Sys::Syslog module
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

        # validate different mask combinations
        foreach my $i (keys %{$masks}) {

                # check to make sure masks line up properly
                ok(2 << eval "$i" == $masks->{$i});

                # set the level as appropriate
                $handle->{mask} = $masks->{$i};

                # perform some other tests
                foreach my $j (keys %{$masks}) {
                        $handle->{mask} |= $masks->{$j};
                        ok($handle->isLoggable(eval "$i"));
                }
        }
}
