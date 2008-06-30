
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
    my $handle = Log::Fine::Handle::Console->new();
    $log->registerHandle( $handle );

    # log a message
    $log->log(INFO, "Log object successfully initialized");

    # create a clone of a Logger object and a handle object
    my $clone1 = $log->clone();          # <-- clone of $log
    my $clone2 = $log->clone($handle);

=head1 DESCRIPTION

Log::Fine provides a logging framework for application developers
who need a fine-grained logging mechanism in their program(s).  By
itself, Log::Fine provides a mechanism to get one or more logging
objects (called I<loggers>) from its stored namespace.  Most logging
is then done through a logger object that is specific to the
application.

=head2 Handles

Handlers provides a means to output log messages in one or more
ways. Currently, the following handles are provided:

=over 4

=item  * L<Log::Fine::Handle::Console|Log::Fine::Handle::Console>

Provides logging to C<STDERR> or C<STDOUT>

=item  * L<Log::Fine::Handle::File|Log::Fine::Handle::File>

Provides logging to a file

=item * L<Log::Fine::Handle::File::Timestamp|Log::Fine::Handle::File::Timestamp>

Same thing with support for time-stamped files

=item  * L<Log::Fine::Handle::Syslog|Log::Fine::Handle::Syslog>

Provides logging to L<syslog>

=back

See the relevant perldoc information for more information.  Additional
handlers can be defined to the user's taste.

=cut

use strict;
use warnings;

require 5.006;
require Exporter;

package Log::Fine;

use Carp;
use Log::Fine::Logger;
use Storable qw( dclone );
use Sys::Syslog qw( :macros );

our $VERSION = '0.14';
our @ISA     = qw( Exporter );

=head2 Log Levels

Log::Fine bases its log levels on those found in
L<Sys::Syslog|Sys::Syslog>.  For convenience, the following shorthand
macros are exported.

=over 4

=item * C<EMER>

=item * C<ALRT>

=item * C<CRIT>

=item * C<ERR>

=item * C<WARN>

=item * C<NOTI>

=item * C<INFO>

=item * C<DEBG>

=back

Each of these corresponds to the appropriate logging level.

=cut

# Log Levels
use constant LOG_LEVELS => [qw( EMER ALRT CRIT ERR WARN NOTI INFO DEBG )];

=head2 Masks

Log masks can be exported for use in setting up individual handles
(see L<Log::Fine::Handle>).  Log::Fine exports the following
masks corresponding to their log level:

=over 4

=item * C<LOGMASK_EMERG>

=item * C<LOGMASK_ALERT>

=item * C<LOGMASK_CRIT>

=item * C<LOGMASK_ERR>

=item * C<LOGMASK_WARNING>

=item * C<LOGMASK_NOTICE>

=item * C<LOGMASK_INFO>

=item * C<LOGMASK_DEBUG>

=back

See L<Log::Fine::Handle> for more information.

In addition, the following shortcut constants are provided.  Note that
these I<are not> exported by default, rather you have to reference
them explicitly, as shown below.

=over 4

=item * C<Log::Fine-E<gt>LOGMASK_ALL>

Shorthand constant for B<all> log masks.

=item * C<Log::Fine-E<gt>LOGMASK_ERROR>

Shorthand constant for C<LOGMASK_EMERG> through C<LOGMASK_ERR>.  This
is not to be confused with C<LOGMASK_ERR>.

=back

In addition, you can specify your own customized masks as shown below:

    # we want to log all error masks plus the warning mask
    my $mask = Log::Fine->LOGMASK_ERROR | LOGMASK_WARNING;

=cut

# Log Masks
use constant LOG_MASKS => [
        qw( LOGMASK_EMERG LOGMASK_ALERT LOGMASK_CRIT LOGMASK_ERR LOGMASK_WARNING LOGMASK_NOTICE LOGMASK_INFO LOGMASK_DEBUG )
];

=head2 Formatters

A formatter specifies how Log::Fine displays messages.  When a message
is logged, it gets passed through a formatter object, which adds any
additional information such as a time-stamp or caller information.

By default, log messages are formatted as follows using the
L<Basic|Log::Fine::Formatter::Basic> formatter object.

     [<time>] <LEVEL> <MESSAGE>

For more information on the customization of log messages, see
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

# define some convenient mask shorthands
use constant LOGMASK_ALL => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT |
    LOGMASK_ERR | LOGMASK_WARNING | LOGMASK_NOTICE | LOGMASK_INFO |
    LOGMASK_DEBUG;
use constant LOGMASK_ERROR => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT |
    LOGMASK_ERR;

=head1 METHODS

The Log::Fine module, by itself, simply exports a few constants, and
allows the developer to get a new logger.  After a logger is created,
further actions are done through the logger object.  The following two
constructors are defined:

=head2 new()

Creates a new Log::Fine object.

=cut

sub new
{

        my $class = shift;
        my %h     = @_;

        # if $class is already an object, then return the object
        return $class if (ref $class and $class->isa("Log::Fine"));

        # bless the hash into a class
        my $self = bless \%h, $class;

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

        # validate name
        croak "First parameter must be a valid name!\n"
            unless (defined $name and $name =~ /\w/);

        # if the requested logger is found, then return it, otherwise
        # store and return a newly created logger object.
        $loggers->{$name} = Log::Fine::Logger->new(name => $name)
            unless (defined $loggers->{$name}
                    and $loggers->{$name}->isa("Log::Fine::Logger"));

        # return the logger
        return $loggers->{$name};

}          # getLogger()

=head2 clone([$obj])

Clone the given Log::Fine object, returning the newly cloned object.
If not given an object, then returns a clone of the calling object.

=cut

sub clone
{

        my $self = shift;
        my $obj  = shift;

        # if we weren't given any additional arguments, assume we wish
        # to clone ourself.
        return dclone($self) unless scalar @_;

        # validate object
        croak "First argument must be valid Log::Fine object!\n"
            unless $obj->isa("Log::Fine");

        # return the cloned object
        return dclone($obj);

}          # clone()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # increment object count
        _incrObjectCount();

        # we set the object's name unless it is already set for us
        unless (defined $self->{name} and $self->{name} =~ /\w/) {

                # grab the class name
                $self->{name} = ref $self;
                $self->{name} =~ /\:(\w+)$/;
                $self->{name} = lc($+) . _getObjectCount();

        }

        # Victory!
        return $self;

}          # _init()

# is "Python" a dirty word in perl POD documentation?  Oh well.

=head1 ACKNOWLEDGMENTS

I'd like the thank the following people for either inspiration or past
work on logging: Josh Glover for his work as well as teaching me all I
know about object-oriented programming in perl.  Dan Boger for taking
the time and patience to review this code and offer his own
suggestions.  Additional thanks to Tom Maher and Chris Josephs for
encouragement.

=head2 Related Modules/Frameworks

The following logging frameworks provided inspiration for parts of Log::Fine.

=over 4

=item

Dave Rolsky's L<Log::Dispatch> module

=item

Sun Microsystem's C<java.utils.logging> framework

=item

The Python logging package

=back

=head1 SEE ALSO

L<perl>, L<syslog>, L<Log::Fine::Handle>, L<Log::Fine::Formatter>,
L<Log::Fine::Logger>, L<Sys::Syslog>,

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

=cut

1;          # End of Log::Fine
