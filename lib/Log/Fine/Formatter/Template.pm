
=head1 NAME

Log::Fine::Formatter::Template - Format log messages using template

=head1 SYNOPSIS

Formats log messages for output using a user-defined template spec.

    use Log::Fine::Formatter::Template;
    use Log::Fine::Handle::Console;

    # instantiate a handle
    my $handle = Log::Fine::Handle::Console->new();

    # instantiate a formatter
    my $formatter = Log::Fine::Formatter::Template
        ->new(
          name             => 'template0',
          template         => "[%%TIME%%] %%LEVEL%% (%%FILENAME%%:%%LINENO%%) %%MSG%%\n",
          timestamp_format => "%y-%m-%d %h:%m:%s"
    );

    # set the formatter
    $handle->setFormatter( formatter => $formatter );

    # When displaying user or group information, use the effective
    # user ID
    my $formatter = Log::Fine::Formatter::Template
        ->new(
          name             => 'template0',
          template         => "[%%TIME%%] %%USER%%@%%HOSTNAME%% %%%LEVEL%% %%MSG%%\n",
          timestamp_format => "%y-%m-%d %h:%m:%s",
          use_effective_id => 1,
    );

=head1 DESCRIPTION

The template formatter allows the user to specify the log format via a
template, using placeholders as substitutions.  This provides the user
an alternative way of formatting their log messages without the
necessity of having to write their own formatter object.

=cut

use strict;
use warnings;

package Log::Fine::Formatter::Template;

use base qw( Log::Fine::Formatter );

use Log::Fine;
use Log::Fine::Formatter;
use Log::Fine::Levels;

our $VERSION = $Log::Fine::Formatter::VERSION;

use File::Basename;
use Sys::Hostname;

=head1 SUPPORTED PLACEHOLDERS

Placeholders are case-insensitive.  C<%%msg%%> will work just as well
as C<%%MSG%%>

    +---------------+-----------------------------------+
    | %%TIME%%      | Timestamp                         |
    +---------------+-----------------------------------+
    | %%LEVEL%%     | Log Level                         |
    +---------------+-----------------------------------+
    | %%MSG%%       | Log Message                       |
    +---------------+-----------------------------------+
    | %%PACKAGE%%   | Caller package                    |
    +---------------+-----------------------------------+
    | %%FILENAME%%  | Caller filename                   |
    +---------------+-----------------------------------+
    | %%LINENO%%    | Caller line number                |
    +---------------+-----------------------------------+
    | %%SUBROUT%%   | Caller Subroutine                 |
    +---------------+-----------------------------------+
    | %%HOSTLONG%%  | Long Hostname including domain    |
    +---------------+-----------------------------------+
    | %%HOSTSHORT%% | Short Hostname                    |
    +---------------+-----------------------------------+
    | %$%LOGIN%%    | User Login                        |
    +---------------+-----------------------------------+
    | %%GROUP%%     | User Group                        |
    +---------------+-----------------------------------+

=head1 METHODS

=head2 format

Formats the given message for the given level

=head3 Parameters

=over

=item  * level

Level at which to log (see L<Log::Fine::Levels>)

=item  * message

Message to log

=item  * skip

Controls caller skip level

=back

=head3 Returns

The formatted log message as specified by {template}

=cut

