# -*- perl -*-

#
# $Id: basic.t,v 1.6 2000/07/06 00:01:38 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1997,1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

BEGIN { $^W = 1; $| = 1; $loaded = 0; $last = 25; print "1..$last\n"; }
END {print "not ok 1\n" unless $loaded;}

use Tk::HistEntry;
use strict;
use vars qw($loaded $last $VISUAL);
use FindBin;

chdir "$FindBin::RealBin";

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


my @test_values = qw(bla foo bar);

my($b4) = $top->HistEntry->pack;
foreach (@test_values) { $b4->historyAdd($_) }
if (join(",", @test_values) ne join(",", $b4->history)) {
    print "not ";
}
print "ok " . $ok++ . "\n";

$b4->_entry->insert("end", "blubber");
$b4->addhistory();
if (join(",", @test_values, "blubber") ne join(",", $b4->history)) {
    print "not ";
}
print "ok " . $ok++ . "\n";

$b4->OnDestroy(sub { $b4->historySave("hist.tmp.save") });


my($b5) = $top->SimpleHistEntry->pack;
foreach (@test_values) { $b5->historyAdd($_) }
if (join(",", @test_values) ne join(",", $b5->history)) {
    print "not ";
}
print "ok " . $ok++ . "\n";

$b5->insert("end", "blubber");
$b5->addhistory();
if (join(",", @test_values, "blubber") ne join(",", $b5->history)) {
    print "not ";
}
print "ok " . $ok++ . "\n";

$b5->OnDestroy(sub { $b5->historySave("hist2.tmp.save") });


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

my(@oldhist) = $b4->history;
$b4->destroy;

my(@oldhist2) = $b5->history;
$b5->destroy;

my $b3 = $top->HistEntry;
$b3->historyMergeFromFile("hist.tmp.save");

if (join(",", @oldhist) ne join(",", $b3->history)) {
    print "not ";
}
print "ok " . $ok++ . "\n";
unlink "hist.tmp.save";

my $b6 = $top->SimpleHistEntry;
$b6->historyMergeFromFile("hist2.tmp.save");

if (join(",", @oldhist2) ne join(",", $b6->history)) {
    print "not ";
}
print "ok " . $ok++ . "\n";
unlink "hist2.tmp.save";

MainLoop if $VISUAL;

