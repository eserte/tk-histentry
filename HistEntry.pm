# -*- perl -*-

#
# $Id: HistEntry.pm,v 1.1 1997/12/06 16:45:23 eserte Exp $
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
require Tk::Entry;
@ISA = qw(Tk::Entry);
Construct Tk::Widget 'HistEntry';

$VERSION = '0.01';

sub ClassInit {
    my ($class,$mw) = @_;
    addBind($mw);
    return $class->SUPER::ClassInit($mw);
}

sub addBind {
    my $w = shift;
    $w->bind('<Up>' => 'historyUp');
    $w->bind('<Down>' => 'historyDown');    
    $w->bind('<Control-r>' => 'searchBack');    
    $w->bind('<Control-s>' => 'searchForw');    
}

sub historyAdd {
    my($w, $line) = @_;
    $line = ${$w->cget(-textvariable)} if !defined $line;
    if ($line ne $w->{'history'}->[$#{$w->{'history'}}]) {
	push(@{$w->{'history'}}, $line);
	$w->{'historycount'} = $#{$w->{'history'}};
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

return 1 if caller();

package main;
require Tk;
$top = MainWindow->new;
$x = $top->HistEntry(-textvariable => \$bla);
$x->pack;
$x->bind('<Return>', sub { $x->historyAdd; $bla = '' });
Tk::MainLoop();
