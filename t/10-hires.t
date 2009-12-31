#!perl -T

#
# $Id$
#

use Test::More;

use Log::Fine;
use Log::Fine::Formatter;
use Log::Fine::Formatter::Basic;
use Log::Fine::Formatter::Detailed;
use Log::Fine::Levels::Syslog;

{

        # See if we have Time::HiRes installed
        eval "use Time::HiRes";

        if ($@) {
                plan skip_all =>
"Time::HiRes is not installed.  High precision logging not possible";
        } else {
                plan tests => 8;
        }

        # create a basic formatter
        my $basic = Log::Fine::Formatter::Basic->new(hires => 1);

        ok(ref $basic          eq "Log::Fine::Formatter::Basic");
        ok($basic->timeStamp() eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT_PRECISE);

        # format a message
        my $msg = "Stop by this disaster town";
        my $log0 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log0 =~ /^\[.*?\] \w+ $msg/);

        # make sure we can change the timestamp format
        $basic->timeStamp("%Y%m%d%H%M%S.%%millis%%");

        my $log1 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log1 =~ /^\[\d{14}\.\d+\] \w+ $msg/);

        # now create a detailed formatter
        my $detailed = Log::Fine::Formatter::Detailed->new(hires => 1);

        ok(ref $detailed          eq "Log::Fine::Formatter::Detailed");
        ok($detailed->timeStamp() eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT_PRECISE);

        # format a message
        my $log2 = $detailed->format(INFO, $msg, 1);

        ok($log2 =~ /^\[\d\d\:\d\d\:\d\d\.\d+\] \w+ \(.*?\) $msg/);

        my $log3 = myfunc($detailed, $msg);

        ok($log3 =~ /^\[.*?\] \w+ \(.*?\:\d+\) $msg/);

}

# this subroutine is for testing the detailed formatter

sub myfunc
{

        my $formatter = shift;
        my $msg       = shift;

        return $formatter->format(INFO, $msg, 1);

}
