# -*- perl -*-

#
# $Id: HistEntry.pm,v 1.11 1998/08/04 18:05:40 eserte Exp $
# Author: Slaven Rezic
#
# Copyright © 1997 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: <URL:mailto:eserte@cs.tu-berlin.de>
# WWW:  <URL:http://www.cs.tu-berlin.de/~eserte/>
#

package Tk::HistEntry;
require Tk;
use strict;
use vars qw($VERSION);

$VERSION = '0.23';

sub addBind {
    my $w = shift;

    $w->bind('<Up>'        => sub { $w->historyUp });
    $w->bind('<Control-p>' => sub { $w->historyUp });
    $w->bind('<Down>'      => sub { $w->historyDown });
    $w->bind('<Control-n>' => sub { $w->historyDown });

    $w->bind('<Meta-less>'    => sub { $w->historyBegin });
    $w->bind('<Alt-less>'     => sub { $w->historyBegin });
    $w->bind('<Meta-greater>' => sub { $w->historyEnd });
    $w->bind('<Alt-greater>'  => sub { $w->historyEnd });

    $w->bind('<Control-r>' => sub { $w->searchBack });
    $w->bind('<Control-s>' => sub { $w->searchForw });

    $w->bind('<Return>' => sub { 
		 if ($w->cget(-command) || $w->cget(-auto)) {
		     $w->invoke;
		 }
	     });
}

sub _isdup {
    my($w, $string) = @_;
    foreach (@{ $w->privateData->{'history'} }) {
	return 1 if $_ eq $string;
    }
    0;
}

