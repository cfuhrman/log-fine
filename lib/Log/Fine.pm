
=head1 NAME

Log::Fine - Yet another logging framework

=head1 SYNOPSIS

Provides fine-grained logging and tracing.

    use Log::Fine;
    use Log::Fine qw( :masks );          # log masks
    use Log::Fine qw( :macros :masks );  # everything

    # build a Log::Fine object
    my $fine = Log::Fine->new();

    # specify a custom map
    my $fine = Log::Fine->new(levelmap => "Syslog");

    # use logger() to get a new logger object.  If "foo" is not
    # defined then a new logger with the name "foo" will be created.
    my $log = Log::Fine->logger("foo");

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

require 5.006;

package Log::Fine;

use Carp;
use Log::Fine::Levels;
use Log::Fine::Logger;

our $VERSION = sprintf "r%d", q$Rev$ =~ m/(\d+)/;

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

# Private Methods
# --------------------------------------------------------------------

{

        # private global variables
        my $levelmap;
        my $loggers  = {};
        my $objcount = 0;

        # getter/setter for levelMap.  Note that levelMap can only be
        # set _once_.
        sub _levelMap
        {

                my $map = shift;

                if (    ($levelmap and $levelmap->isa("Log::Fine::Levels"))
                     or (not defined $map)) {
                        return $levelmap;
                } elsif ($map and $map->isa("Log::Fine::Levels")) {
                        $levelmap = $map;
                } else {
                        croak sprintf("Invalid Value: %s", $map || "{undef}");
                }

        }          # _levelMap()

        sub _logger          { return $loggers }
        sub _objectCount     { return $objcount }
        sub _incrObjectCount { $objcount++ }

}

# --------------------------------------------------------------------

=head1 METHODS

The Log::Fine module, by itself, simply exports a few constants, and
allows the developer to get a new logger.  After a logger is created,
further actions are done through the logger object.  The following two
constructors are defined:

=head2 new()

Creates a new Log::Fine object.  Optionally takes a hash with the
following parameters:

=over

=item levelmap [default: Syslog]

Name of level map to use.  See L<Log::Fine::Levels> for further
details

=back

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

=head2 levelMap

Returns the L<Log::Fine::Levels> object for level mapping.

=cut

sub levelMap { return _levelMap() }

=head2 logger($name)

Returns the named logger object.  If there is no object with the given
name, then a new one will be created.

=cut

sub logger
{

        my $self = shift;
        my $name = shift;          # name of logger

        # validate name
        croak "First parameter must be a valid name!\n"
            unless (defined $name and $name =~ /\w/);

        # Grab our list of loggers
        my $loggers = _logger();

        # if the requested logger is found, then return it, otherwise
        # store and return a newly created logger object.
        $loggers->{$name} = Log::Fine::Logger->new(name => $name)
            unless (defined $loggers->{$name}
                    and $loggers->{$name}->isa("Log::Fine::Logger"));

        # return the logger
        return $loggers->{$name};

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
        unless (defined $self->{name} and $self->{name} =~ /\w/) {

                # grab the class name
                $self->{name} = ref $self;
                $self->{name} =~ /\:(\w+)$/;
                $self->{name} = lc($+) . _objectCount();

        }

        # Set our levels if we need to
        _levelMap(Log::Fine::Levels->new($self->{levelmap}))
            unless (_levelMap() and _levelMap()->isa("Log::Fine::Levels"));

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
L<Log::Fine::Logger>, L<Log::Fine::Utils>, L<Sys::Syslog>

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

Copyright (c) 2008, 2009 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine
