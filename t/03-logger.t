#!perl -T

#
# $Id$
#

use Test::Simple tests => 4;

use Log::Fine;
use Log::Fine::Handle::Test;
use Log::Fine::Logger;

{

        # first we create a logger object
        my $log = Log::Fine->getLogger("logger0");

        ok($log->isa("Log::Fine::Logger"));

        # create a handle for the logger
        my $handle = Log::Fine::Handle::Test->new();

        # validate handle
        ok($handle->isa("Log::Fine::Handle"));

        # now register the handle
        my $result = $log->registerHandle($handle);

        # validate result (should be a Logger)
        ok($result->isa("Log::Fine::Logger"));

        # Log something (won't do anything)
        my $logrc = $log->log(DEBG, "This is a test message");

        # just make sure the object returned is a Logger object
        ok($logrc->isa("Log::Fine::Logger"));

}
