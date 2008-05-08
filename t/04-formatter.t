#!perl -T

#
# $Id$
#

use Test::Simple tests => 7;

use Log::Fine;
use Log::Fine::Formatter;
use Log::Fine::Formatter::Basic;
use Log::Fine::Formatter::Detailed;

{

        # create a basic formatter
        my $basic = Log::Fine::Formatter::Basic->new();

        ok(ref $basic                 eq "Log::Fine::Formatter::Basic");
        ok($basic->{timestamp_format} eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT);

        # format a message
        my $msg = "Stop by this disaster town";
        my $log0 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log0 =~ /^\[.*?\] \w+ $msg/);

        # now create a detailed formatter
        my $detailed = Log::Fine::Formatter::Detailed->new();

        ok(ref $detailed                 eq "Log::Fine::Formatter::Detailed");
        ok($detailed->{timestamp_format} eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT);

        # format a message
        my $log1 = $detailed->format(INFO, $msg, 1);

        ok($log1 =~ /^\[.*?\] \w+ \(.*?\) $msg/);

        my $log2 = myfunc($detailed, $msg);

        ok($log2 =~ /^\[.*?\] \w+ \(.*?\:\d+\) $msg/);

}

# this subroutine is for testing the detailed formatter

sub myfunc
{

        my $formatter = shift;
        my $msg       = shift;

        return $formatter->format(INFO, $msg, 1);

}
