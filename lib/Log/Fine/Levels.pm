
=head1 NAME

Log::Fine::Levels - Define variable logging levels

=head1 SYNOPSIS

Provides logging level translations

    use Log::Fine::Levels;

    # instantiate a levels object
    my $levels = Log::Fine::Levels->new();

    # instantiate a levels object using java.utils.logging log levels
    my $javalevels = {
                       "SEVERE"  => 0,
                       "WARNING" => 1,
                       "INFO"    => 2,
                       "CONFIG"  => 3,
                       "FINE"    => 4,
                       "FINER"   => 5,
                       "FINEST"  => 6
    };

    my $levels = Log::Fine::Levels->new( levels => $javalevels );

    # Using levels with Log::Fine
    my $logger = Log::Fine->getLogger();

    $logger->log( $lvl->INFO, "No matter where you go, there you are" );

    # Get a list of supported levels
    my @levels = $levels->getLevels();

    # Get a Level from a Value
    my $level = $levels->getLvlFromVal(2); # Using the java example
                                           # above, this would return
                                           # "INFO"

    # Get a Value from a Level
    my $level = $levels->getValFromLvl("FINER") # Returns 5


=head1 DESCRIPTION

Log::Fine::Levels provides an object-oriented way to access levels.
Please note that this module I<does not> export given levels
dynamically, rather they must be accessed via the constructed object
as so:

    $log->log( $lvl->CRIT, "The angels have my blue box" );

Levels are kept in a shared namespace.  As such, redefining levels on
the fly is B<strongly> discouraged.

=cut

use strict;
use warnings;

package Log::Fine::Levels;

use Carp;

our $AUTOLOAD;

use vars qw( %ok_fields );

=head2 Default Levels

Default levels are similar to those found in Log::Fine:

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

=cut

# Default level-to-value hash
use constant DEFAULT_LVLTOVAL => {
                                   EMER => 0,
                                   ALRT => 1,
                                   CRIT => 2,
                                   ERR  => 3,
                                   WARN => 4,
                                   NOTI => 5,
                                   INFO => 6,
                                   DEBG => 7
};          # DEFAULT_LVLTOVAL{}

# Default value-to-level hash
use constant DEFAULT_VALTOLVL => {
                                   0 => "EMER",
                                   1 => "ALRT",
                                   2 => "CRIT",
                                   3 => "ERR",
                                   4 => "WARN",
                                   5 => "NOTI",
                                   6 => "INFO",
                                   7 => "DEBG"
};          # DEFAULT_VALTOLVL{}

# Private Methods
# --------------------------------------------------------------------

{
        my $callCount = 0;

        my $lvltoval = DEFAULT_LVLTOVAL;
        my $valtolvl = DEFAULT_VALTOLVL;

        sub _getCallCount  { return $callCount }
        sub _getLvltoVal   { return $lvltoval }
        sub _getValtoLvl   { return $valtolvl }
        sub _incrCallCount { $callCount++ }
        sub _setLvltoVal   { $lvltoval = shift }
        sub _setValtoLvl   { $valtolvl = shift }
}

# --------------------------------------------------------------------

=head1 METHODS

=head2 new

Creates a new Log::Fine::Levels object

=cut

sub new
{

        my $class = shift;
        my %data  = @_;
        my $obj   = {};

        # if $class is already an object, then return the object
        return $class if (ref $class and $class->isa("Log::Fine::Levels"));

        # bless the hash into a class
        my $self = bless $obj, $class;

        # check for custom levels
        $self->setLevels($data{levels})
            if (defined $data{levels} and ref $data{levels} eq "HASH");

        # populate our ok_to_export hash
        my $levels = _getLvltoVal;
        %ok_fields = %{$levels};

        # return the bless'd object
        return $self;

}          # new()

=head2 getLvlFromVal($value)

Gets the matching level string from the given numerical value

=cut

sub getLvlFromVal
{

        my $self = shift;
        my $val  = shift;
        my $hash = _getValtoLvl();

        return $hash->{$val};

}          # getLvlFromVal()

=head2 getValFromLvl($level)

Gets the matching numeric value for the given level

=cut

sub getValFromLvl
{

        my $self = shift;
        my $lvl  = shift;
        my $hash = _getLvltoVal();

        return $hash->{$lvl};

}          # getValFromLvl()

=head2 getLevels()

Returns a list of supported levels

=cut

sub getLevels
{
        my $keys = _getLvltoVal();
        return keys %{$keys};
}          # getLevels()

=head2 setLevels($levels)

Set Levels for this class from a hash of level keyword to number
pairs.  B<NOTE:> Use of C<setLevels()> is highly discouraged outside
of any class chosing to override Log::Fine::Levels.

=cut

sub setLevels
{

        my $self   = shift;
        my $levels = shift;

        # validate levels
        croak "First parameter must be a valid hash ref"
            unless (    defined $levels
                    and ref $levels eq "HASH"
                    and scalar keys %{$levels} > 0);

        # level-to-value hash
        my $values = {};

        # construct ValtoLvl hash
        foreach my $level (keys %{$levels}) {

                # validate level and value
                croak "Invalid keypair $level -> $levels->{$level}"
                    unless (    defined $level
                            and defined $levels->{$level}
                            and $level            =~ /\w+/
                            and $levels->{$level} =~ /\d+/);

                # set the value
                $values->{ $levels->{$level} } = $level;

        }

        # warn if we are called more than once
        carp "setLevels() called more than once!"
            if (_getCallCount() > 0);

        # now set appropriate hashes
        _setLvltoVal($levels);
        _setValtoLvl($values);

        # set ok_fields
        %ok_fields = %{$levels};

        # Bump up callcount
        _incrCallCount();

}          # setLevels()

# AutoLoader
# --------------------------------------------------------------------

sub AUTOLOAD
{

        my $self = shift;
        my $type = ref $self;

        # Get the method name
        my $name = $AUTOLOAD;

        # strip out package prefix
        $name =~ s/.*://;

        # Return on DESTROY
        return if $name eq 'DESTROY';

        # make sure we have a valid function
        croak "Invalid function $name"
            unless (exists $ok_fields{$name});

        # evaluate and return the appropriate level
        eval "sub $name { return $ok_fields{$name} }";
        goto &$name;

}          # AUTOLOAD()

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

