
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
    $handle->formatter( formatter => $formatter );

    # When displaying user or group information, use the effective
    # user ID
    my $formatter = Log::Fine::Formatter::Template
        ->new(
          name             => 'template0',
          template         => "[%%TIME%%] %%USER%%@%%HOSTNAME%% %%%LEVEL%% %%MSG%%\n",
          timestamp_format => "%y-%m-%d %h:%m:%s",
          use_effective_id => 1,
    );

    # format a msg
    my $str = $formatter->format(INFO, "Resistence is futile", 1);

=head1 DESCRIPTION

The template formatter allows the user to specify the log format via a
template, using placeholders as substitutions.  This provides the user
an alternative way of formatting their log messages without the
necessity of having to write their own formatter object.

Note that if you desire speed, consider rolling your own
Log::Fine::Formatter module.

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
        my $v2l  = $self->levelMap()->valueToLevel($lvl);

        # Set skip to default if need be, then increment as calls to
        # caller() are now encapsulated in anonymous functions
        $skip = Log::Fine::Logger->LOG_SKIP_DEFAULT unless defined $skip;
        $skip++;

        # Level & message are variable values
        $tmpl =~ s/%%LEVEL%%/$v2l/ig;
        $tmpl =~ s/%%MSG%%/$msg/ig;

        # Have we set our template list yet?
        if (not defined $self->{_used_placeholders}) {

                $self->{_used_placeholders} = {};

                $self->{_used_placeholders}->{time} =
                    sub { return $self->_formatTime() }
                    if ($tmpl =~ /%%TIME%%/i);

                $self->{_used_placeholders}->{package} = sub {
                        my $skip = shift;
                        return (caller($skip))[0] || "{undef}";
                    }
                    if ($tmpl =~ /%%PACKAGE%%/i);

                $self->{_used_placeholders}->{filename} =
                    sub { return $self->{_fileName} }
                    if ($tmpl =~ /%%FILENAME%%/i);

                $self->{_used_placeholders}->{lineno} =
                    sub { my $skip = shift; return (caller($skip))[2] || 0 }
                    if ($tmpl =~ /%%LINENO%%/i);

                $self->{_used_placeholders}->{subrout} = sub {
                        my $skip = shift;
                        return (caller(++$skip))[3] || "main";
                    }
                    if ($tmpl =~ /%%SUBROUT%%/i);

                $self->{_used_placeholders}->{hostshort} =
                    sub { return (split /\./, $self->{_fullHost})[0] }
                    if ($tmpl =~ /%%HOSTSHORT%%/i);

                $self->{_used_placeholders}->{hostlong} =
                    sub { return $self->{_fullHost} }
                    if ($tmpl =~ /%%HOSTLONG%%/i);

                $self->{_used_placeholders}->{user} =
                    sub { return $self->{_userName} }
                    if ($tmpl =~ /%%USER%%/i);

                $self->{_used_placeholders}->{group} =
                    sub { return $self->{_groupName} }
                    if ($tmpl =~ /%%GROUP%%/i);

        }

        # Fill in placeholders
        foreach my $holder (keys %{ $self->{_used_placeholders} }) {
                my $value = &{ $self->{_used_placeholders}->{$holder} }($skip);
                $tmpl =~ s/%%${holder}%%/$value/ig;
        }

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

}          # _fileName

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
                $self->{_groupName} =
                    ($^O eq "MSWin32")
                    ? $ENV{EGID}   || 0
                    : getgrgid($)) || "nogroup";
        } else {
                $self->{_groupName} =
                    ($^O eq "MSWin32")
                    ? $ENV{GID} || 0
                    : getgrgid($() || "nogroup";
        }

        return $self->{_groupName};

}          # _groupName()

##
# Getter/Setter for hostname

sub _hostName
{

        my $self = shift;

        # If {_fullHost} is already cached, then return it, otherwise
        # get hostname, cache it, and return
        if (defined $self->{_fullHost} and $self->{_fullHost} =~ /\w/) {
                return $self->{_fullHost};
        } else {
                $self->{_fullHost} = hostname() || "{undef}";
                return $self->{_fullHost};
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
                $self->{_userName} =
                    ($^O eq "MSWin32")
                    ? $ENV{EUID}   || 0
                    : getpwuid($>) || "nobody";
        } else {
                $self->{_userName} = getlogin() || getpwuid($<) || "nobody";
        }

        return $self->{_userName};

}          # _userName()

=head1 MICROSOFT WINDOWS CAVEATS

Under Microsoft Windows operating systems (WinXP, Win2003, Vista,
Win7, etc), Log::Fine::Formatters::Template will use the following
environment variables for determining user and group information:

=over

=item * C<$UID>

=item * C<$EUID>

=item * C<$GID>

=item * C<$EGID>

=back

Under MS Windows, these values will invariably be set to 0.

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
