# -*- mode: cperl -*-

use strict;
use warnings;
use ExtUtils::MakeMaker;

use Sys::Syslog 0.13;

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
