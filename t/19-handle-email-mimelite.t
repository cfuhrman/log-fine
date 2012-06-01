#!perl -T

#
# $Id$
#

use Log::Fine;
use Log::Fine::Formatter::Template;
use Log::Fine::Levels::Syslog qw( :macros :masks );
use Test::More;

{

        # See if we have Mail::RFC822::Address installed
        eval "require Mail::RFC822::Address";

        if ($@) {
                plan skip_all => "Mail::RFC822::Address is not installed";
        } else {

                # See if we have MIME::Lite installed
                eval "require MIME::Lite";

                if ($@) {
                        plan skip_all => "MIME::Lite is not installed";
                } else {
                        plan tests => 5;
                }

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
This is a test of Log::Fine::Handle::Email.  The following message was
delivered at %%TIME%%:

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

}
