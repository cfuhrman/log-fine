#!perl -T

#
# $Id$
#

use Test::More tests => 13;

use File::Spec::Functions;

use Log::Fine;
use Log::Fine::Handle;
use Log::Fine::Handle::File::Timestamp;
use Log::Fine::Levels::Syslog;

use POSIX qw( strftime );

{

        my $base = "fine.%y%m%d.log";
        my $msg  = "We're so miserable it's stunning";

        # add a handle.  Note we use the default formatter.
        my $handle =
            Log::Fine::Handle::File::Timestamp->new(file      => $base,
                                                    autoflush => 1);

        isa_ok($handle, "Log::Fine::Handle");
        can_ok($handle, "name");
        can_ok($handle, "msgWrite");

        ok($handle->name() =~ /\w\d+$/);

        # these should be set to their default values
        ok($handle->{mask} == $handle->levelMap()->bitmaskAll());
        ok($handle->{formatter}->isa("Log::Fine::Formatter::Basic"));

        # File-specific attributes
        ok($handle->{file} eq $base);
        ok($handle->{dir}  eq "./");
        ok($handle->{autoflush} == 1);

        # remove the file if it exists so as not to confuse ourselves
        unlink $base if -e $base;

        # write a test message
        $handle->msgWrite(INFO, $msg, 1);

        # construct the full name of the file
        my $file = strftime($base, localtime(time));

        # see if a file handle was properly constructed
        ok($handle->{_filehandle}->isa("IO::File"));

        # now check the file
        ok(-e $file);

        # close the file handle and reopen
        $handle->{_filehandle}->close();

        my $fh = FileHandle->new(catdir($handle->{dir}, $file));

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
