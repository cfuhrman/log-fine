#!perl -T

#
# $Id$
#

use Test::More tests => 16;

use File::Spec::Functions;
use FileHandle;
use Log::Fine;
use Log::Fine::Handle::File;
use Log::Fine::Handle::String;
use Log::Fine::Levels::Java;
use Log::Fine::Utils;

{

        my $file = "utils.log";
        my $msg  = "Stop by this disaster town";

        # Create a handle
        my $handle =
            Log::Fine::Handle::File->new(file      => $file,
                                         autoflush => 1,);

        isa_ok($handle, "Log::Fine::Handle");
        can_ok($handle, "name");

        # remove the file if it exists so as not to confuse ourselves
        unlink $file if -e $file;

        # Make sure there are no loggers defined
        ok(not defined ListLoggers() or scalar ListLoggers() == 0);
        ok(not defined CurrentLogger());

        # open the logging sub-system
        OpenLog(handles  => [$handle],
                levelmap => "Java");

        # Should be one logger defined now
        ok(scalar ListLoggers() == 1);
        ok(grep("GENERIC", ListLoggers()));
        ok(CurrentLogger()->name() eq "GENERIC");

        #print STDERR "\n1) About to log\n\n";

        # log a message
        Log(FINE, $msg);

        # check the file
        ok(-f $file);

        my $fh = FileHandle->new(catdir($handle->{dir}, $file));

        # see if a file handle was properly constructed
        isa_ok($fh, "IO::File");

        # read in the file
        while (<$fh>) {
                ok(/^\[.*?\] \w+ $msg/);
        }

        # clean up
        #$fh->close();
        #unlink $file;

        # Now test multiple loggers
        my $strhandle = Log::Fine::Handle::String->new();

        OpenLog(name    => "UNITTEST",
                handles => [$strhandle],);

        ok(scalar ListLoggers() == 2);
        ok(grep("UNITTEST", ListLoggers()));
        ok(CurrentLogger()->name() eq "UNITTEST");

        # print STDERR "\n2) About to log\n\n";

        # Note that levelmap should be already set to "Java"
        ok(Log(FINER, $msg));

        # Switch back to generic logger
        OpenLog(name => "GENERIC");
        ok(CurrentLogger()->name() eq "GENERIC");

        # print STDERR "\n3) About to log\n\n";

        Log(INFO, $msg);

        ok(-f $file);

        # Clean up
        $fh->flush();
        $fh->close();
        $handle->fileHandle()->close();
        unlink $file;

}
