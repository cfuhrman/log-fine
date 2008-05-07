
=head1 NAME

Log::BSDLog::Handle::Syslog - Output log messages to syslog

=head1 SYNOPSIS

Provides logging to syslog()

    use Log::BSDLog;
    use Log::BSDLog::Handle::Syslog;
    use Sys::Syslog;

    # Get a new logger
    my $log = Log::BSDLog->getLogger("foo");

    # register a syslog handle
    my $handle = Log::BSDLog::Handle::Syslog->new(
        {
             name  => 'myname',
             mask  => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT | LOGMASK_ERR | LOGMASK_WARNING | LOGMASK_NOTICE | LOGMASK_INFO,
             ident => $0,
             logopts => 'pid',
             facility => LOG_LEVEL0,
        } );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->(INFO, "Opened new log handle");

=head1 DESCRIPTION

Log::BSDLog::Handle::Syslog provides logging via the standard UNIX
syslog facility.  For more information, it is I<highly> recommended
that you read the L<Sys::Syslog> documentation.

=cut

use strict;
use warnings;

package Log::BSDLog::Handle::Syslog;

use base qw( Log::BSDLog::Handle );

use File::Basename;
use Log::BSDLog;
use Sys::Syslog qw( :standard :macros );

our $VERSION = '0.01';

# Constant: LOG_MAPPING
#
# Maps Log::BSDLog LOG_LEVELS to Sys::Syslog equivalents

use constant LOG_MAPPING => {
                              0 => LOG_EMERG,
                              1 => LOG_ALERT,
                              2 => LOG_CRIT,
                              3 => LOG_ERR,
                              4 => LOG_WARNING,
                              5 => LOG_NOTICE,
                              6 => LOG_INFO,
                              7 => LOG_DEBUG,
};

# Constant: DEFAULT_LOG_IDENT

=head1 METHODS

=head2 msgWrite($lvl, $msg, $skip)

See L<Log::BSDLog::Handle>

Note that this method B<does not> make use of a formatter as this is
handled by the syslog facility.

=cut

sub msgWrite
{

    my $self = shift;
    my $lvl  = shift;
    my $msg  = shift;
    my $skip = shift;             # NOT USED
    my $map  = LOG_MAPPING;

    # write to syslog
    syslog($map->{$lvl}, $msg);

    # Victory!
    return $self;

}        # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

    my $self = shift;

    # call the super object
    $self->SUPER::_init();

    # set ident
    $self->{ident} = basename $0;

    # set the default logopts (to be passed to Sys::Syslog::openlog()
    $self->{logopts} = "pid"
        unless (defined $self->{logopts} and $self->{logopts} =~ /\w+/);

    # set the default facility
    $self->{facility} = LOG_LOCAL0
        unless (defined $self->{faciity} and $self->{facility} =~ /\w+/);

    # open the syslog connection
    openlog($self->{ident}, $self->{logopts}, $self->{facility});

    # Victory!
    return $self;

}        # _init()

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-bsdlog-handle-syslog at rt.cpan.org>, or through the web interface at
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
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

=head1 SEE ALSO

L<perl>, L<syslog>, L<Sys::Syslog>

=cut

1;        # End of Log::BSDLog::Handle::Syslog
