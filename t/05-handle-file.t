#!perl -T

#
# $Id: 05-handle-file.t 45 2008-05-07 22:06:40Z cfuhrman $
#

use Test::Simple tests => 12;

use File::Spec::Functions;
use FileHandle;
use Log::BSDLog;
use Log::BSDLog::Handle;
use Log::BSDLog::Handle::File;
use Log::BSDLog::Logger;

{

    my $file = "autotest.log";
    my $msg  = "We're so miserable it's stunning";

    # get a logger
    my $log = Log::BSDLog->getLogger("handlefile0");

    ok(ref $log eq "Log::BSDLog::Logger");

    # add a handle.  Note we use the default formatter.
    my $handle =
        Log::BSDLog::Handle::File->new({
                                         file      => $file,
                                         autoflush => 1,
        });

    # do some validation
    ok($handle->isa("Log::BSDLog::Handle"));

    # these should be set to their default values
    ok($handle->{mask} == Log::BSDLog::Handle->DEFAULT_LOGMASK);
    ok($handle->{level} == DEBG);
    ok($handle->{formatter}->isa("Log::BSDLog::Formatter::Basic"));

    # File-specific attributes
    ok($handle->{file} eq $file);
    ok($handle->{dir}  eq "./");
    ok($handle->{autoflush} == 1);

    # remove the file if it exists so as not to confuse ourselves
    unlink $file if -e $file;

    # write a test message
    $handle->msgWrite(INFO, $msg, 1);

    # grab a ref to our filehandle
    my $fh = $handle->getFileHandle();

    # see if a file handle was properly constructed
    ok($fh->isa("IO::File"));

    # now check the file
    ok(-e $file);

    # close the file handle and reopen
    $fh->close();

    $fh = FileHandle->new(catdir($handle->{dir}, $file));

    # see if a file handle was properly constructed
    ok($fh->isa("IO::File"));

    # read in the file
    while (<$fh>) {
        ok(/^\[.*?\] \w+ $msg/);
    }

    # clean up
    $fh->close();
    unlink $file;

}
