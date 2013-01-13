
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

    # Register the handle
    $log->registerHandle($handle);

    # Log something
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

#use Data::Dumper;
use File::Spec::Functions;
use FileHandle;
use POSIX qw( strftime );

our $VERSION = $Log::Fine::Handle::File::VERSION;

=head1 OVERRIDDEN METHODS

=head2 fileHandle

See L<Log::Fine::Handle::File/fileHandle>

=cut

sub fileHandle
{

        my $self = shift;

        # Return if we have a registered filehandle and the date is
        # still the same
        return $self->{_filehandle}
            if (    not $self->_fileRotate()
                and defined $self->{_filehandle}
                and ref $self->{_filehandle}
                and UNIVERSAL::can($self->{_filehandle}, 'isa')
                and $self->{_filehandle}->isa("IO::File")
                and defined fileno($self->{_filehandle}));

        # We need a new file.  Close our filehandle if it exists
        if (     defined $self->{_filehandle}
             and ref $self->{_filehandle}
             and UNIVERSAL::can($self->{_filehandle}, 'isa')
             and $self->{_filehandle}->isa("IO::File")
             and defined fileno($self->{_filehandle})) {

                $self->_error(
                              sprintf("Unable to close file handle to %s : %s",
                                      $self->{_expanded_filename}, $!
                              )) unless $self->{_filehandle}->close();

        }

        # Generate file name
        my $filename = catdir($self->{dir}, $self->{_expanded_filename});

        # Generate a new filehandle
        $self->{_filehandle} = FileHandle->new(">> " . $filename);

        $self->_error("Unable to open log file $filename : $!\n")
            unless defined $self->{_filehandle};

        # Set autoflush if necessary
        $self->{_filehandle}->autoflush($self->{autoflush});

        return $self->{_filehandle};

}          # fileHandle();

# --------------------------------------------------------------------

##
# Determines if we need a new file name or not.  Note that
# {_expanded_filename} will be set to new value if we need to rotate
#
# @returns 1 if we need a file name, 0 otherwise

sub _fileRotate
{

        my $self = shift;
        my $filename = strftime($self->{file}, localtime(time));

        if (not defined $self->{_expanded_filename}
             or $self->{_expanded_filename} ne $filename) {
                $self->{_expanded_filename} = $filename;
                return 1;
        } else {
                return 0;
        }

        #
        # NOT REACHED
        #

}          # _fileName()

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-handle at rt.cpan.org>, or through the
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

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle::File>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008, 2010-2011, 2013 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Handle::File::Timestamp
