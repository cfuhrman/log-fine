#!perl -T

#
# $Id$
#

use Test::More;

use Log::Fine;
use Log::Fine::Handle::Console;

# set message
my $msg =
"Stop by this disaster town, we put our eyes to the sun and say 'Hello!'";

# add a handle.  Note we use the default formatter.
my $handle = Log::Fine::Handle::Console->new();

{

        # see if we have Test::Output installed
        eval "use Test::Output 0.10";

        if ($@) {
                plan skip_all =>
"Test::Output 0.10 or above required for testing Console output"
                        if $@;
        } else {
                plan tests => 9;
        }

        # get a logger
        my $log = Log::Fine->getLogger("handleconsole0");

        ok(ref $log eq "Log::Fine::Logger");

        # do some validation
        ok($handle->isa("Log::Fine::Handle"));

        # these should be set to their default values
        ok($handle->{mask} == Log::Fine::Handle->DEFAULT_LOGMASK);
        ok($handle->{level} == DEBG);
        ok($handle->{formatter}->isa("Log::Fine::Formatter::Basic"));

        # Console-specific attributes
        ok(!$handle->{use_stderr});
        stdout_like(\&writer, qr/$msg/, 'Test STDOUT');

        # test STDOUT
        $handle->{use_stderr} = 1;

        ok($handle->{use_stderr});
        stderr_like(\&writer, qr/$msg/, 'Test STDERR');

}

sub writer
{
        $handle->msgWrite(INFO, $msg);
}
