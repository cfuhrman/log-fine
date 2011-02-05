# -*- mode: cperl -*-

use strict;
use warnings;
use ExtUtils::MakeMaker;

use Sys::Syslog;

# Constants
use constant SYS_SYSLOG_MIN_VERSION => 0.13;

# --------------------------------------------------------------------

# In order to prevent myself from getting flooded with CPAN Testing
# reports, exit if Sys::Syslog isn't found
if ($Sys::Syslog::VERSION < SYS_SYSLOG_MIN_VERSION) {
        printf STDERR
            "Log::Fine requires Sys::Syslog >= %0.02f (You have %0.02f)\n",
            SYS_SYSLOG_MIN_VERSION, $Sys::Syslog::VERSION;
        printf STDERR
            "Upgrade Sys::Syslog before installing this CPAN module\n\n";
        printf STDERR "Aborting!\n";
        exit 0;
}

# Write our Makefile
WriteMakefile(
        NAME          => 'Log::Fine',
        AUTHOR        => 'Christopher M. Fuhrman <cfuhrman@panix.com>',
        LICENSE       => 'bsd',
        VERSION_FROM  => 'lib/Log/Fine.pm',
        ABSTRACT_FROM => 'lib/Log/Fine.pm',
        PL_FILES      => {},
        PREREQ_PM     => {
                       'Test::More'  => 0,
                       'Sys::Syslog' => "0.13"
        },
        META_MERGE => {
                'resources' => {
                       bugtracker =>
"http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-Fine",
                       repository => "https://github.com/cfuhrman/log-fine",
                       license =>
"https://github.com/cfuhrman/log-fine/raw/master/LICENSE"
                },
                'recommends' => {
                                  'Test::Output'  => 0.10,
                                  'Pod::Coverage' => 0.19,
                                  'Test::Pod'     => 1.14,
                                  'Time::HiRes'   => 1.86
                }
        },
        dist => {
                  COMPRESS => 'gzip -9f',
                  SUFFIX   => 'gz',
        },
        clean => { FILES => 'Log-Fine-*' },
);
