#!perl -T

#
# $Id$
#

use Test::More tests => 11;

use Log::Fine;
use Log::Fine::Handle::String;
use Log::Fine::Levels::Syslog;
use Log::Fine::Logger;

{

        # Create a Log::Fine object and a new logger
        my $log = Log::Fine->new(no_croak => 1);

        # first we create a logger object
        my $logger = Log::Fine->logger("logger0");

        ok($logger->isa("Log::Fine::Logger"));

        # create a handle for the logger
        my $handle = Log::Fine::Handle::String->new();

        # validate handle
        ok($handle->isa("Log::Fine::Handle"));

        # now register the handle
        my $result = $logger->registerHandle($handle);

        # validate result (should be a Logger)
        ok($result->isa("Log::Fine::Logger"));

        # Log something (won't do anything)
        my $loggerrc = $logger->log(DEBG, "This is a test message");

        # just make sure the object returned is a Logger object
        ok($loggerrc->isa("Log::Fine::Logger"));

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

    SKIP: {

                eval "use Test::Output 0.10";

                skip
"Test::Output 0.10 or above required for testing Console output",
                    3
                    if $@;

                # Create a valid logger for testing
                my $badlog = $log->logger("badlogger");

                $badlog->{no_croak} = 1;

                stderr_like(
                        sub {
                                my $foo = Log::Fine::Logger->new(no_croak => 1);
                        },
                        qr/Loggers need names/,
                        'logger(): Invoke without name'
                );
                stderr_like(
                        sub {
                                $badlog->log(INFO,
"It was lightning headaches and sweet avalance"
                                );
                        },
                        qr/No handles defined/,
                        'log(): Invoke without handle'
                );
                stderr_like(sub { $badlog->registerHandle() },
                            qr/must be a valid/,
                            'registerHandle(): Invoke without handle');

        }

}
