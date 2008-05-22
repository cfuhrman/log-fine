#!perl -T

use Test::More tests => 10;

BEGIN {
        use_ok('Log::Fine');
        use_ok('Log::Fine::Handle');
        use_ok('Log::Fine::Handle::File');
        use_ok('Log::Fine::Handle::Console');
        use_ok('Log::Fine::Handle::Syslog');
        use_ok('Log::Fine::Handle::String');
        use_ok('Log::Fine::Logger');
        use_ok('Log::Fine::Formatter');
        use_ok('Log::Fine::Formatter::Basic');
        use_ok('Log::Fine::Formatter::Detailed');
}

diag("Testing Log::Fine $Log::Fine::VERSION, Perl $], $^X");
