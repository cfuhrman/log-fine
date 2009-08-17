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

use Carp;
use Storable qw( dclone );

use Log::Fine::Levels;

our $VERSION = '0.22.1';
our @ISA     = qw( Exporter );

# Exporter and Autoload variables
our (%EXPORT_TAGS, @EXPORT, @EXPORT_OK) = ();

# --------------------------------------------------------------------

# Package Methods
# --------------------------------------------------------------------

{
        my $loggers  = {};  # stores hash of Log::Fine::Logger objects
        my $objcount = 0;   # number of active objects
        my $loaded = 0;     # set if all log levels are loaded

        # variable for storing Log::Fine::Levels object
        my $levels;

        # these are relatively straightforward
        sub _getLvlObject       { return $levels }
        sub _getLoggers      { return $loggers }
        sub _getObjectCount  { return $objcount }
        sub _incrObjectCount { $objcount++ }
        sub _isLoaded        { return $loaded }
        sub _setObjectCount  { $objcount = shift }
        sub _setLoaded       { $loaded = 1 }

        sub _setLevels {

                my $obj = shift;

                # validate levels
                Carp::confess "Levels must be set to Log::Fine::Levels object"
                        unless $obj->isa("Log::Fine::Levels");

                # we can only be set ONCE
                if ($levels->isa("Log::Fine::Levels")) {
                        Carp::cluck "WARN: Levels has already been set";
                } else {
                        $levels = $obj;
                }

        } # _setLevels

}

# --------------------------------------------------------------------

BEGIN {

         

}

# --------------------------------------------------------------------

# Private Methods
# --------------------------------------------------------------------

sub _load_imports {

        my $lvlclass = shift;

        # don't do anything if we're already loaded
        return if _isLoaded();

        %EXPORT_TAGS = ( macros => [ _getLvlObject()->getLevels() ],
                         masks  => [ _getLvlObject()->getMasks() ]);

        # Export Log Levels
        foreach my $lvl ( @{ $EXPORT_TAGS{macros}}) {
                eval "sub $lvl { return _getLvlObject()->levelToValue($lvl) }";
        }

        # export Log Masks
        foreach my $mask ( @{$EXPORT_TAGS{masks}}) {
                eval "sub $mask { return _getLvlObject()->maskToValue{$mask} }";
        }

        # mark ourselves as loaded
        _setLoaded();

} # _load_imports()

# --------------------------------------------------------------------

# Exported macros
@EXPORT    = _getLvlObject->getLevels();
@EXPORT_OK = _getLvlObject->getMasks();

# variable to store convenience macros
use constant LOGMASK_ALL => 8888;

# --------------------------------------------------------------------

# Public Methods
# --------------------------------------------------------------------

=head1 METHODS

The Log::Fine module, by itself, simply exports a few constants, and
allows the developer to get a new logger.  After a logger is created,
further actions are done through the logger object.  The following two
constructors are defined:

=cut

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

        # perform any initializations required by the super class
        $self->SUPER::_init();

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

# --------------------------------------------------------------------

# Overridden methods
# --------------------------------------------------------------------

##
# Override method for Exporter::import()

sub import {

        my $this =  shift;

        my $lvlclass; # Name of the level class passed to Log::Fine::Levels->new();
        my @list;     # list to export

        # differentiate imports from level class
        foreach my $import (@_) {
                if ($import =~ m/^:/) {
                        push @list, $import;
                } else {
                        _setLevels( Log::Fine::Level->new($import));
                }
        }

        _load_imports();

        local $Exporter::ExportLevel = 1;
        Exporter::import($this, @list);

} # import()

# --------------------------------------------------------------------

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

