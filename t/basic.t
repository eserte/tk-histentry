# -*- perl -*-

#
# $Id: basic.t,v 1.1 1998/05/20 08:38:20 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1997,1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

BEGIN { $^W = 1; $| = 1; $loaded = 0; $last = 9; print "1..$last\n"; }
END {print "not ok 1\n" unless $loaded;}

use Tk::HistEntry;
use strict;
use vars qw($loaded $last $VISUAL);

$loaded = 1;
$VISUAL = 0;

my $ok = 1;
print "ok " . $ok++ . "\n";

use Tk;

my $top = new MainWindow;

my($foo, $bla);

my($b1, $b2);
$b1 = $top->SimpleHistEntry(-textvariable => \$foo,
			    -bell => 1,
			    -dup => 1,
			   )->pack;
print "ok " . $ok++ . "\n";
$b2 = $top->HistEntry(-textvariable => \$bla,
		      -bell => 1,
		      -dup => 1,
		     )->pack;
print "ok " . $ok++ . "\n";
$b1->update;
print "ok " . $ok++ . "\n";
$b2->update;
print "ok " . $ok++ . "\n";

my $e1   = $b1;
my $e2   = $b2->Subwidget('entry');

$e1->insert(0, 'first 1');
$b1->historyAdd;
my @h1 = $b1->history;
print ((@h1 == 1 && $h1[0] eq 'first 1' ? "" : "not ") . "ok " . $ok++ . "\n");

$b1->historyAdd('second 1');
@h1 = $b1->history;
print ((@h1 == 2 && $h1[1] eq 'second 1' ? "" : "not ") . "ok " . $ok++ . "\n");

$e2->insert(0, 'first 2');
$b2->historyAdd;
my @h2 = $b2->history;
print ((@h2 == 1 && $h2[0] eq 'first 2' ? "" : "not ") . "ok " . $ok++ . "\n");

$b2->historyAdd('second 2');
@h2 = $b2->history;
print ((@h2 == 2 && $h2[1] eq 'second 2' ? "" : "not ") . "ok " . $ok++ . "\n");

#MainLoop;

