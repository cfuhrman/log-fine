
=head1 NAME

Log::Fine::Levels - Define variable logging levels

=head1 SYNOPSIS

Provides logging level translations



=head1 DESCRIPTION



=cut

use strict;
use warnings;

package Log::Fine::Levels;

use Carp;

our $AUTOLOAD;
our @EXPORT = qw( getLevels setLevels );
our @EXPORT_OK = qw( getLvlFromVal getValFromLvl );

# Private Methods
# --------------------------------------------------------------------

{
	my $callCount = 0;
	my $lvltoval = {};
	my $valtolvl = {};

	sub _getCallCount { return $callCount };
	sub _getLvltoVal { return $lvltoval }
	sub _getValtoLvl { return $valtolvl }
	sub _incrCallCount { $callCount++ };
	sub _setLvltoVal { $lvltoval = shift }
	sub _setValtoLvl { $valtolvl = shift }
}

# --------------------------------------------------------------------

=head1 METHODS

=head2 new

Creates a new Log::Fine::Levels object

=cut

sub new
{

	my $class = shift;
	my %h     = @_;

        # if $class is already an object, then return the object
        return $class if (ref $class and $class->isa("Log::Fine::Levels"));

        # bless the hash into a class
        my $self = bless \%h, $class;

	# check for custom levels
	$self->setLevels($self->{levels})
		if (exists $self->{levels} and ref $self->{levels} eq "HASH");

	# return the bless'd object
	return $self;

} # new()

=head2 getLvlFromVal($value)

Gets the matching level string from the given numerical value

=cut

sub getLvlFromVal
{
	my $hash = _getLvltoVal();
	return $hash->{$_[0]};
} # getLvlFromVal()

=head2 getValFromLvl($level)

Gets the matching numeric value for the given level

=cut

sub getValFromLvl
{
	my $hash = _getValtoLvl();
	return $hash->{$_[0]};
} # getValFromLvl()

=head2 getLevels()

Returns a list of supported levels

=cut

sub getLevels
{
	my $keys = _getLvltoVal();
	return keys %{$keys};
}

=head2 setLevels($levels)

Set Levels for this class from a hash of level keyword to number pairs.

=cut

sub setLevels
{

	my $self   = shift;
	my $levels = shift;

	# validate levels
	croak "First parameter must be a valid hash ref"
		unless(defined $levels and ref $levels eq "HASH" and scalar keys %{$levels} > 0);

	# level-to-value hash
	my $values = {};

	# construct ValtoLvl hash
	foreach my $level (keys %{$levels}) {

		# validate level and value
		croak "Invalid keypair $level -> $levels->{$level}"
			unless(defined $level and defined $levels->{$level} and $level =~ /\w+/ and $levels->{$level} =~ /\d+/);

		# set the value
		$values->{$levels->{$level}} = $level;

	}

	# warn if we are called more than once
	carp "setLevels() called more than once!";

	# now set appropriate hashes
	_setLvlToVal($values);
	_setValToLvl($levels);

} # setLevels()

# AutoLoader
# --------------------------------------------------------------------

sub AUTOLOAD
{

	my $self = shift;

	# Get the method name
	my $name = $AUTOLOAD;

	# strip out package prefix
	$name =~ s/.*://; 

	# make sure we have a valid function
	croak "Invalid function $name"
		unless (defined $levels->{$name});

	# evaluate and return the appropriate level
	eval "sub $name { return $levels->{$name }";
	goto &$name;
vv
} # AUTOLOAD()

=head1 SEE ALSO

L<perl>, L<strftime>, L<Log::Fine>, L<Time::HiRes>

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

1;          # End of Log::Fine::Formatter

__END__
