# -*- perl -*-

#
# $Id: HistEntry.pm,v 1.2 1997/12/06 17:31:03 eserte Exp $
# Author: Slaven Rezic
#
# Copyright © 1997 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: <URL:mailto:eserte@cs.tu-berlin.de>
# WWW:  <URL:http://www.cs.tu-berlin.de/~eserte/>
#

# XXX TODO: limit history entries

package Tk::HistEntry;
require Tk::BrowseEntry;
@ISA = qw(Tk::BrowseEntry);
Construct Tk::Widget 'HistEntry';

$VERSION = '0.10';

sub Populate {
    my($w, $args) = @_;
    $args->{'-variable'} = delete $args->{'-textvariable'} 
        if defined $args->{'-textvariable'};
#    $args->{'-browsecmd'} = sub { $w->historySet($_[0]) };
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
}

sub historyAdd {
    my($w, $line) = @_;
    $line = ${$w->cget(-textvariable)} if !defined $line;
    if ($line ne $w->{'history'}->[$#{$w->{'history'}}]) {
	push(@{$w->{'history'}}, $line);
	$w->{'historycount'} = $#{$w->{'history'}};
	$w->insert('end', $line);
    }
}

sub historyUp {
    my $w = shift;
    if ($w->{'historycount'} > 0) {
	$w->{'historycount'}--;
	${$w->cget(-textvariable)} = $w->{'history'}->[$w->{'historycount'}];
    } else {
	$w->toplevel->bell;
    }
}

sub historyDown {
    my $w = shift;
    if ($w->{'historycount'} <= $#{$w->{'history'}}) {
	$w->{'historycount'}++;
	${$w->cget(-textvariable)} = $w->{'history'}->[$w->{'historycount'}];
    } else {
	$w->toplevel->bell;
    }
}

sub historySet {
    my($w, $index) = @_;
    my $i;
    for($i = $#{$w->{'history'}}; $i >= 0; $i--) {
	if ($index eq $w->{'history'}->[$i]) {
	    $w->{'historycount'} = $i;
	    last;
	}
    }
}

# XXX search ist nicht so intuitiv wie bei gnu-readline
sub searchBack {
    my $w = shift;
    my $i = $w->{'historycount'}-1;
    while ($i >= 0) {
	my $search = ${$w->cget(-textvariable)};
        if ($search eq substr($w->{'history'}->[$i], 0, length($search))) {
	    $w->{'historycount'} = $i;
	    ${$w->cget(-textvariable)} 
                = $w->{'history'}->[$w->{'historycount'}];
            return;
        }
        $i--;
    }
    $w->toplevel->bell;
}

sub searchForw {
    my $w = shift;
    my $i = $w->{'historycount'}+1;
    while ($i <= $#{$w->{'history'}}) {
	my $search = ${$w->cget(-textvariable)};
        if ($search eq substr($w->{'history'}->[$i], 0, length($search))) {
	    $w->{'historycount'} = $i;
	    ${$w->cget(-textvariable)} 
                = $w->{'history'}->[$w->{'historycount'}];
            return;
        }
        $i++;
    }
    $w->toplevel->bell;
}

1;
