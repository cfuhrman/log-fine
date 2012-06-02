#!perl

#
# $Id$
#

use Log::Fine;
use Log::Fine::Formatter::Template;
use Log::Fine::Levels::Syslog qw( :macros :masks );
use Test::More;

{

        $ENV{ENABLE_AUTHOR_TESTS} = 0
            unless defined $ENV{ENABLE_AUTHOR_TESTS};

        # Check environmental variables
        plan skip_all => "these tests are for testing by the author"
            unless $ENV{ENABLE_AUTHOR_TESTS};
        plan skip_all => "cannot test delivery under MsWin32 or cygwin"
            if (($^O eq "MSWin32") || ($^O eq "cygwin"));

        # See if we have MIME::Lite installed
        eval "require MIME::Lite";

        if ($@) {
                plan skip_all => "MIME::Lite is not installed";
        } else {
                plan tests => 6;
        }

        use_ok("Log::Fine::Handle::Email::MIMELite");

        my $user =
            sprintf('%s@localhost', getlogin() || getpwuid($<) || "nobody");
        my $log = Log::Fine->logger("email0");

        isa_ok($log, "Log::Fine");

        # Create a formatter for subject line
        my $subjfmt =
            Log::Fine::Formatter::Template->new(
                      name     => 'email-subject',
                      template => "%%LEVEL%% : Test of Log::Fine::Handle::Email"
            );

        # Create a formatted msg template
        my $msgtmpl = <<EOF;
This is a test of Log::Fine::Handle::Email::MIMELite using Perl $].
The following message was delivered at %%TIME%%:

--------------------------------------------------------------------
%%MSG%%
--------------------------------------------------------------------

This is only a test.  Thank you for your patience.

/Chris

EOF

        my $bodyfmt =
            Log::Fine::Formatter::Template->new(name     => 'email-body',
                                                template => $msgtmpl);

        isa_ok($subjfmt, "Log::Fine::Formatter::Template");
        isa_ok($bodyfmt, "Log::Fine::Formatter::Template");

        # register an email handle
        my $handle =
            Log::Fine::Handle::Email->new(
                           name => 'email11',
                           mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT,
                           subject_formatter => $subjfmt,
                           body_formatter    => $bodyfmt,
                           header_from       => $user,
                           header_to         => $user,
                           email_handle      => "MIMELite",
            );

        isa_ok($handle, "Log::Fine::Handle::Email::MIMELite");

        # register the handle
        $log->registerHandle($handle);

        # Grab number of messages
        my $msg_t1 =
            ($^O eq "solaris") ? qx! mailx -H | wc -l ! : qx! mail -H | wc -l !;

        $log->log(DEBG, "Debugging $0");
        $log->log(CRIT, "Beware the weeping angels");

        # Give sendmail a chance to deliver
        print STDERR "---- Sleeping for 5 seconds";
        sleep 5;

        my $msg_t2 =
            ($^O eq "solaris") ? qx! mailx -H | wc -l ! : qx! mail -H | wc -l !;

        ok($msg_t2 > $msg_t1);

}
