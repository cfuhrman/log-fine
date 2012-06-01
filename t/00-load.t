#!perl -T

use Test::More tests => 20;

BEGIN {
        use_ok('Log::Fine');
        use_ok('Log::Fine::Formatter');
        use_ok('Log::Fine::Formatter::Basic');
        use_ok('Log::Fine::Formatter::Detailed');
        use_ok('Log::Fine::Formatter::Syslog');
        use_ok('Log::Fine::Formatter::Template');
        use_ok('Log::Fine::Handle');
        use_ok('Log::Fine::Handle::File');
        use_ok('Log::Fine::Handle::File::Timestamp');
        use_ok('Log::Fine::Handle::Console');
        use_ok('Log::Fine::Handle::Syslog');
        use_ok('Log::Fine::Handle::String');
        use_ok('Log::Fine::Levels');
        use_ok('Log::Fine::Levels::Syslog');
        use_ok('Log::Fine::Levels::Java');
        use_ok('Log::Fine::Logger');
        use_ok('Log::Fine::Utils');

    SKIP: {

                eval "use Mail::RFC822::Address";
                skip
                    "Mail::RFC822::Address required for testing Email delivery",
                    3
                    if $@;

                eval "use Email::Sender";
                skip "Email::Sender required for testing Email delivery", 2
                    if $@;

                use_ok('Log::Fine::Handle::Email');
                use_ok('Log::Fine::Handle::Email::EmailSender');

                eval "use MIME::Lite";
                skip
"MIME::Lite required for testing Email delivery via MIME::Lite",
                    1
                    if $@;

                use_ok('Log::Fine::Handle::Email::MIMELite');

        }

}

diag("Testing Log::Fine $Log::Fine::VERSION, Perl $], $^X");
