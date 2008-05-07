
=head1 NAME

Log::BSDLog::Logger - Main logging object

=head1 SYNOPSIS

Provides an object through which to log.

    use Log::BSDLog;
    use Log::BSDLog::Logger;

    # get a new logging object
    my $log = Log::BSDLog->getLogger("mylogger");

    # register a handle
    $log->registerHandle( Log::BSDLog::Handle::Output->new() );

    # log a message
    $log->log(DEBG, "This is a really cool module!");

    # illustrate use of the logskip attribute
    package Some::Package::That::Overrides::Log::BSDLog::Logger;

    use base qw( Log::BSDLog::Logger );

    sub log
    {
        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;

        # do some custom stuff ...

        # make sure the formatter logs the correct calling method.
        $self->{skip}++;
        $self->log($lvl, $msg);
        $self->{skip}--;

    } # log()

=cut

use strict;
use warnings;

package Log::BSDLog::Logger;

use base qw( Log::BSDLog );

use Carp;
use Exporter;
use Log::BSDLog;

use vars qw(@ISA @EXPORT);

# Constant: LOG_SKIP_DEFAULT
#
# By default, calls to caller() will be given a stack frame of 2.

use constant LOG_SKIP_DEFAULT => 2;

our $VERSION = '0.01';

# --------------------------------------------------------------------

=head2 new([<hash ref>])

Constructor for this object.

=cut

sub new
{

        my $class = shift;
        my $hash  = shift;

        # set default name if necessary
        $hash->{name} = "default"
                unless (defined $hash->{name} and $hash->{name} =~ /\w+/);

        # set logskip if necessary
        $hash->{skip} = LOG_SKIP_DEFAULT
                unless ($hash->{skip} and $hash->{skip} =~ /\d+/);

        # return the bless'd object
        return bless $hash, $class;

}          # new()

=head2 log($lvl, $msg)

Log a message to one or more handles

Parameters:

  level - level at which to log
  msg   - message to log

=cut

sub log
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;

        # see if we have any handles defined
        croak "No handles defined!\n"
                unless (scalar @{ $self->{_handles} } > 0);

        # iterate through each handle, logging as appropriate
        foreach my $handle (@{ $self->{_handles} }) {
                $handle->msgWrite($lvl, $msg, $self->{skip})
                        if $handle->isLoggable($lvl);
        }

        # Victory
        return $self;

}          # log()

=head2 registerHandle(<handle>)

Registers the given L<Log::BSDLog::Handle> object with the logging
facility.

=cut

sub registerHandle
{

        my $self   = shift;
        my $handle = shift;

        # validate handle
        croak "first argument must be a valid Log::BSDLog::Handle object\n"
                unless (defined $handle
                        and $handle->isa("Log::BSDLog::Handle"));

        # initialize handles if we haven't already
        $self->{_handles} = []
                unless (defined $self->{_handles}
                        and ref $self->{_handles} eq "ARRAY");

        # save the handle
        push @{ $self->{_handles} }, $handle;

        return $self;

}          # registerHandle()

# --------------------------------------------------------------------

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-bsdlog-logger at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-BSDLog>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::BSDLog

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-BSDLog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Log-BSDLog>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-BSDLog>

=item * Search CPAN

L<http://search.cpan.org/dist/Log-BSDLog>

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

=head1 SEE ALSO

L<perl>, L<Log::BSDLog>, L<Log::BSDLog::Handle>

=cut

1;          # End of Log::BSDLog::Logger
