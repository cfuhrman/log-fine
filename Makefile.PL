use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(NAME          => 'Log::BSDLog',
              AUTHOR        => 'Christopher M. Fuhrman <cfuhrman@panix.com>',
              VERSION_FROM  => 'lib/Log/BSDLog.pm',
              ABSTRACT_FROM => 'lib/Log/BSDLog.pm',
              PL_FILES      => {},
              PREREQ_PM     => { 'Test::More' => 0, },
              dist          => {
                        COMPRESS => 'gzip -9f',
                        SUFFIX   => 'gz',
              },
              clean => { FILES => 'Log-BSDLog-*' },
);
