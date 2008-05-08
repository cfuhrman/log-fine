use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(NAME          => 'Log::Fine',
              AUTHOR        => 'Christopher M. Fuhrman <cfuhrman@panix.com>',
              VERSION_FROM  => 'lib/Log/Fine.pm',
              ABSTRACT_FROM => 'lib/Log/Fine.pm',
              PL_FILES      => {},
              PREREQ_PM     => { 'Test::More' => 0, },
              dist          => {
                        COMPRESS => 'gzip -9f',
                        SUFFIX   => 'gz',
              },
              clean => { FILES => 'Log-Fine-*' },
);
