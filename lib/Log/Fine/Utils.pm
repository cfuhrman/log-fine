
=head1 NAME

Log::Fine::Utils - Functional wrapper around Log::Fine

=head1 SYNOPSIS

Provides a functional wrapper around Log::Fine.

    use Log::Fine::Handle;
    use Log::Fine::Handle::File;
    use Log::Fine::Handle::Syslog;
    use Log::Fine::Utils;

    # set up some handles as you normally would.  First, a handler for
    # file logging:
    my $handle1 = Log::Fine::Handle::File
        ->new( name      => "file0",
               mask      => Log::Fine::Handler->LOGMASK_ALL,
               formatter => Log::Fine::Formatter::Basic->new() );

    # and now a handle for syslog
    my $handle2 = Log::Fine::Handle::Syslog
        ->new( name      => "syslog0",
               mask      => LOGMASK_EMERG | LOGMASK_CRIT | LOGMASK_ERR,
               ident     => $0,
               logopts   => 'pid',
               facility  => LOG_LEVEL0 );

    # open the logging subsystem
    OpenLog( handles  => [ $handle1, [$handle2], ... ],
             levelmap => "Syslog");

    # Log a message
    Log(INFO, "The angels have my blue box");

=head1 DESCRIPTION

The Utils class provides a functional wrapper for L<Log::Fine> and
friends, thus saving the developer the tedious task of mucking about
in object-oriented land.

=cut

use strict;
use warnings;

package Log::Fine::Utils;

our @ISA = qw( Exporter );

use Data::Dumper;

use Log::Fine;
use Log::Fine::Levels;
use Log::Fine::Logger;

our $VERSION = $Log::Fine::VERSION;

# Exported functions
our @EXPORT = qw( ListLoggers Log OpenLog );

# Private Functions
# --------------------------------------------------------------------

{

        my $logfine;
        my $logname;

        # Getter/Setter for Log::Fine object
        sub _logfine
        {
                my $obj = shift;

                $logfine = $obj
                    if (defined $obj and $obj->isa("Log::Fine"));

                return $logfine;
        }

        # getter/setter for logger name
        sub _logname
        {
                my $name = shift;

                $logname = $name
                    if (defined $name and $name =~ /\w/);

                return $logname;
        }

}

=head1 FUNCTIONS

The following functions are automatically exported by
Log::Fine::Utils:

=head2 ListLoggers

Provides list of currently defined loggers

=head3 Parameters

None

=head3 Returns

Array containing list of currently defined loggers or undef if no
loggers are defined

=cut

sub ListLoggers
{
        return (defined _logfine()) ? _logfine()->listLoggers() : ();
}          # ListLoggers()

=head2 Log

Logs the message at the given log level

=head3 Parameters

=over

=item  * level

Level at which to log

=item  * message

Message to log

=back

=head3 Returns

1 on success

=cut

sub Log
{

        my $lvl = shift;
        my $msg = shift;
        my $log = _logfine->logger(_logname());

        # validate logger has been set
        Log::Fine->_fatal(  "Logging system has not been set up "
                          . "(See Log::Fine::Utils::OpenLog())")
            unless (defined $log and $log->isa("Log::Fine::Logger"));

        # make sure we log the correct calling method
        $log->incrSkip();
        $log->log($lvl, $msg);
        $log->decrSkip();

        return 1;

}          # Log()

=head2 OpenLog

Opens the logging subsystem.

=head3 Parameters

A hash containing the following keys:

=over

=item * handles

An array ref containing one or more L<Log::Fine::Handle> objects

=item * levelmap

B<[optional]> L<Log::Fine::Levels> subclass to use.  Will default to
"Syslog" if not defined.

=item * name

B<[optional]> Name of logger.  If name is defined, will switch
internal logger to given name, otherwise, creates a new logger and
switches to that

=back

=head3 Returns

1 on success

=cut

sub OpenLog
{

        my %data = @_;

        # Set name to a default if need be
        $data{name} = "GENERIC"
            unless (defined $data{name} and $data{name} =~ /\w/);

        # If no Log::Fine object is defined, generate one
        _logfine(
                 Log::Fine->new(name     => "Utils",
                                levelmap => $data{levelmap}
                                    || Log::Fine::Levels->DEFAULT_LEVELMAP
                 )
        ) unless (defined _logfine() and _logfine()->isa("Log::Fine"));

        # See if logger specified by name is already defined
        if (     defined _logfine
             and defined _logname()
             and _logfine->isa("Log::Fine")
             and _logname() =~ /\w/
             and grep(/$data{name}/, ListLoggers())) {
                _logname($data{name});
                return 1;
        } elsif (   not defined $data{handles}
                 or ref $data{handles} ne "ARRAY"
                 or scalar @{ $data{handles} } == 0) {

                Log::Fine->_fatal("At least one handle must be defined");
                return undef;          # in case {no_croak} option given

        } else {

                # create logger
                my $logger = _logfine->logger($data{name});

                # register given handles
                $logger->registerHandle($_) foreach @{ $data{handles} };

                # Set logger name
                _logname($data{name});

                return 1;

        }

        #
        # NOT REACHED
        #

}          # OpenLog()

=head1 CAVEATS

Log::Fine::Utils defines one and only one generic logger.  Multiple
loggers via Utils are not currently supported.

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>, L<Log::Fine::Logger>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-utils at rt.cpan.org>, or through the web interface at
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

Copyright (c) 2008, 2010 Christopher M. Fuhrman, 
All rights reserved

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Utils
