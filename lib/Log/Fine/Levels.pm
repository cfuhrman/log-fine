use strict;
use warnings;

package Log::Fine::Levels;

use Carp;

# Constants & Globals
# --------------------------------------------------------------------

# default levels to use
use constant DEFAULT_LEVELMAP => "Syslog";

# --------------------------------------------------------------------

# --------------------------------------------------------------------

# Constructor
# --------------------------------------------------------------------

=head1 METHODS

=head2 new

Creates a new Log::Fine::Levels object.  Takes as an argument the name
of the level map to use.  For instance:

    # Use levels as found in java.lang.logging
    my $levels = Log::Fine::Levels("Java");

    # Use classic Syslog levels
    my $levels = Log::Fine::Levels("Syslog");

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
            if ($@);

        # return the new subclass
        return $levelClass->new();

}          # new()

# --------------------------------------------------------------------

# Public Methods
# --------------------------------------------------------------------

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

sub logMasks {

        my $self = shift;
        return keys %{$self->MASK_MAP};

} # logMasks()

sub levelToValue {

        my $self = shift;
        return $self->LVLTOVAL_MAP->{$_[0]};

} # levelToValue()

sub maskToValue {

        my $self = shift;
        return $self->MASK_MAP->{$_[0]};

}; # maskToValue()

sub valueToLevel {

        my $self = shift;
        return $self->VALTOLVL_MAP->{$_[0]}

} # valueToLevel()

# --------------------------------------------------------------------

=head1 SEE ALSO

L<perl>, L<strftime>, L<Log::Fine>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-record at rt.cpan.org>, or through the web interface at
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

Copyright (c) 2009 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Levels
