#!/usr/bin/env perl

#
# $Id$
#

use strict;
use warnings;

use lib "lib";

use File::Slurp;
use Getopt::Long;
use Time::HiRes qw( gettimeofday tv_interval );

use Log::Fine::Handle::Console;
use Log::Fine::Handle::File;
use Log::Fine::Formatter::Template;
use Log::Fine::Levels::Syslog;

{

        my $input;
        my $output = "fine.log";

        GetOptions("i=s" => \$input,
                   "o=s" => \$output);

        die "Need input file"
            unless $input =~ /\w/;

        # Open up a console output
        my $console_handle = Log::Fine::Handle::Console->new();
        my $out            = Log::Fine->logger("console0");

        $out->registerHandle($console_handle);
        $out->log(INFO, "Starting Stress Script");
        $out->log(DEBG, "INPUT FILE:$input:");
        $out->log(DEBG, "OUTPUT FILE:$output:");

        # Create a template logger to a file
        my $formatter =
            Log::Fine::Formatter::Template->new(
                                     template => "[%%TIME%%] %%USER%%@%%HOSTSHORT%% %%LEVEL%% %%MSG%%",
                                     timestamp_format => "%b %e %T");

        my $handle =
            Log::Fine::Handle::File->new(file      => $output,
                                         autoflush => 1,
                                         formatter => $formatter
            );

        my $log = Log::Fine->logger("logger0");

        $log->registerHandle($handle);

        # Slurp in input file
        $out->log(INFO, "Reading in $input");
        my @lines = read_file($input);

        # Start writing out test file
        $out->log(INFO, "Writing out test log");
        my $t1 = [gettimeofday];
        for my $line (@lines) {
                $log->log(INFO, $line);
        }
        my $t2 = [gettimeofday];
        my $t3 = tv_interval $t1, $t2;

        # clean up after ourselves
        $out->log(INFO, "Done");
        $handle->fileHandle->close();

        $out->log(INFO,
                  sprintf("%d lines were written to %s in %0.5f seconds",
                          scalar @lines,
                          $output, $t3
                  ));
        $out->log(NOTI, "Good bye");

}
