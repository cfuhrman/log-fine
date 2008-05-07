
=head1 NAME

Log::BSDLog - Yet another logging framework

=head1 SYNOPSIS

Provides fine-grained logging and tracing.

    use Log::BSDLog;
    use Log::BSDLog qw( :masks );          # log masks
    use Log::BSDLog qw( :macros :masks );  # everything

    # grab our logger object
    my $log = Log::BSDLog->getLogger("foo");

    # register a handle, in this case a handle that logs to console.
    $log->registerHandle( Log::BSDLog::Handle::Output->new() );

    # log a message
    $log->log(INFO, "Log object successfully initialized");

=head1 DESCRIPTION

Log::BSDLog provides a logging framework for application developers
who need a fine-grained logging mechanism in their program(s).  By
itself, Log::BSDLog provides a mechanism to get one or more logging
objects (called I<loggers>) from its stored namespace.  Most logging
is then done through a logger object that is specific to the
application.

=head2 Handlers

Handlers provides a means to output log messages in one or more
ways. Currently, the following handles are provided:

=over 4

=item L<Log::BSDLog::Handle::Output>

Provides logging to C<STDERR> or C<STDOUT>.

=item L<Log::BSDLog::Handle::File>

Provides logging to a file.

=item L<Log::BSDLog::Handle::Syslog>

Provides logging to L<syslog>

=back

Additional Handlers can be defined to the user's taste.

=cut

use strict;
use warnings;

require 5.006;
require Exporter;

package Log::BSDLog;

use Carp;
use Sys::Syslog qw( :macros );

our $VERSION = '0.01';
our @ISA     = qw( Exporter );

=head2 Log Levels

Log::BSDLog bases its log levels on those found in the
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
(see L<Log::BSDLog::Handle>).  Log::BSDLog exports the following
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

See L<Log::BSDLog::Handle> for more information.

=cut

# Log Masks
use constant LOG_MASKS => [
    qw( LOGMASK_EMERG LOGMASK_ALERT LOGMASK_CRIT LOGMASK_ERR LOGMASK_WARNING LOGMASK_NOTICE LOGMASK_INFO LOGMASK_DEBUG )
];

=head2 Logging Formats

By default, log messages are formatted as follows using the
L<Basic|Log::BSDLog::Formatter::Basic> formatter object.

     [<time>] <LEVEL> <MESSAGE>\n

For more information on the customization of log messages, please see
L<Log::BSDLog::Formatter>.

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
    my $loggers = {};

    sub _getLoggers { return $loggers }
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

The Log::BSDLog module, by itself, simply exports a few constants, and
allows the developer to get a new logger.  After a logger is created,
further actions are done through the logger object.  The following two
constructors are defined:

=head2 new($hash)

Creates a new Log::BSDLog object.

=cut

sub new
{

    my $class = shift;
    my $hash = shift || {};

    # if $class is already an object, then return the object
    return $class if (ref $class);

    # bless the hash into a class
    my $self = bless $hash, ref $class || $class;

    # perform any necessary initializations
    $self->_init();

    # return the bless'd object
    return $self;

}        # new()

=head2 getLogger($name)

Creates a logger with the given name.  This method can also be used as
a constructor for a Log::BSDLog object

=cut

sub getLogger
{

    my $self    = shift->new();
    my $name    = shift;
    my $loggers = _getLoggers();

    # validate name
    confess "Loggers need names!\n"
        unless (defined $name and $name =~ /\w+/);

    # if the requested logger is found, then return it, otherwise
    # return a newly created logger object.
    if (defined $loggers->{$name}) {
        return $loggers->{$name};
    } else {
        require Log::BSDLog::Logger;
        return Log::BSDLog::Logger->new({ name => $name });
    }

}        # getLogger()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

    my $self = shift;

    return $self;

}        # _init()

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-bsdlog at rt.cpan.org>, or through the web interface at
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

  $Id: BSDLog.pm 45 2008-05-07 22:06:40Z cfuhrman $

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

1;        # End of Log::BSDLog
