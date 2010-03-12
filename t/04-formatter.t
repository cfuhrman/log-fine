#!perl -T

#
# $Id$
#

use Test::More tests => 51;

use Log::Fine;
use Log::Fine::Formatter;
use Log::Fine::Formatter::Basic;
use Log::Fine::Formatter::Detailed;
use Log::Fine::Formatter::Syslog;
use Log::Fine::Levels::Syslog;

use locale;
use POSIX qw( locale_h setlocale strftime );

# constant for containing locales
use constant LOCALES => [ "C",           "ar_AE.UTF-8",
                          "cs_CZ.UTF-8", "de_DE.UTF-8",
                          "en_US.UTF-8", "es_ES.UTF-8",
                          "fr_FR.UTF-8", "hi_IN.UTF-8",
                          "ja_JP.UTF-8", "ru_RU.UTF-8",
                          "ko_KR.UTF-8", "pt_BR.UTF-8",
                          "zh_TW.UTF-8",
];          # LOCALES

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

        my $log3 = myfunc($detailed, $msg);

        ok($log3 =~ /^\[.*?\] \w+ \(.*?\:\d+\) $msg/);

        my $log4 = $detailed->testFormat(INFO, $msg);

        ok($log4 =~
/^\[.*?\] \w+ \(Log\:\:Fine\:\:Formatter\:\:Detailed\:\:format\(\)\:\d+\) $msg/
        );

        # Log::Fine::Formatter::Syslog testing.  Note we test multiple
        # locales
        my $locales    = LOCALES;
        my $old_locale = setlocale(LC_ALL);

        foreach my $locale (@{$locales}) {

                # Set locale as appropriate
                setlocale(LC_ALL, $locale);

                # Instantiate syslog formatter object and set
                # timestamp as appropriate
                my $syslog = Log::Fine::Formatter::Syslog->new();
                ok(ref $syslog eq "Log::Fine::Formatter::Syslog");
                ok($syslog->timeStamp() eq
                    Log::Fine::Formatter::Syslog->LOG_TIMESTAMP_FORMAT);

                # Create formatted message
                my $log5 = $syslog->format(INFO, $msg, 1);

                print STDERR "\n$locale:$log5\n";

                ok($log5 =~
/^([ 1]\d\S+|[^ ]+) [ 1-3][0-9] \d{2}:\d{2}:\d{2} [0-9a-zA-Z\-]+ .*?\[\d+\]: $msg/
                );

                # reset locale
                setlocale(LC_ALL, "");

        }

        # reset locale to default
        setlocale(LC_ALL, $old_locale);

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