sub format
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;
        my $tmpl = $self->{template};

        # Set skip to default if need be
        $skip = Log::Fine::Logger->LOG_SKIP_DEFAULT unless (defined $skip);

        # get the caller information
        my @c         = caller($skip);
        my @subr      = split /::/, $c[3] || "main()";
        my $now       = $self->_formatTime();
        my $lname     = $self->levelMap()->valueToLevel($lvl);
        my $subname   = pop @subr || "{undef}";
        my $package   = join "::", @subr;
        my $filename  = $self->_fileName();
        my $lineno    = $c[2] || 0;
        my $hostname  = $self->_hostName();
        my $shorthost = (split /\./, $hostname)[0];
        my $user      = $self->_userName();
        my $group     = $self->_groupName();

        # Run through template, formatting as appropriate
        $tmpl =~ s/%%TIME%%/$now/ig;
        $tmpl =~ s/%%LEVEL%%/$lname/ig;
        $tmpl =~ s/%%MSG%%/$msg/ig;
        $tmpl =~ s/%%PACKAGE%%/$package/ig;
        $tmpl =~ s/%%FILENAME%%/$filename/ig;
        $tmpl =~ s/%%LINENO%%/$lineno/ig;
        $tmpl =~ s/%%SUBROUT%%/$subname/ig;
        $tmpl =~ s/%%HOSTSHORT%%/$shorthost/ig;
        $tmpl =~ s/%%HOSTLONG%%/$hostname/ig;
        $tmpl =~ s/%%USER%%/$user/ig;
        $tmpl =~ s/%%GROUP%%/$group/ig;

        # return the formatted string
        return $tmpl;

}          # format()

# --------------------------------------------------------------------

##
# Initializer for this object

sub _init
{

        my $self = shift;

        # perform super initializations
        $self->SUPER::_init();

        # Make sure that template is defined
        $self->_fatal("No template specified")
            unless (defined $self->{template}
                    and $self->{template} =~ /\w/);

        # Set use_effective_id to default
        $self->{use_effective_id} = 1
            unless (defined $self->{use_effective_id}
                    and $self->{use_effective_id} =~ /\d/);

        # Set use_effective_id to default
        $self->{use_effective_id} = 1
            unless (defined $self->{use_effective_id}
                    and $self->{use_effective_id} =~ /\d/);

        # Set up some defaults
        $self->_fileName();
        $self->_groupName();
        $self->_hostName();
        $self->_userName();

        # Victory
        return $self;

}          # _init()

##
# Getter/Setter for fileName

sub _fileName
{

        my $self = shift;

        # If {_fileName} is already cached, then return it, otherwise
        # get the file name, cache it, and return
        if (defined $self->{_fileName} and $self->{_fileName} =~ /\w/) {
                return $self->{_fileName};
        } else {
                $self->{_fileName} = basename $0;
                return $self->{_fileName};
        }

        #
        # NOT REACHED
        #

} # _fileName

##
# Getter/Setter for group

sub _groupName
{

        my $self = shift;

        # If {_groupName} is already cached, then return it, otherwise get
        # the group name, cache it, and return
        if (defined $self->{_groupName} and $self->{_groupName} =~ /\w/) {
                return $self->{_groupName};
        } elsif ($self->{use_effective_id}) {
                $self->{_groupName} = getgrgid($)) || "nogroup";
        } else {
                $self->{_groupName} = getgrgid($() || "nogroup";
        }

        return $self->{_groupName};

}          # _groupName()

##
# Getter/Setter for hostname

sub _hostName
{

        my $self = shift;

        # If {_fullhost} is already cached, then return it, otherwise
        # get hostname, cache it, and return
        if (defined $self->{_fullhost} and $self->{_fullhost} =~ /\w/) {
                return $self->{_fullhost};
        } else {
                $self->{_fullhost} = hostname() || "{undef}";
                return $self->{_fullhost};
        }

        #
        # NOT REACHED
        #

}          # _hostName()

##
# Getter/Setter for user name

sub _userName
{

        my $self = shift;

        # If {_userName} is already cached, then return it, otherwise get
        # the user name, cache it, and return
        if (defined $self->{_userName} and $self->{_userName} =~ /\w/) {
                return $self->{_userName};
        } elsif ($self->{use_effective_id}) {
                $self->{_userName} = getpwuid($>) || "nobody";
        } else {
                $self->{_userName} = getlogin() || getpwuid($<) || "nobody";
        }

        return $self->{_userName};

}          # _userName()

=head1 SEE ALSO

L<perl>, L<Log::Fine::Formatter>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-formatter-template at rt.cpan.org>, or through the web interface at
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

Copyright (c) 2008, 2009, 2010 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Formatter::Template
