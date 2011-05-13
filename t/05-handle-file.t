#!perl -T

#
# $Id$
#

use Test::More tests => 22;

use File::Spec::Functions;
use FileHandle;

use Log::Fine;
use Log::Fine::Handle;
use Log::Fine::Handle::File;
use Log::Fine::Levels::Syslog;
use Log::Fine::Logger;

{

        my $file = "fine.log";
        my $msg  = "We're so miserable it's stunning";

        # get a logger
        my $log = Log::Fine->logger("handlefile0");

        isa_ok($log, "Log::Fine::Logger");
        can_ok($log, "name");

        ok($log->name() =~ /\w\d+$/);

        # add a handle.  Note we use the default formatter.
        my $handle =
            Log::Fine::Handle::File->new(file      => $file,
                                         autoflush => 1);

        # do some validation
        isa_ok($handle, "Log::Fine::Handle");
        can_ok($handle, "name");
        can_ok($handle, "levelMap");
        can_ok($handle, "msgWrite");

        ok($handle->name() =~ /\w\d+$/);

        # these should be set to their default values
        ok($handle->{mask} == $handle->levelMap()->bitmaskAll());
        ok($handle->{formatter}->isa("Log::Fine::Formatter::Basic"));

        # File-specific attributes
        ok($handle->{file} eq $file);
        ok($handle->{dir}  eq "./");
        ok($handle->{autoflush} == 1);
        ok($handle->{autoclose} == 0);

        # remove the file if it exists so as not to confuse ourselves
        unlink $file if -e $file;

        # write a test message
        $handle->msgWrite(INFO, $msg, 1);

        # grab a ref to our filehandle
        my $fh = $handle->fileHandle();

        # see if a file handle was properly constructed
        isa_ok($fh, "IO::File");

        # now check the file
        ok(-e $file);

        # close the file handle and reopen
        $fh->close();

        $fh = FileHandle->new(catdir($handle->{dir}, $file));

        # see if a file handle was properly constructed
        isa_ok($fh, "IO::File");

        # read in the file
        while (<$fh>) {
                ok(/^\[.*?\] \w+ $msg/);
        }

        # clean up
        $fh->close();
        unlink $file;

        # Test to make sure autoclose works as expected
        my $closehandle =
            Log::Fine::Handle::File->new(file      => $file,
                                         autoflush => 1,
                                         autoclose => 1
            );

        isa_ok($closehandle, "Log::Fine::Handle::File");
        can_ok($closehandle, "fileHandle");
        can_ok($closehandle, "msgWrite");

        # grab a ref to the FileHandle object
        my $fh2 = $closehandle->fileHandle();

        # Write something out and make sure our filehandle is closed
        $closehandle->msgWrite(INFO, $msg, 1);

        # fileno will return undef if $fh2 is a closed filehandle
        ok(not defined fileno $fh2);

        # clean up
        unlink $file;

}
