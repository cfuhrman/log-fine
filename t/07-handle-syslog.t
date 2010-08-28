#!perl -T

use Test::Simple tests => 7;

use File::Basename;

use Log::Fine;
use Log::Fine::Handle::Syslog;
use Log::Fine::Levels::Syslog;

use Sys::Syslog qw( :standard :macros );

{

        my $msg =
            "This is a test message generated by the install of Log::Fine";

        # get a logger
        my $log = Log::Fine->logger("handlesyslog0");

        ok(ref $log eq "Log::Fine::Logger");

        # add a handle.  Note we use the default formatter.
        my $handle = Log::Fine::Handle::Syslog->new();

        # do some validation
        ok($handle->isa("Log::Fine::Handle"));

        # these should be set to their default values
        ok($handle->{mask} == $handle->levelMap()->bitmaskAll());
        ok($handle->{formatter}->isa("Log::Fine::Formatter::Basic"));

        # Syslog-specific attributes
        ok($handle->{ident} eq basename $0);
        ok($handle->{logopts} =~ /pid/);
        ok($handle->{facility} == LOG_LOCAL0);

        # write a test message
        $handle->msgWrite(INFO, $msg, 1);

}
