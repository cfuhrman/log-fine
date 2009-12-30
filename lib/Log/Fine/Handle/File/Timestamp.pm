
=head1 NAME

Log::Fine::Handle::File::Timestamp - Output log messages to time-stamped files

=head1 SYNOPSIS

Provides logging to a time-stamped file

    use Log::Fine;
    use Log::Fine::Handle::File::Timestamp;

    # Get a new logger
    my $log = Log::Fine->getLogger("foo");

    # register a file handle (default values shown)
    my $handle = Log::Fine::Handle::File::Timestamp
        ->new( name => 'file1',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT | LOGMASK_ERR | LOGMASK_WARNING | LOGMASK_NOTICE | LOGMASK_INFO,
               dir  => "/var/log",
               file => "myapp.%y%m%d.log" );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->(INFO, "Opened new log handle");


=head1 DESCRIPTION

Log::Fine::Handle::File::Timestamp, aside from having a ridiculously
long name, provides logging to a time-stamped file.  Usage is similar
to L<Log::Fine::Handle::File> with the exception that the file name
can take an L<strftime(3)-compatible|strftime> string.

=cut

use strict;
use warnings;

package Log::Fine::Handle::File::Timestamp;

use base qw( Log::Fine::Handle::File );

use File::Spec::Functions;
use FileHandle;
use POSIX qw( strftime );

# Constant: TODAY_FORMAT
#
# strftime-compatible format for today's date.

use constant TODAY_FORMAT => "%Y%m%d";

# Private Methods
# --------------------------------------------------------------------

{

        my $today;

        sub _getToday { return $today }
        sub _setToday { $today = shift }

}

=head1 OVERRIDDEN METHODS

=head2 getFileHandle()

See L<Log::Fine::Handle::File>

=cut

sub getFileHandle
{

        my $self  = shift;
        my $today = _getToday();

        # return if we have a registered filehandle and the date is
        # still the same
        return $self->{_filehandle}
            if (    defined $self->{_filehandle}
                and $self->{_filehandle}->isa("IO::File")
                and defined $today
                and strftime(TODAY_FORMAT, localtime(time)) eq $today);

        # need a new file.  Close our filehandle if it exists
        $self->{_filehandle}->close()
            if (defined $self->{_filehandle}
                and $self->{_filehandle}->isa("IO::File"));

        # generate file name
        my $filename =
            catdir($self->{dir}, strftime($self->{file}, localtime(time)));

        # generate a new filehandle
        $self->{_filehandle} = FileHandle->new(">> " . $filename);

        $self->_fatal("Unable to open log file $filename : $!\n")
            unless defined $self->{_filehandle};

        # set autoflush if necessary
        $self->{_filehandle}->autoflush($self->{autoflush});

        # reset today's date
        _setToday(strftime(TODAY_FORMAT, localtime(time)));

        # return the newly created file handle
        return $self->{_filehandle};

}          # getFileHandle();

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle::File>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-handle-file-timestamp at rt.cpan.org>, or through the
web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-Fine>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::Fine

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-Fine>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Log-Fine>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-Fine>

=item * Search CPAN

L<http://search.cpan.org/dist/Log-Fine>

=back

=head1 REVISION INFORMATION

  $Id$

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Handle::File::Timestamp
