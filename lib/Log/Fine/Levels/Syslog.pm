
=head1 NAME

Log::Fine::Levels::Syslog - Provides levels correlating to those provided by Syslog

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

use strict;
use warnings;

package Log::Fine::Levels::Syslog;

use AutoLoader;
use Carp;
use Exporter;

use base qw/ Log::Fine::Levels Exporter /;

# Necessary for AutoLoader
our $AUTOLOAD;

=head1 CONSTANTS

The following constants are provided:

=head2 LVLTOVAL_MAP

Hash ref mapping level names to their associated numeric values

=cut

# Default level-to-value hash
use constant LVLTOVAL_MAP => {
                               EMER => 0,
                               ALRT => 1,
                               CRIT => 2,
                               ERR  => 3,
                               WARN => 4,
                               NOTI => 5,
                               INFO => 6,
                               DEBG => 7
};          # LVLTOVAL_MAP{}

=head2

Hash ref mapping level values to their associated name

=cut

# Default value-to-level hash
use constant VALTOLVL_MAP => {
                               0 => "EMER",
                               1 => "ALRT",
                               2 => "CRIT",
                               3 => "ERR",
                               4 => "WARN",
                               5 => "NOTI",
                               6 => "INFO",
                               7 => "DEBG"
};          # VALTOLVL_MAP{}

=head2

Hash ref mapping Log Masks to their associated values

=cut

use constant MASK_MAP => {
                           LOGMASK_EMERG   => LVLTOVAL_MAP->{EMER} << 2,
                           LOGMASK_ALERT   => LVLTOVAL_MAP->{ALRT} << 2,
                           LOGMASK_CRIT    => LVLTOVAL_MAP->{CRIT} << 2,
                           LOGMASK_ERR     => LVLTOVAL_MAP->{ERR} << 2,
                           LOGMASK_WARNING => LVLTOVAL_MAP->{WARN} << 2,
                           LOGMASK_NOTICE  => LVLTOVAL_MAP->{NOTI} << 2,
                           LOGMASK_INFO    => LVLTOVAL_MAP->{INFO} << 2,
                           LOGMASK_DEBUG   => LVLTOVAL_MAP->{DEBG} << 2
};          # MASK_MAP{}

# --------------------------------------------------------------------

# grab appropriate refs
my $levels = LVLTOVAL_MAP;
my $masks  = MASK_MAP;

# Exported tags
our %EXPORT_TAGS = (macros => [ keys %{$levels} ],
                    masks  => [ keys %{$masks} ]);          # EXPORT_TAGS

# Exported macros
our @EXPORT    = (@{ $EXPORT_TAGS{macros} });
our @EXPORT_OK = (@{ $EXPORT_TAGS{masks} });

# functions okay to export
our %ok_fields = (%{$levels}, %{$masks});

# --------------------------------------------------------------------

=head1 CONSTRUCTOR

=head2 new()

Returns a newly constructed object

=cut

sub new
{

        my $class = shift;
        return bless { levelclass => $class }, $class;

}          # new()

# Autoloader
# --------------------------------------------------------------------

sub AUTOLOAD
{

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

    perldoc Log::Fine::Levels::Syslog

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

1;          # End of Log::Fine::Levels::Syslog

__END__

