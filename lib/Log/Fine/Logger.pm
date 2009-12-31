
=head1 NAME

Log::Fine::Logger - Main logging object

=head1 SYNOPSIS

Provides an object through which to log.

    use Log::Fine;
    use Log::Fine::Logger;

    # get a new logging object
    my $log = Log::Fine->getLogger("mylogger");

    # alternatively, specify a custom map
    my $log = Log::Fine->getLogger("mylogger", "Syslog");

    # register a handle
    $log->registerHandle( Log::Fine::Handle::Console->new() );

    # log a message
    $log->log(DEBG, "This is a really cool module!");

    # illustrate use of the log skip API
    package Some::Package::That::Overrides::Log::Fine::Logger;

    use base qw( Log::Fine::Logger );

    sub log
    {
        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;

        # do some custom stuff to message

        # make sure the formatter logs the correct calling method.
        $self->incrSkip();
        $self->SUPER::log($lvl, $msg);
        $self->decrSkip();

    } # log()

=head1 DESCRIPTION

The Logger class is the main workhorse of the Log::Fine framework,
providing the main L</"log"> method from which to log.  In addition,
the Logger class provides means by which the developer can control the
parameter passed to any caller() call so information regarding the
correct stack frame is displayed.

=cut

use strict;
use warnings;

package Log::Fine::Logger;

use base qw( Log::Fine );

use Log::Fine;

# Constant: LOG_SKIP_DEFAULT
#
# By default, calls to caller() will be given a stack frame of 2.

use constant LOG_SKIP_DEFAULT => 2;

# --------------------------------------------------------------------

=head2 decrSkip()

Decrements the value of {_skip} by one, returning the new value.

=cut

sub decrSkip
{
        return --$_[0]->{_skip};
}          # decrSkip()

=head2 getSkip()

Returns the value of {_skip}

=cut

sub getSkip
{
        return $_[0]->{_skip};
}          # getSkip()

=head2 incrSkip()

Increments the value of {_skip}, returning the new value

=cut

sub incrSkip
{
        return ++$_[0]->{_skip};
}          # incrSkip()

=head2 log($lvl, $msg)

Logs the message at the given log level.

=cut

sub log
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;

        # see if we have any handles defined
        $self->_fatal("No handles defined!")
            unless (    defined $self->{_handles}
                    and ref $self->{_handles} eq "ARRAY"
                    and scalar @{ $self->{_handles} } > 0);

        # iterate through each handle, logging as appropriate
        foreach my $handle (@{ $self->{_handles} }) {
                $handle->msgWrite($lvl, $msg, $self->{_skip})
                    if $handle->isLoggable($lvl);
        }

        # Victory
        return $self;

}          # log()

=head2 registerHandle($handle)

Registers the given L<Log::Fine::Handle> object with the logging
facility.

=cut

sub registerHandle
{

        my $self   = shift;
        my $handle = shift;

        # validate handle
        $self->_fatal(
                    "first argument must be a valid Log::Fine::Handle object\n")
            unless (defined $handle
                    and $handle->isa("Log::Fine::Handle"));

        # initialize handles if we haven't already
        $self->{_handles} = []
            unless (defined $self->{_handles}
                    and ref $self->{_handles} eq "ARRAY");

        # save the handle
        push @{ $self->{_handles} }, $handle;

        return $self;

}          # registerHandle()

=head2 setSkip($skip)

Sets the value passed to L<perlfunc/"caller">().   Note this
only applies to loggers that include caller information in their log
files.

=cut

sub setSkip
{
        $_[0]->{_skip} = $_[1];
}          # setSkip()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # validate name
        $self->_fatal("Loggers need names!")
            unless (defined $self->{name} and $self->{name} =~ /^\w+$/);

        # set logskip if necessary
        $self->{_skip} = LOG_SKIP_DEFAULT
            unless ($self->{_skip} and $self->{_skip} =~ /\d+/);

        return $self;

}          # _init()

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-logger at rt.cpan.org>, or through the web interface at
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
All rights reserved

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Logger
