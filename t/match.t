# -*- perl -*-

#
# $Id: match.t,v 1.2 1998/08/28 11:54:20 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1997,1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

use Test;
use Tk;
use Tk::HistEntry;
use strict;

BEGIN { plan tests => 2, todo => [2] }

my $top = new MainWindow;
$top->geometry($top->screenwidth . "x" .$top->screenheight . "+0+0");

my $he = $top->HistEntry(-match => 1,
			)->pack;

$he->addhistory('Slaven');
$he->addhistory('Rezic');
my $e = $he->_entry;
$e->focus;
$e->update;
eval {
    $e->event('generate', '<KeyPress>', -keysym => 'S');
    $e->event('generate', '<KeyPress>', -keysym => 'l');
    $e->update;
};
skip($@, $e->get eq 'Slaven');

eval {
    $e->event('generate', '<KeyPress>', -keysym => 'BackSpace');
    $e->update;
};
#warn $e->get;
skip ($@, $e->get eq 'S');

#MainLoop;
