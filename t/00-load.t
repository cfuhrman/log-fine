#!perl -T

use Test::More tests => 16;

BEGIN {
        use_ok('Log::Fine');
        use_ok('Log::Fine::Formatter');
        use_ok('Log::Fine::Formatter::Basic');
        use_ok('Log::Fine::Formatter::Detailed');
        use_ok('Log::Fine::Formatter::Syslog');
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
}

diag("Testing Log::Fine $Log::Fine::VERSION, Perl $], $^X");
