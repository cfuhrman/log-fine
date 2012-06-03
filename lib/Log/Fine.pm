
=head1 NAME

Log::Fine - Yet another logging framework

=head1 SYNOPSIS

Provides fine-grained logging and tracing.

    use Log::Fine;
    use Log::Fine::Levels::Syslog;                # exports log levels
    use Log::Fine::Levels::Syslog qw( :masks );   # exports masks and levels

    # build a Log::Fine object
    my $fine = Log::Fine->new();

    # specify a custom map
    my $fine = Log::Fine->new(levelmap => "Syslog");

    # Get the name of the log object
    my $name = $fine->name();

    # use logger() to get a new logger object.  If "foo" is not
    # defined then a new logger with the name "foo" will be created.
    my $log = Log::Fine->logger("foo");

    # get list of names of defined logger objects
    my @loggers = $log->listLoggers();

    # register a handle, in this case a handle that logs to console.
    my $handle = Log::Fine::Handle::Console->new();
    $log->registerHandle( $handle );

    # log a message
    $log->log(INFO, "Log object successfully initialized");

=head1 DESCRIPTION

Log::Fine provides a logging framework for application developers
who need a fine-grained logging mechanism in their program(s).  By
itself, Log::Fine provides a mechanism to get one or more logging
objects (called I<loggers>) from its stored namespace.  Most logging
is then done through a logger object that is specific to the
application.

For a simple functional interface to the logging sub-system, see
L<Log::Fine::Utils|Log::Fine::Utils>.

=head2 Handles

Handlers provides a means to output log messages in one or more
ways. Currently, the following handles are provided:

=over 4

=item  * L<Log::Fine::Handle::Console|Log::Fine::Handle::Console>

Provides logging to C<STDERR> or C<STDOUT>

=item  * L<Log::Fine::Handle::Email|Log::Fine::Handle::Email>

Provides logging via email.  Useful for delivery to one or more pager
addresses.

=item  * L<Log::Fine::Handle::File|Log::Fine::Handle::File>

Provides logging to a file

=item  * L<Log::Fine::Handle::File::Timestamp|Log::Fine::Handle::File::Timestamp>

Same thing with support for time-stamped files

=item  * L<Log::Fine::Handle::Syslog|Log::Fine::Handle::Syslog>

Provides logging to L<syslog>

=back

See the relevant perldoc information for more information.  Additional
handlers can be defined to the user's taste.

=cut

use strict;
use warnings;

package Log::Fine;

require 5.006;

use Carp;
use Log::Fine::Levels;
use Log::Fine::Logger;
use POSIX qw( strftime );

our $VERSION = '0.59';

=head2 Formatters

A formatter specifies how Log::Fine displays messages.  When a message
is logged, it gets passed through a formatter object, which adds any
additional information such as a time-stamp or caller information.

By default, log messages are formatted as follows using the
L<Basic|Log::Fine::Formatter::Basic> formatter object.

     [<time>] <LEVEL> <MESSAGE>

For more information on the customization of log messages, see
L<Log::Fine::Formatter>.

=head1 INSTALLATION

To install Log::Fine:

  perl Makefile.PL
  make
  make test
  make install

=cut

# Private Methods
# --------------------------------------------------------------------

{

        # private global variables
        my $levelmap;
        my $loggers  = {};
        my $objcount = 0;

        # getter/setter for levelMap.  Note that levelMap can only be
        # set _once_.  Once levelmap is set, any other value passed,
        # whether a valid object or not, will be ignored!
        sub _levelMap
        {

                my $map = shift;

                if (     defined $map
                     and $map->isa("Log::Fine::Levels")
                     and not $levelmap) {
                        $levelmap = $map;
                } elsif (defined $map and not $levelmap) {
                        _fatal(
                                sprintf("Invalid Value: \"%s\"",
                                        $map || "{undef}"));
                }

                return $levelmap;

        }          # _levelMap()

        sub _logger          { return $loggers }
        sub _objectCount     { return $objcount }
        sub _incrObjectCount { return ++$objcount }

}

# --------------------------------------------------------------------

=head1 METHODS

The Log::Fine module, by itself, provides getters & setter methods for
loggers and level classes.  After a logger is created, further actions
are done through the logger object.  The following two constructors
are defined:

=head2 new

Creates a new Log::Fine object.

=head3 Parameters

A hash with the following keys

