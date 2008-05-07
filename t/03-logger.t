#!perl -T

#
# $Id: 03-logger.t 45 2008-05-07 22:06:40Z cfuhrman $
#

use Test::Simple tests => 4;

use Log::BSDLog;
use Log::BSDLog::Handle::Test;
use Log::BSDLog::Logger;

{

    # first we create a logger object
    my $log = Log::BSDLog->getLogger("logger0");

    ok($log->isa("Log::BSDLog::Logger"));

    # create a handle for the logger
    my $handle = Log::BSDLog::Handle::Test->new();

    # validate handle
    ok($handle->isa("Log::BSDLog::Handle"));

    # now register the handle
    my $result = $log->registerHandle($handle);

    # validate result (should be a Logger)
    ok($result->isa("Log::BSDLog::Logger"));

    # Log something (won't do anything)
    my $logrc = $log->log(DEBG, "This is a test message");

    # just make sure the object returned is a Logger object
    ok($logrc->isa("Log::BSDLog::Logger"));

}
