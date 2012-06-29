#!perl -T

#
# $Id$
#

use Test::More;

use Log::Fine;
use Log::Fine::Handle::File;
use Log::Fine::Levels::Syslog;
use Log::Fine::Logger;

use FileHandle;
use POSIX qw(strftime);

{

        if ($^O ne "MSWin32") {
                plan skip_all => "Tests for MSWin32 environment only";
        } else {
                plan tests => 5;
        }

        my $file = sprintf("C:\\WINDOWS\\Temp\\log-fine-$$-%s",
                           strftime("%Y%m%d%H%M%S", localtime(time)));
        my $msg = "Smoke me a kipper, I'll be back for breakfast";

        # Get a logger
        my $log = Log::Fine->logger("windowstest0");

        isa_ok($log, "Log::Fine");

        # Add file handle
        my $handle =
            Log::Fine::Handle::File->new(file      => $file,
                                         autoflush => 1);

        isa_ok($handle, "Log::Fine::Handle");

        # Remove the file if it exists so as not to confuse ourselves
        unlink $file if -e $file;

        # Write a test message
        $handle->msgWrite(INFO, $msg, 1);

        ok(-f $file);
        $handle->fileHandle()->close();

        # Grab a ref to our filehandle
        my $fh = FileHandle->new($file);
        isa_ok($fh, "IO::File");

        # Read in the file
        while (<$fh>) {
                ok(/^\[.*?\] \w+ $msg/);
        }

        # Clean up
        $fh->close();
        unlink $file;

}