=over

=item  * levelmap

[default: Syslog] Name of level map to use.  See L<Log::Fine::Levels>
for further details

=item  * no_croak

[optional] If set to true, then do not L<croak|Carp> when
L</"_fatal()"> is called.

=back

=head3 Returns

The newly bless'd object

=cut

sub new
{

        my $class = shift;
        my %h     = @_;

        # bless the hash into a class
        my $self = bless \%h, $class;

        # perform any necessary initializations
        $self->_init();

        # return the bless'd object
        return $self;

}          # new()

=head2 listLoggers

Provides list of currently defined loggers

=head3 Parameters

None

=head3 Returns

Array containing list of currently defined loggers

=cut

sub listLoggers { return keys %{ _logger() } }

=head2 levelMap

Getter for the global level map.

=head3 Returns

A L<Log::Fine::Levels> subclass

=cut

sub levelMap { return _levelMap() }

=head2 logger

Getter/Constructor for a logger object.

=head3 Parameters

=over

=item  * logger name

The name of the logger object.  If the specified logger object does
not exist, then a new one will be created.

=back

=head3 Returns

an L<Log::Fine::Logger> object

=cut

sub logger
{

        my $self = shift;
        my $name = shift;          # name of logger

        # validate name
        $self->_fatal("First parameter must be a valid name!")
            unless (defined $name and $name =~ /\w/);

        # If the requested logger is found, then return it, otherwise
        # store and return a newly created logger object with the
        # given name
        _logger()->{$name} = Log::Fine::Logger->new(name => $name)
            unless (defined _logger()->{$name}
                    and _logger()->{$name}->isa("Log::Fine::Logger"));

        # return the logger
        return _logger()->{$name};

}          # logger()

=head2 name

Getter for name of object

=head3 Parameters

None

=head3 Returns

String containing name of object, otherwise undef

=cut

sub name { return $_[0]->{name} || undef }

# --------------------------------------------------------------------

=head2 _fatal

Private internal method that is called when a fatal (nonrecoverable)
condition is encountered.  Unless the C<{no_croak}> attribute is
defined, this method will call L<confess|Carp>.  Also, should the user
elect to set C<{no_croak}>, then the objects C<{_err_str}> attribute
will contain a string representing the error message.

This method can be overridden per taste.

=head3 Parameters

=over

=item message

Message passed to L<confess|Carp>.

=back

=cut

sub _fatal
{

        my $self;
        my $msg;
        my @call = caller;

        # how were we called?
        if (scalar @_ > 1) {
                $self = shift;
                $msg  = shift;
        } else {
                $msg = shift;
        }

        printf STDERR "\n[%s] {%s@%d} FATAL : %s\n",
            strftime("%c", localtime(time)), $call[0] || "{undef}",
            $call[2] || 0,
            $msg || "No reason given";

        $self->{_err_str} = $msg
            if (defined $self and $self->isa("Log::Fine"));

        confess $msg
            if ((    defined $self
                 and $self->isa("Log::Fine")
                 and not $self->{no_croak})
                or (not defined $self));

}          # _fatal()

##
# Initializes our object

sub _init
{

        my $self = shift;

        # increment object count
        _incrObjectCount();

        # we set the objects name unless it is already set for us
        unless (defined $self->{name} and $self->{name} =~ /\w/) {

                # grab the class name
                $self->{name} = ref $self;
                $self->{name} =~ /\:(\w+)$/;
                $self->{name} = lc($+) . _objectCount();

        }

        # Set our levels if we need to
        _levelMap(Log::Fine::Levels->new($self->{levelmap}))
            unless (defined _levelMap()
                    and _levelMap()->isa("Log::Fine::Levels"));

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

=head1 CONTRIBUTING

Want to contribute?  The source code repository for Log::Fine is now
available at L<http://github.com/cfuhrman/log-fine>.  To clone your
own copy:

  $ git clone git://github.com/cfuhrman/log-fine.git

Signed patches generated by L<git-format-patch>(1) may be submitted
L<via email|/AUTHOR>.

=head1 REVISION INFORMATION

  $Id$

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 SEE ALSO

L<perl>, L<syslog>, L<Log::Fine::Handle>, L<Log::Fine::Formatter>,
L<Log::Fine::Logger>, L<Log::Fine::Utils>, L<Sys::Syslog>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008-2011 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine
