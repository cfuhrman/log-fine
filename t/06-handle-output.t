#!perl -T

#
# $Id$
#

use Test::Simple tests => 6;

use Log::BSDLog;
use Log::BSDLog::Handle::Output;

{

        my $msg =
                "This output is expected as part of the test.  Please ignore.";

        # get a logger
        my $log = Log::BSDLog->getLogger("handleoutput0");

        ok(ref $log eq "Log::BSDLog::Logger");

        # add a handle.  Note we use the default formatter.
        my $handle = Log::BSDLog::Handle::Output->new({ use_stderr => 1, });

        # do some validation
        ok($handle->isa("Log::BSDLog::Handle"));

        # these should be set to their default values
        ok($handle->{mask} == Log::BSDLog::Handle->DEFAULT_LOGMASK);
        ok($handle->{level} == DEBG);
        ok($handle->{formatter}->isa("Log::BSDLog::Formatter::Basic"));

        # Output-specific attributes
        ok($handle->{use_stderr});

        # write a test message
        $handle->msgWrite(INFO, "\n\n$msg\n\n", 1);
}
