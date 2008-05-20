#!perl -T

#
# $Id$
#

use Test::Simple tests => 6;

use Log::Fine;
use Log::Fine::Handle::Console;

{
        my $msg =
                "This output is expected as part of the test.  Please ignore.";

        # get a logger
        my $log = Log::Fine->getLogger("handleconsole0");

        ok(ref $log eq "Log::Fine::Logger");

        # add a handle.  Note we use the default formatter.
        my $handle = Log::Fine::Handle::Console->new(use_stderr => 1);

        # do some validation
        ok($handle->isa("Log::Fine::Handle"));

        # these should be set to their default values
        ok($handle->{mask} == Log::Fine::Handle->DEFAULT_LOGMASK);
        ok($handle->{level} == DEBG);
        ok($handle->{formatter}->isa("Log::Fine::Formatter::Basic"));

        # Console-specific attributes
        ok($handle->{use_stderr});

        # write a test message
        $handle->msgWrite(INFO, "\n\n$msg\n\n", 1);
}
