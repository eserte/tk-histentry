# -*- perl -*-

#
# $Id: HistEntry.pm,v 1.5 1997/12/11 00:10:25 eserte Exp $
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
require Tk::BrowseEntry;
@ISA = qw(Tk::Derived Tk::BrowseEntry);
Construct Tk::Widget 'HistEntry';

$VERSION = '0.11';

sub Populate {
    my($w, $args) = @_;
    $args->{'-variable'} = delete $args->{'-textvariable'} 
        if defined $args->{'-textvariable'};
    $w->{Configure}{-command} = delete $args->{'-command'};
    $w->{Configure}{-dup}     = delete $args->{'-dup'};
    $w->{Configure}{-bell}    =
      (!exists $args->{'-bell'} ? 1 : delete $args->{'-bell'});
    # $args->{'-browsecmd'} = sub { $w->historySet($_[1]) };
    $w->SUPER::Populate($args);
}

sub SetBindtags {
    my($w) = @_;
    $w->addBind;
    $w->SUPER::SetBindtags;
}

sub addBind {
    my $w = shift;
    $w->bind('<Up>'        => sub { $w->historyUp });
    $w->bind('<Down>'      => sub { $w->historyDown });
    $w->bind('<Control-r>' => sub { $w->searchBack });
    $w->bind('<Control-s>' => sub { $w->searchForw });
    if ($w->{Configure}{-command}) {
	$w->bind('<Return>' => sub { $w->invoke });
    }
}

sub historyAdd {
    my($w, $line) = @_;
    $line = ${$w->cget(-textvariable)} if !defined $line;
    if ($w->{Configure}{-dup} 
	|| $line ne $w->{'history'}->[$#{$w->{'history'}}]) {
	push(@{$w->{'history'}}, $line);
	$w->{'historyindex'} = $#{$w->{'history'}} + 1;
	$w->insert('end', $line);
	$w->Subwidget('slistbox')->see('end');
    }
}

sub historyUp {
    my $w = shift;
    if ($w->{'historyindex'} > 0) {
	$w->{'historyindex'}--;
	${$w->cget(-textvariable)} = $w->{'history'}->[$w->{'historyindex'}];
    } else {
	$w->_bell;
    }
}

sub historyDown {
    my $w = shift;
    if ($w->{'historyindex'} <= $#{$w->{'history'}}) {
	$w->{'historyindex'}++;
	${$w->cget(-textvariable)} = $w->{'history'}->[$w->{'historyindex'}];
    } else {
	$w->_bell;
    }
}

sub historySet {
    my($w, $index) = @_;
    my $i;
    for($i = $#{$w->{'history'}}; $i >= 0; $i--) {
	if ($index eq $w->{'history'}->[$i]) {
	    $w->{'historyindex'} = $i;
	    last;
	}
    }
}

sub searchBack {
    my $w = shift;
    my $i = $w->{'historyindex'}-1;
    while ($i >= 0) {
	my $search = $ {$w->cget(-textvariable)};
        if ($search eq substr($w->{'history'}->[$i], 0, length($search))) {
	    $w->{'historyindex'} = $i;
	    $ {$w->cget(-textvariable)} 
                = $w->{'history'}->[$w->{'historyindex'}];
            return;
        }
        $i--;
    }
    $w->_bell;
}

sub searchForw {
    my $w = shift;
    my $i = $w->{'historyindex'}+1;
    while ($i <= $#{$w->{'history'}}) {
	my $search = $ {$w->cget(-textvariable)};
        if ($search eq substr($w->{'history'}->[$i], 0, length($search))) {
	    $w->{'historyindex'} = $i;
	    $ {$w->cget(-textvariable)} 
                = $w->{'history'}->[$w->{'historyindex'}];
            return;
        }
        $i++;
    }
    $w->_bell;
}

sub invoke {
    my($w) = @_;
    return unless defined $ {$w->cget(-textvariable)};
    $w->historyAdd($ {$w->cget(-textvariable)});
    &{$w->{Configure}{-command}}($w);
}

sub _bell {
    my $w = shift;
    return unless $w->{Configure}{-bell};
    $w->bell;
}

1;

=head1 NAME

Tk::HistEntry - Entry widget with history capability

=head1 SYNOPSIS

    use Tk::HistEntry;

    $hist = $top->HistEntry( ... );

=head1 DESCRIPTION

TODO

=head1 BUGS/TODO

 - limit history entries
 - C-s/C-r do not work as nice as in gnu readline
  - use -browsecmd from Tk::BrowseEntry

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

Copyright (c) 1997 Slaven Rezic. All rights reserved.
This package is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
