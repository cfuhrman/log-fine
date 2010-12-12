#!perl -T

#
# $Id$
#

use Test::More tests => 15;

use Log::Fine;
use Log::Fine::Formatter;
use Log::Fine::Formatter::Basic;
use Log::Fine::Formatter::Detailed;
use Log::Fine::Formatter::Syslog;
use Log::Fine::Levels::Syslog;

{

        # create a basic formatter
        my $basic = Log::Fine::Formatter::Basic->new();

        ok(ref $basic eq "Log::Fine::Formatter::Basic");
        ok($basic->timeStamp() eq Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT);

        # See if our levels are properly defined
        ok($basic->can("levelMap"));

        # variable for levels object
        my $lvls = $basic->levelMap();

        ok($lvls and $lvls->isa("Log::Fine::Levels"));

        # format a message
        my $msg = "Stop by this disaster town";
        my $log0 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log0 =~ /^\[.*?\] \w+ $msg/);

        # make sure we can change the timestamp format
        $basic->timeStamp("%Y%m%d%H%M%S");

        my $log1 = $basic->format(INFO, $msg, 1);

        # see if the format is correct
        ok($log1 =~ /^\[\d{14,14}\] \w+ $msg/);

        # now create a detailed formatter
        my $detailed = Log::Fine::Formatter::Detailed->new();

        ok(ref $detailed eq "Log::Fine::Formatter::Detailed");
        ok($detailed->timeStamp() eq
            Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT);

        # format a message
        my $log2 = $detailed->format(INFO, $msg, 1);

        ok($log2 =~ /^\[.*?\] \w+ \(.*?\) $msg/);

        #print STDERR "\n$log2\n";

        my $log3 = myfunc($detailed, $msg);

        ok($log3 =~ /^\[.*?\] \w+ \(.*?\:\d+\) $msg/);

        #print STDERR "\n$log3\n";

        my $log4 = $detailed->testFormat(INFO, $msg);

        ok($log4 =~
/^\[.*?\] \w+ \(Log\:\:Fine\:\:Formatter\:\:testFormat\(\)\:\d+\) $msg/
        );

        #print STDERR "\n$log4\n";

        # now create a syslog formatter
        my $syslog = Log::Fine::Formatter::Syslog->new();

        ok(ref $syslog eq "Log::Fine::Formatter::Syslog");
        ok($syslog->timeStamp() eq
            Log::Fine::Formatter::Syslog->LOG_TIMESTAMP_FORMAT);

        # format a message
        my $log5 = $syslog->format(INFO, $msg, 1);

        # Uncomment to deliberately fail the next test
        # $log5 = "BARFME $log5";

        # Note: This regex is designed to catch non-English month
        # representations found in other locales.  This has been
        # tested against:
        #
        #  * ar_AE.utf8
        #  * cs_CZ.utf8
        #  * de_DE.utf8
        #  * es_ES.utf8
        #  * hi_IN.utf8
        #  * ja_JP.utf8
        #  * ko_KR.utf8
        #  * zh_TW.UTF-8
        #
        # This list is by no means comprehensive.  Also, since there
        # is a wide variety of different interpretations of various
        # locales on different operating systems, handle our own error
        # reporting.

        if ($log5 =~
/^([ 1]\d\S+|[^ ]+) [ 0-3][0-9] \d{2}:\d{2}:\d{2} [0-9a-zA-Z\-]+ .*?\[\d+\]: $msg/
            ) {
                ok(1);
        } else {
                print STDERR "\n----------------------------------------\n";
                print STDERR "Test failed on the following line:\n\n";
                print STDERR "${log5}";
                print STDERR "----------------------------------------\n";
                ok(0);
        }

    SKIP: {

                eval "use Test::Output";

                skip
"Test::Output 0.10 or above required for testing Console output",
                    1
                    if $@;

                my $badformatter = Log::Fine::Formatter->new(no_croak => 1);

                stderr_like(sub { $badformatter->format(INFO, $msg, 1) },
                            qr /direct call to abstract method/,
                            'Test Direct Abstract Call'
                );

        }

}

# this subroutine is for testing the detailed formatter

sub myfunc
{

        my $formatter = shift;
        my $msg       = shift;

        return $formatter->format(INFO, $msg, 1);

}
