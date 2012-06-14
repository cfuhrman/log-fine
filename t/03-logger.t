#!perl -T

#
# $Id$
#

use Test::More tests => 22;

use Log::Fine;
use Log::Fine::Handle::String;
use Log::Fine::Levels::Syslog;
use Log::Fine::Logger;

{

        # Create a Log::Fine object and a new logger
        my $log = Log::Fine->new(no_croak => 1);

        isa_ok($log, "Log::Fine");
        can_ok($log, "name");

        # all objects should have names
        ok($log->name() =~ /\w\d+$/);

        # first we create a logger object
        my $logger = Log::Fine->logger("logger0");

        isa_ok($logger, "Log::Fine::Logger");
        can_ok($logger, "name");
        can_ok($logger, "registerHandle");

        ok($logger->name() =~ /\w\d+$/);

        # create a handle for the logger and validate
        my $handle = Log::Fine::Handle::String->new();

        isa_ok($handle, "Log::Fine::Handle");
        can_ok($handle, "name");
        ok($handle->name() =~ /\w\d+$/);

        # now register the handle and validate
        my $result = $logger->registerHandle($handle);

        isa_ok($result, "Log::Fine::Logger");
        can_ok($result, "name");
        ok($result->name() =~ /\w\d+$/);

        # Log something (won't do anything)
        my $loggerrc = $logger->log(DEBG, "This is a test message");

        # just make sure the object returned is a Logger object
        isa_ok($loggerrc, "Log::Fine::Logger");

        # make sure skip is set to our default
        my $num = $logger->skip();
        ok($num == Log::Fine::Logger->LOG_SKIP_DEFAULT);

        # set the skip level to 5
        $logger->skip(5);

        # check to see if it's okay
        $num = $logger->skip();
        ok($num == 5);

        # okay, now increment and decrement
        ok($logger->incrSkip() == 6);
        ok($logger->decrSkip() == 5);

        # Create an invalid logger for testing
        my $badlog = $log->logger("badlogger");

        # Call logger without a name
        eval { my $foo = Log::Fine::Logger->new(); };

        ok($@ =~ /Loggers need names/);

        # Test for no handles defined
        eval {
                $badlog->log(INFO,
                             "It was lightning headaches and sweet avalanche");
        };

        ok($@ =~ /No handles defined/);

        # Test bad call to registerHandle()
        eval { $badlog->registerHandle(); };

        ok($@ =~ /^first argument must either be a valid Log/);

        # Test bad array to registerHandle()
        eval { $badlog->registerHandle([ $handle, $logger ]); };

        ok($@ =~ /^Array ref must contain valid Log/);

}
