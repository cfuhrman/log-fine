#!perl -T

#
# $Id$
#

use Test::Simple tests => 8;

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

        # make sure skip is set to our default
        my $num = $log->getSkip();
        ok($num == Log::Fine::Logger->LOG_SKIP_DEFAULT);

        # set the skip level to 5
        $log->setSkip(5);

        # check to see if it's okay
        $num = $log->getSkip();
        ok($num == 5);

        # okay, now increment and decrement
        ok($log->incrSkip() == 6);
        ok($log->decrSkip() == 5);

}
