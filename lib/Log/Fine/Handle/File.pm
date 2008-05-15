
=head1 NAME

Log::Fine::Handle::File - Output log messages to a file

=head1 SYNOPSIS

Provides logging to a file

    use Log::Fine;
    use Log::Fine::Handle::File;

    # Get a new logger
    my $log = Log::Fine->getLogger("foo");

    # register a file handle (default values shown)
    my $handle = Log::Fine::Handle::File
        ->new( name => 'file0',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT | LOGMASK_ERR | LOGMASK_WARNING | LOGMASK_NOTICE | LOGMASK_INFO,
               dir  => "/var/log",
               file => "myapp.log" );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->(INFO, "Opened new log handle");

=head1 DESCRIPTION

Log::Fine::Handle::File provides logging to a file.  Note that this
module will log messages to a specific file.  By itself, it does not
support file timestamps (see L<Log::Fine::Handle::File::Timestamp>) or
log rotation.

=cut

use strict;
use warnings;

package Log::Fine::Handle::File;

use base qw( Log::Fine::Handle );

use Carp;
use File::Basename;
use File::Spec::Functions;
use FileHandle;
use Log::Fine;

=head1 METHODS

=head2 getFileHandle()

Retrives the filehandle to write to.  Override this method if you wish
to support features such as time-stamped and/or rotating files.

=cut

sub getFileHandle
{

        my $self = shift;

        # if we already have a file handle defined, return it
        return $self->{_filehandle}
                if (defined $self->{_filehandle}
                    and $self->{_filehandle}->isa("IO::File"));

        # generate file name
        my $filename = catdir($self->{dir}, $self->{file});

        # otherwise create a new one
        $self->{_filehandle} = FileHandle->new(">> " . $filename);

        croak "Unable to open log file $filename : $!\n"
                unless defined $self->{_filehandle};

        # set autoflush if necessary
        $self->{_filehandle}->autoflush($self->{autoflush});

        # return the newly created file handle
        return $self->{_filehandle};

}          # getFileHandle()

=head2 msgWrite($lvl, $msg, $skip)

See L<Log::Fine::Handle>

=cut

sub msgWrite
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;

        # grab a ref to our file handle
        my $fh = $self->getFileHandle();

        # if we have a formatter defined, then use that, otherwise, just
        # print the raw message
        $msg = $self->{formatter}->format($lvl, $msg, $skip)
                if defined $self->{formatter};

        # print the message to the log file
        print $fh $msg;

        # Victory!
        return $self;

}          # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

        # set the default directory
        $self->{dir} = "./"
                unless (defined $self->{dir} and -d $self->{dir});

        # set the default file name
        $self->{file} = basename $0 . ".log"
                unless defined $self->{file};

        # Victory!
        return $self;

}          # _init()

##
# called when this object is destroyed

sub DESTROY
{

        my $self = shift;

        # close our filehandle if necessary.
        $self->{_filehandle}->close()
                if (defined $self->{_filehandle}
                    and $self->{_filehandle}->isa("IO::File"));

}          # DESTROY

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-handle-file at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-Fine>.
I will be notified, and then you'll automatically be notified of progress on
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

1;          # End of Log::Fine::Handle::File
