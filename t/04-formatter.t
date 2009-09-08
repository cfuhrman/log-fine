#!perl -T

#
# $Id$
#

use Test::Simple tests => 11;

use Log::Fine;
use Log::Fine::Formatter;
use Log::Fine::Formatter::Basic;
use Log::Fine::Formatter::Detailed;

{

        # create a basic formatter
        my $basic = Log::Fine::Formatter::Basic->new();

        ok(ref $basic eq "Log::Fine::Formatter::Basic");
        ok($basic->getTimestamp() eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT);

        # See if our levels are properly defined
        ok($basic->can("getLevels"));

        # variable for levels object
        my $lvls = $basic->getLevels();

        ok($lvls and $lvls->isa("Log::Fine::Levels"));

        # format a message
        my $msg = "Stop by this disaster town";
        my $log0 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log0 =~ /^\[.*?\] \w+ $msg/);

        # make sure we can change the timestamp format
        $basic->setTimestamp("%Y%m%d%H%M%S");

        my $log1 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log1 =~ /^\[\d{14,14}\] \w+ $msg/);

        # now create a detailed formatter
        my $detailed = Log::Fine::Formatter::Detailed->new();

        ok(ref $detailed eq "Log::Fine::Formatter::Detailed");
        ok($detailed->getTimestamp() eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT);

        # format a message
        my $log2 = $detailed->format(INFO, $msg, 1);

        ok($log2 =~ /^\[.*?\] \w+ \(.*?\) $msg/);

        my $log3 = myfunc($detailed, $msg);

        ok($log3 =~ /^\[.*?\] \w+ \(.*?\:\d+\) $msg/);

        my $log4 = $detailed->testFormat(INFO, $msg);

        ok($log4 =~
/^\[.*?\] \w+ \(Log\:\:Fine\:\:Formatter\:\:Detailed\:\:format\(\)\:\d+\) $msg/
        );

}

# this subroutine is for testing the detailed formatter

sub myfunc
{

        my $formatter = shift;
        my $msg       = shift;

        return $formatter->format(INFO, $msg, 1);

}
