#!perl -T

#
# $Id$
#

use Test::More tests => 20;

use Log::Fine;
use Log::Fine::Formatter::Template;
use Log::Fine::Levels::Syslog;

use POSIX qw( strftime );
use Sys::Hostname;

{

        # Set up some variables
        my $hostname = hostname();
        my $msg      = "Stop by this disaster town";

        # level
        my $log_level =
            Log::Fine::Formatter::Template->new(template         => "%%LEVEL%%",
                                                timestamp_format => "%Y%m%d");
        ok($log_level->isa("Log::Fine::Formatter::Template"));

        # msg
        my $log_msg =
            Log::Fine::Formatter::Template->new(template         => "%%MSG%%",
                                                timestamp_format => "%Y%m%d");
        ok($log_msg->isa("Log::Fine::Formatter::Template"));

        # package
        my $log_package =
            Log::Fine::Formatter::Template->new(
                                          template => "%%PACKAGE%% %%SUBROUT%%",
                                          timestamp_format => "%Y%m%d");
        ok($log_package->isa("Log::Fine::Formatter::Template"));

        # filename & lineno
        my $log_filename =
            Log::Fine::Formatter::Template->new(
                                          template => "%%FILENAME%%:%%LINENO%%",
                                          timestamp_format => "%Y%m%d");
        ok($log_filename->isa("Log::Fine::Formatter::Template"));

        # short hostname
        my $log_shorthost =
            Log::Fine::Formatter::Template->new(template => "%%HOSTSHORT%%",
                                                timestamp_format => "%Y%m%d");
        ok($log_shorthost->isa("Log::Fine::Formatter::Template"));

        # long hostname
        my $log_longhost =
            Log::Fine::Formatter::Template->new(template => "%%HOSTLONG%%",
                                                timestamp_format => "%Y%m%d");
        ok($log_longhost->isa("Log::Fine::Formatter::Template"));

        # user
        my $log_user =
            Log::Fine::Formatter::Template->new(template         => "%%USER%%",
                                                timestamp_format => "%Y%m%d");
        ok($log_user->isa("Log::Fine::Formatter::Template"));

        # group
        my $log_group =
            Log::Fine::Formatter::Template->new(template         => "%%GROUP%%",
                                                timestamp_format => "%Y%m%d");
        ok($log_group->isa("Log::Fine::Formatter::Template"));

        # time
        my $log_time =
            Log::Fine::Formatter::Template->new(template         => "%%TIME%%",
                                                timestamp_format => "%Y%m");
        ok($log_time->isa("Log::Fine::Formatter::Template"));

        # Note we test time first to avoid a possible race condition
        # that would occur at the end of every month.

        # validate
        ok($log_time->format(INFO, $msg, 1) eq
            strftime("%Y%m", localtime(time)));
        ok($log_level->format(INFO, $msg, 1) eq "INFO");
        ok($log_msg->format(INFO, $msg, 1) eq $msg);
        ok(myfunc($log_package, $msg) =~ /myfunc/);
        ok($log_filename->format(INFO, $msg, 1) =~ /\w+\:\d+/);
        ok($log_longhost->format(INFO, $msg, 1) =~ /$hostname/);
        ok($log_shorthost->format(INFO, $msg, 1) =~ /\w/);

    SKIP: {

                skip
"Cannot accurately test user and group placeholders under MSWin32",
                    2
                    if ($^O eq "MSWin32");

                ok($log_user->format(INFO, $msg, 1) eq getpwuid($<));
                ok($log_group->format(INFO, $msg, 1) eq getgrgid($());

        }

        # Now test a combination string for good measure
        my $log_basic =
            Log::Fine::Formatter::Template->new(
                  template         => "[%%time%%] %%level%% %%msg%%",
                  timestamp_format => Log::Fine::Formatter->LOG_TIMESTAMP_FORMAT
            );
        ok($log_basic->isa("Log::Fine::Formatter::Template"));
        ok($log_basic->format(INFO, $msg, 1) =~ /^\[.*?\] \w+ $msg/);

}

# this subroutine is for testing the detailed formatter

sub myfunc
{

        my $formatter = shift;
        my $msg       = shift;

        return $formatter->format(INFO, $msg, 1);

}