sub historyAdd {
    my($w, $string) = @_;
    $string = $ {$w->cget(-textvariable)} if !defined $string;
    return undef if !defined $string || $string eq '';
    my $history_ref = $w->privateData->{'history'};
    if ((!@{ $history_ref } or $string ne $history_ref->[$#$history_ref])
	and ($w->cget(-dup) or !$w->_isdup($string))) {
	push @{ $history_ref }, $string;
	if (defined $w->cget(-limit) &&
	    @{ $history_ref } > $w->cget(-limit)) {
	    shift @{ $history_ref };
	}
	$w->privateData->{'historyindex'} = $#$history_ref + 1;
	return $string;
    }
    undef;
}
# compatibility with Term::ReadLine
*addhistory = \&historyAdd;

sub historyUpdate {
    my $w = shift;
    $ {$w->cget(-textvariable)} =
      $w->privateData->{'history'}->[$w->privateData->{'historyindex'}];
    $w->icursor('end'); # suggestion by Jason Smith <smithj4@rpi.edu>
}

sub historyUp {
    my $w = shift;
    if ($w->privateData->{'historyindex'} > 0) {
        $w->privateData->{'historyindex'}--;
	$w->historyUpdate;
    } else {
	$w->_bell;
    }
}

sub historyDown {
    my $w = shift;
    if ($w->privateData->{'historyindex'} <= $#{$w->privateData->{'history'}}) {
	$w->privateData->{'historyindex'}++;
	$w->historyUpdate;
    } else {
	$w->_bell;
    }
}

sub historyBegin {
    my $w = shift;
    $w->privateData->{'historyindex'} = 0;
    $w->historyUpdate;
}

sub historyEnd {
    my $w = shift;
    $w->privateData->{'historyindex'} = $#{$w->privateData->{'history'}};
    $w->historyUpdate;
}

sub historySet {
    my($w, $index) = @_;
    my $i;
    my $history_ref = $w->privateData->{'history'};
    for($i = $#{ $history_ref }; $i >= 0; $i--) {
	if ($index eq $history_ref->[$i]) {
	    $w->privateData->{'historyindex'} = $i;
	    last;
	}
    }
}

sub historyReset {
    my $w = shift;
    $w->privateData->{'history'} = [];
    $w->privateData->{'historyindex'} = 0;
}

sub history {
    my($w, $history) = @_;
    if (defined $history) {
	$w->privateData->{'history'} = [ @$history ];
	$w->privateData->{'historyindex'} =
	  $#{$w->privateData->{'history'}} + 1;
    }
    @{ $w->privateData->{'history'} };
}

sub searchBack {
    my $w = shift;
    my $i = $w->privateData->{'historyindex'}-1;
    while ($i >= 0) {
	my $search = $ {$w->cget(-textvariable)};
        if ($search eq substr($w->privateData->{'history'}->[$i], 0,
			      length($search))) {
	    $w->privateData->{'historyindex'} = $i;
	    $ {$w->cget(-textvariable)} 
                = $w->privateData->{'history'}->[$w->privateData->{'historyindex'}];
            return;
        }
        $i--;
    }
    $w->_bell;
}

sub searchForw {
    my $w = shift;
    my $i = $w->privateData->{'historyindex'}+1;
    while ($i <= $#{$w->privateData->{'history'}}) {
	my $search = $ {$w->cget(-textvariable)};
        if ($search eq substr($w->privateData->{'history'}->[$i], 0,
			      length($search))) {
	    $w->privateData->{'historyindex'} = $i;
	    $ {$w->cget(-textvariable)} 
                = $w->privateData->{'history'}->[$w->privateData->{'historyindex'}];
            return;
        }
        $i++;
    }
    $w->_bell;
}

sub invoke {
    my($w, $string) = @_;
    $string = $ {$w->cget(-textvariable)} if !defined $string;
    return unless defined $string;
    my $added = defined $w->historyAdd($string);
    $w->Callback(-command => $w, $string, $added);
}

sub _bell {
    my $w = shift;
    return unless $w->cget(-bell);
    $w->bell;
}

######################################################################

package Tk::HistEntry::Simple;
require Tk::Entry;
use vars qw(@ISA);
@ISA = qw(Tk::Derived Tk::Entry Tk::HistEntry);
Construct Tk::Widget 'SimpleHistEntry';

sub InitObject {
    my($w, $args) = @_;
    $w->SUPER::InitObject($args);
    $w->addBind;
}

sub Populate {
    my($w, $args) = @_;

    $w->historyReset;

    $w->SUPER::Populate($args);

    $w->ConfigSpecs
      (-command => ['CALLBACK', 'command', 'Command', undef],
       -auto    => ['PASSIVE',  'auto',    'Auto',    0],
       -dup     => ['PASSIVE',  'dup',     'Dup',     1],
       -bell    => ['PASSIVE',  'bell',    'Bell',    1],
       -limit   => ['PASSIVE',  'limit',   'Limit',   undef],

      );

    $w;
}

######################################################################
package Tk::HistEntry::Browse;
require Tk::BrowseEntry;
use vars qw(@ISA);
@ISA = qw(Tk::Derived Tk::BrowseEntry Tk::HistEntry);
Construct Tk::Widget 'HistEntry';

sub InitObject {
    my($w, $args) = @_;
    $w->SUPER::InitObject($args);
    $w->addBind;
}

sub Populate {
    my($w, $args) = @_;

    $w->historyReset;

    if ($Tk::VERSION >= 800) {
	$w->SUPER::Populate($args);
    } else {
	my $saveargs;
	foreach (qw(-command -dup -bell -limit)) {
	    if (exists $args->{$_}) {
		$saveargs->{$_} = delete $args->{$_};
	    }
	}
	$w->SUPER::Populate($args);
	foreach (keys %$saveargs) {
	    $args->{$_} = $saveargs->{$_};
	}
    }

    $w->ConfigSpecs
      (-command => ['CALLBACK', 'command', 'Command', undef],
       -auto    => ['PASSIVE',  'auto',    'Auto',    0],
       -dup     => ['PASSIVE',  'dup',     'Dup',     0],
       -bell    => ['PASSIVE',  'bell',    'Bell',    1],
       -limit   => ['PASSIVE',  'limit',   'Limit',   undef],
      );

    $w;
}

sub historyAdd {
    my($w, $string) = @_;
    if (defined($string = $w->SUPER::historyAdd($string))) {
	$w->insert('end', $string);
	# XXX Obeying -limit also for the array itself?
	if (defined $w->cget(-limit) &&
	    $w->Subwidget('slistbox')->size > $w->cget(-limit)) {
	    $w->delete(0);
	}
	$w->Subwidget('slistbox')->see('end');
	return $string;
    }
    undef;
}

sub history {
    my($w, $history) = @_;
    if (defined $history) {
	$w->Subwidget('slistbox')->delete(0, 'end');
	$w->Subwidget('slistbox')->insert('end', @$history);
	$w->Subwidget('slistbox')->see('end');
    }
    $w->SUPER::history($history);
}

1;

=head1 NAME

Tk::HistEntry - Entry widget with history capability

=head1 SYNOPSIS

    use Tk::HistEntry;

    $hist1 = $top->HistEntry(-textvariable => \$var1);
    $hist2 = $top->SimpleHistEntry(-textvariable => \$var2);

=head1 DESCRIPTION

C<Tk::HistEntry> defines entry widgets with history capabilities. The widgets
come in two flavours:

=over 4

=item C<HistEntry> (in package C<Tk::HistEntry::Browse>) - with associated
browse entry

=item C<SimpleHistEntry> (in package C<Tk::HistEntry::Simple>) - plain widget
without browse entry

=back

The user may browse with the B<Up> and B<Down> keys through the history list.
New history entries may be added either manually by binding the
B<Return> key to B<historyAdd()> or
automatically by setting the B<-command> option.

=head1 OPTIONS

B<HistEntry> is an descendant of B<BrowseEntry> and thus supports all of its
standard options.

B<SimpleHistEntry> is an descendant of B<Entry> and supports all of the
B<Entry> options.

In addition, the widgets support following specific options:

=over 4

=item B<-textvariable> or B<-variable>

Variable which is tied to the HistEntry widget. Either B<-textvariable> (like
in Entry) or B<-variable> (like in BrowseEntry) may be used.

=item B<-command>

Specifies a callback, which is executed when the Return key was pressed or
the B<invoke> method is called. The callback reveives three arguments:
the reference to the HistEntry widget, the current textvariable value and
a boolean value, which tells whether the string was added to the history
list (e.g. duplicates and empty values are not added to the history list).

=item B<-dup>

Specifies whether duplicate entries are allowed in the history list. Defaults
to true.

=item B<-bell>

If set to true, rings the bell if the user tries to move off of the history
or if a search was not successful. Defaults to true.

=item B<-limit>

Limits the number of history entries. Defaults to unlimited.

=back

=head1 METHODS

=over 4

=item B<historyAdd(>[I<string>]B<)>

Adds string (or the current textvariable value if not set) manually to the
history list. B<addhistory> is an alias for B<historyAdd>. Returns the
added string or undef if no addition was made.

=item B<invoke(>[I<string>]B<)>

Invokes the command specified with B<-command>.

=item B<history(>[I<arrayref>]B<)>

Without argument, returns the current history list. With argument (a
reference to an array), replaces the history list.

=back

=head1 KEY BINDINGS

=over 4

=item B<Up>, B<Control-p>

Selects the previous history entry.

=item B<Down>, B<Control-n>

Selects the next history entry.

=item B<Meta-E<lt>>, B<Alt-E<lt>>

Selects first entry.

=item B<Meta-E<gt>>, B<Alt-E<gt>>

Selects last entry.

=item B<Control-r>

The current content of the widget is searched backward in the history.

=item B<Control-s>

The current content of the widget is searched forward in the history.

=item B<Return>

If B<-command> is set, adds current content to the history list and
executes the associated callback.

=back

=head1 EXAMPLE

    use Tk;
    use Tk::HistEntry;

    $top = new MainWindow;
    $he = $top->HistEntry(-textvariable => \$foo,
                          -command => sub {
                              # automatically adds $foo to history
                              print STDERR "Do something with $foo\n";
                          })->pack;
    $b = $top->Button(-text => 'Do it',
                      -command => sub { $he->invoke })->pack;
    MainLoop;

=head1 BUGS/TODO

 - C-s/C-r do not work as nice as in gnu readline
 - use -browsecmd from Tk::BrowseEntry
 - use Tie::Array if present

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

=head1 COPYRIGHT

Copyright (c) 1997 Slaven Rezic. All rights reserved.
This package is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
