# -*- perl -*-

#
# $Id: basic.t,v 1.4 2000/01/08 23:12:50 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1997,1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

BEGIN { $^W = 1; $| = 1; $loaded = 0; $last = 19; print "1..$last\n"; }
END {print "not ok 1\n" unless $loaded;}

use Tk::HistEntry;
use strict;
use vars qw($loaded $last $VISUAL);

package main;

$loaded = 1;
$VISUAL = !$ENV{BATCH};

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
		      -label => 'Browse:',
		      -labelPack => [-side => 'top'],
		     )->pack;

print "ok " . $ok++ . "\n";
$b1->update;
print "ok " . $ok++ . "\n";
$b2->update;
print "ok " . $ok++ . "\n";

foreach my $sw ($b2->Subwidget) {
    if ($sw->isa('Tk::LabEntry')) {
	foreach my $ssw ($sw->Subwidget) {
	    if ($ssw->isa('Tk::Label')) {
		my $t = $ssw->cget(-text);
		print (($t eq 'Browse:' ? "" : "not ") . "ok " . $ok++ . "\n");
	    }
	}
    }
}

my $e1   = $b1->_entry;
print ((defined $e1 ? "" : "not ") . "ok " . $ok++ . "\n");
my $e2   = $b2->_entry;
print ((defined $e2 ? "" : "not ") . "ok " . $ok++ . "\n");

my $lb2  = $b2->_listbox;
print ((defined $lb2 ? "" : "not ") . "ok " . $ok++ . "\n");

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

$b2->addhistory('third 2');
@h2 = $b2->history;
print ((@h2 == 3 && $h2[2] eq 'third 2' ? "" : "not ") . "ok " . $ok++ . "\n");

my $h2str1 = join(", ", $lb2->get(0, 'end'));
my $h2str2 = join(", ", @h2);

print (($h2str1 eq $h2str2 ? "" : "not ") . "ok " . $ok++ . "\n");


print (($b1->can('addhistory') ? "" : "not") . "ok " . $ok++ . "\n");
print (($b1->can('historyAdd') ? "" : "not") . "ok " . $ok++ . "\n");
print (($b2->can('addhistory') ? "" : "not") . "ok " . $ok++ . "\n");
print (($b2->can('historyAdd') ? "" : "not") . "ok " . $ok++ . "\n");

MainLoop if $VISUAL;

