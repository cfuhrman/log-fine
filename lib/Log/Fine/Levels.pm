
=head1 NAME

Log::Fine::Levels - Define variable logging levels

=head1 SYNOPSIS

Provides logging translations

    use Log::Fine::Levels;

    # instantiate the levels object using the default translations
    my $levels = Log::Fine::Levels->new();

    # instantiate the levels object using customized translations
    my $levels = Log::Fine::Levels->new("Java");

    # Supported methods
    my @l = $levels->logLevels();   # grab list of levels
    my @m = $levels->logMasks();    # grab list of masks

    # translation methods
    my $val     = $levels->levelToValue("INFO");
    my $bitmask = $levels->maskToValue("LOGMASK_INFO");
    my $lvl     = $levels->valueToLevel(3);

=head1 DESCRIPTION

Log::Fine::Levels is used by the L<Log::Fine> framework to translate
customizable log levels (such as INFO, DEBUG, WARNING, etc) to and
from an associated value as well as convenience methods for
interacting with log levels (such as grabbing a list of levels).

In addition, the L<Log::Fine> framework supports the notion of a
I<mask>, which is used for customizing output.  See
L<Log::Fine::Handle> for more details as to how masks are used.

=head2 Customization

Log::Fine::Levels only provides methods for interacting with log
levels and associated log masks.  In order to define levels and masks,
it I<must> be overridden.  Note that, by default, the
L<Log::Fine::Levels::Syslog> class is used to define log levels.

=head2 Independence

Finally, Log::Fine::Levels is written to be independant of the
L<Log::Fine> framework and, as such, does not inherit any methods from
L<Log::Fine>.  This allows developers to use Log::Fine::Levels by
itself for defining customizable level packages for use in their own
programs.

=cut

use strict;
use warnings;

package Log::Fine::Levels;

use Carp;

# Constants
# --------------------------------------------------------------------

use constant DEFAULT_LEVELMAP => "Syslog";

# --------------------------------------------------------------------

=head1 METHODS

The following methods are provided:

=head2 new()

Creates a new Log::Fine::Levels object

=cut

sub new
{

        my $class = shift;
        my $lvlmap = shift || DEFAULT_LEVELMAP;

        # construct the subclass
        my $levelClass = join("::", $class, $lvlmap);

        # validate levelclass
        eval "require $levelClass;";

        # Do we have the class defined?
        confess "Error : Level Class $levelClass does not exist : $@"
            if $@;

        # return the new subclass
        return $levelClass->new();

}          # new()

=head2 logLevels

Returns an array containing levels, sorted by ascending numeric value

=cut

sub logLevels
{

        my $self = shift;
        my @lvls;

        # if there are more than 9 keys, then sorting could be
        # problematic, so make sure values are properly sorted.
        foreach my $val (
                sort map (sprintf("%02d", $_), keys %{ $self->VALTOLVL_MAP })) {
                push @lvls, $self->VALTOLVL_MAP->{ sprintf("%d", $val) };
        }

        return @lvls;

}          # logLevels()

=head2 logMasks

Returns an array containing mask names

=cut

sub logMasks
{

        my $self = shift;
        return keys %{ $self->MASK_MAP };

}          # logMasks()

=head2 levelToValue

Returns the numeric value matching the given log level

=cut

sub levelToValue
{

        my $self = shift;
        my $lvl  = shift;

        return $self->LVLTOVAL_MAP->{$lvl};

}          # levelToValue()

=head2 maskToValue

Returns the numeric value matching the given mask name

=cut

sub maskToValue
{
        my $self = shift;
        my $mask = shift;

        return $self->MASK_MAP->{$mask};

};          # maskToValue()

=head2 valueToLevel

Returns the level name associated with the given numeric value

=cut

sub valueToLevel
{

        my $self = shift;
        my $val  = shift;

        return $self->VALTOLVL_MAP->{$val}

}          # valueToLevel()

=head1 SEE ALSO

L<perl>, L<syslog>, L<Log::Fine>, L<Sys::Syslog>

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

    perldoc Log::Fine::Levels

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

Copyright (c) 2009 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Levels
