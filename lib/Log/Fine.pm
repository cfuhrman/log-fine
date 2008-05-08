
=head1 NAME

Log::Fine - Yet another logging framework

=head1 SYNOPSIS

Provides fine-grained logging and tracing.

    use Log::Fine;
    use Log::Fine qw( :masks );          # log masks
    use Log::Fine qw( :macros :masks );  # everything

    # grab our logger object
    my $log = Log::Fine->getLogger("foo");

    # register a handle, in this case a handle that logs to console.
    $log->registerHandle( Log::Fine::Handle::Output->new() );

    # log a message
    $log->log(INFO, "Log object successfully initialized");

=head1 DESCRIPTION

Log::Fine provides a logging framework for application developers
who need a fine-grained logging mechanism in their program(s).  By
itself, Log::Fine provides a mechanism to get one or more logging
objects (called I<loggers>) from its stored namespace.  Most logging
is then done through a logger object that is specific to the
application.

=head2 Handlers

Handlers provides a means to output log messages in one or more
ways. Currently, the following handles are provided:

=over 4

=item L<Log::Fine::Handle::Output>

Provides logging to C<STDERR> or C<STDOUT>.

=item L<Log::Fine::Handle::File>

Provides logging to a file.

=item L<Log::Fine::Handle::Syslog>

Provides logging to L<syslog>

=back

Additional Handlers can be defined to the user's taste.

=cut

use strict;
use warnings;

require 5.006;
require Exporter;

package Log::Fine;

use Carp;
use Sys::Syslog qw( :macros );

our $VERSION = '0.01';
our @ISA     = qw( Exporter );

=head2 Log Levels

Log::Fine bases its log levels on those found in the
L<Sys::Syslog> module.  For convenience, the following shorthand
macros are exported.

=over 4

=item EMER

=item ALRT

=item CRIT

=item ERR

=item WARN

=item NOTI

=item INFO

=item DEBG

=back

Each of these corresponds to the appropriate logging level.

=cut

use constant LOG_LEVELS => [qw( EMER ALRT CRIT ERR WARN NOTI INFO DEBG )];

=head2 Masks

Log masks can be exported for use in setting up individual handles
(see L<Log::Fine::Handle>).  Log::Fine exports the following
masks corresponding to their log level:

=over 4

=item C<LOGMASK_EMERG>

=item C<LOGMASK_ALERT>

=item C<LOGMASK_CRIT>

=item C<LOGMASK_ERR>

=item C<LOGMASK_WARNING>

=item C<LOGMASK_NOTICE>

=item C<LOGMASK_INFO>

=item C<LOGMASK_DEBUG>

=back

See L<Log::Fine::Handle> for more information.

=cut

# Log Masks
use constant LOG_MASKS => [
        qw( LOGMASK_EMERG LOGMASK_ALERT LOGMASK_CRIT LOGMASK_ERR LOGMASK_WARNING LOGMASK_NOTICE LOGMASK_INFO LOGMASK_DEBUG )
];

=head2 Logging Formats

By default, log messages are formatted as follows using the
L<Basic|Log::Fine::Formatter::Basic> formatter object.

     [<time>] <LEVEL> <MESSAGE>\n

For more information on the customization of log messages, please see
L<Log::Fine::Formatter>.

=cut

# Exported tags
our %EXPORT_TAGS = (macros => LOG_LEVELS,
                    masks  => LOG_MASKS);

# Exported macros
our @EXPORT    = (@{ $EXPORT_TAGS{macros} });
our @EXPORT_OK = (@{ $EXPORT_TAGS{masks} });

# Private Methods
# --------------------------------------------------------------------

{
        my $loggers  = {};
        my $objcount = 0;

        sub _getLoggers      { return $loggers }
        sub _getObjectCount  { return $objcount }
        sub _incrObjectCount { $objcount++ }
        sub _setObjectCount  { $objcount = shift }
}

# Initializations
# --------------------------------------------------------------------

BEGIN {

        my $lvls  = LOG_LEVELS;
        my $masks = LOG_MASKS;

        # define some convenience functions
        for (my $i = 0; $i < scalar @{$lvls}; $i++) {
                eval "sub $lvls->[$i] { return $i; }";
                eval "sub $masks->[$i] { return 2 << $i; }";
        }

}

=head1 METHODS

The Log::Fine module, by itself, simply exports a few constants, and
allows the developer to get a new logger.  After a logger is created,
further actions are done through the logger object.  The following two
constructors are defined:

=head2 new($hash)

Creates a new Log::Fine object.

=cut

sub new
{

        my $class = shift;
        my %h     = @_;

        # if $class is already an object, then return the object
        return $class if (ref $class);

        # bless the hash into a class
        my $self = bless \%h, ref $class || $class;

        # perform any necessary initializations
        $self->_init();

        # return the bless'd object
        return $self;

}          # new()

=head2 getLogger($name)

Creates a logger with the given name.  This method can also be used as
a constructor for a Log::Fine object

=cut

sub getLogger
{

        my $self    = shift->new();
        my $name    = shift;
        my $loggers = _getLoggers();

        # if the requested logger is found, then return it, otherwise
        # return a newly created logger object.
        if (defined $loggers->{$name}) {
                return $loggers->{$name};
        } else {
                require Log::Fine::Logger;
                return Log::Fine::Logger->new(name => $name);
        }

}          # getLogger()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # increment object count
        _incrObjectCount();

        # we set the object's name unless it is already set for us
        unless (defined $self->{name} and $self->{name} =~ /\w+/) {

                # grab the class name
                $_ = ref $self;

                # now grab the last name in that class
                /\:\:(\w+)$/;

                # and set name
                $self->{name} = lc($1) . _getObjectCount();
        }

        # Victory!
        return $self;

}          # _init()

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine at rt.cpan.org>, or through the web interface at
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

=head1 SEE ALSO

L<perl>, L<syslog>, L<Sys::Syslog>

=cut

1;          # End of Log::Fine
