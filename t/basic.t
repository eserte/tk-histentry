# -*- perl -*-

#
# $Id: basic.t,v 1.17 2003/10/27 22:14:50 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1997,1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

BEGIN {
    $^W = 1;
    $| = 1;
    $loaded = 0;
    $last = 46;
    print "1..$last";
#      if ($] >= 5.005 && $] < 5.006) {
#  	print " todo 13;";
#      }
    print "\n";
}

END {print "not ok 1\n" unless $loaded;}

use Tk::HistEntry;
use strict;
use vars qw($loaded $last $VISUAL);
use FindBin;

chdir "$FindBin::RealBin";

package main;

sub _not {
    print "# Line " . (caller)[2] . "\n";
    print "not ";
}

$loaded = 1;
$VISUAL = $ENV{PERL_TEST_INTERACTIVE};

my $ok = 1;
print "ok " . $ok++ . "\n";

use Tk;

my $top = new MainWindow;

my($foo, $bla);

my($b1, $b2);
$b1 = $top->SimpleHistEntry(-textvariable => \$foo,
			    -bell => 1,
			    -dup => 0,
			    -case => 1,
			    -auto => 1,
			    -match => 1,
			   )->pack;
if (!Tk::Exists($b1)) {
    _not;
}
print "ok " . $ok++ . "\n";

if ($b1->class ne 'SimpleHistEntry') {
    _not;
}
print "ok " . $ok++ . "\n";

$b2 = $top->HistEntry(-textvariable => \$bla,
		      -bell => 1,
		      -dup => 0,
		      -label => 'Browse:',
		      -labelPack => [-side => 'top'],
		     )->pack;
if (!Tk::Exists($b2)) {
    _not;
}
print "ok " . $ok++ . "\n";

if ($b2->class ne 'HistEntry') {
    _not;
}
print "ok " . $ok++ . "\n";

my @test_values = qw(bla foo bar);

my($b4) = $top->HistEntry->pack;
foreach (@test_values) { $b4->historyAdd($_) }
if (join(",", @test_values) ne join(",", $b4->history)) {
    _not;
}
print "ok " . $ok++ . "\n";

$b4->_entry->insert("end", "blubber");
$b4->addhistory();
if (join(",", @test_values, "blubber") ne join(",", $b4->history)) {
    _not;
}
print "ok " . $ok++ . "\n";

$b4->OnDestroy(sub { $b4->historySave("hist.tmp.save") });


my($b5) = $top->SimpleHistEntry->pack;
foreach (@test_values) { $b5->historyAdd($_) }
if (join(",", @test_values) ne join(",", $b5->history)) {
    _not;
}
print "ok " . $ok++ . "\n";

$b5->insert("end", "blubber");
$b5->addhistory();
if (join(",", @test_values, "blubber") ne join(",", $b5->history)) {
    _not;
}
print "ok " . $ok++ . "\n";

$b5->OnDestroy(sub { $b5->historySave("hist2.tmp.save") });
print "ok " . $ok++ . "\n";

foreach ($b1, $b2) {
    $_->update;
    print "ok " . $ok++ . "\n";
}

foreach my $sw ($b2->Subwidget) {
    if ($sw->isa('Tk::LabEntry')) {
	foreach my $ssw ($sw->Subwidget) {
	    if ($ssw->isa('Tk::Label')) {
		my $t = $ssw->cget(-text);
		_not if ($t ne 'Browse:');
		print "ok " . $ok++ . "\n";
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

foreach ([$e1, $b1, 1],
	 [$e2, $b2, 2]) {
    my($e,$b,$nr) = @$_;

    $e->insert(0, "first $nr");
    $b->historyAdd;
    my @h = $b->history;
    print ((@h == 1 && $h[0] eq "first $nr" ? "" : "not ") . "ok " . $ok++ . "\n");

    $b->historyAdd("second $nr");
    @h = $b->history;
    print ((@h == 2 && $h[1] eq "second $nr" ? "" : "not ") . "ok " . $ok++ . "\n");

    $b->addhistory("third $nr");
    @h = $b->history;
    print ((@h == 3 && $h[2] eq "third $nr" ? "" : "not ") . "ok " . $ok++ . "\n");

    if ($b eq $b2) {
	my $h2str1 = join(", ", $lb2->get(0, 'end'));
	my $h2str2 = join(", ", @h);

	print (($h2str1 eq $h2str2 ? "" : "not ") . "ok " . $ok++ . "\n");
    }

    print (($b->can('addhistory') ? "" : "not") . "ok " . $ok++ . "\n");
    print (($b->can('historyAdd') ? "" : "not") . "ok " . $ok++ . "\n");

}


my(@oldhist) = $b4->history;
$b4->destroy;

my(@oldhist2) = $b5->history;
$b5->destroy;

# testing historyMergeFromFile for HistEntry
my $b3 = $top->HistEntry;
$b3->historyMergeFromFile("hist.tmp.save");

if (join(",", @oldhist) ne join(",", $b3->history)) {
    _not;
}
print "ok " . $ok++ . "\n";
unlink "hist.tmp.save";

# testing historyReset
$b3->historyReset;
my(@histafterreset) = $b3->history;
if (@histafterreset) {
    _not;
}
print "ok " . $ok++ . "\n";

@histafterreset = $b3->_listbox->get(0, "end");
if (@histafterreset) {
    _not;
}
print "ok " . $ok++ . "\n";

# testing historyMergeFromFile for SimpleHistEntry
my $b6 = $top->SimpleHistEntry;
$b6->historyMergeFromFile("hist2.tmp.save");

if (join(",", @oldhist2) ne join(",", $b6->history)) {
    _not;
}
print "ok " . $ok++ . "\n";
unlink "hist2.tmp.save";

# testing historyReset for SimpleHistEntry
$b6->historyReset;
@histafterreset = $b6->history;
if (@histafterreset) {
    _not;
}
print "ok " . $ok++ . "\n";

# testing insert/get/delete methods
$b3->insert('end', "blablubber");
my $b3_got = $b3->get;
if ($b3_got eq "") {
    _not;
    warn "Got <$b3_got>, expected non-empty string";
}
print "ok " . $ok++ . "\n";

$b3->delete(0, 'end');
if ($b3->get ne "") {
    _not;
}
print "ok " . $ok++ . "\n";

# check duplicates
foreach my $b ($b1, $b2) {
    my $hist_entries = 4;
    $b->historyAdd("foobar");
    if (scalar $b->history != $hist_entries) {
	_not;
    }
    print "ok " . $ok++ . "\n";

    $b->historyAdd("foobar");
    if (scalar $b->history != $hist_entries) {
	_not;
    }
    print "ok " . $ok++ . "\n";

    $b->historyAdd("foobar2");
    $hist_entries++;
    if (scalar $b->history != $hist_entries) {
	_not;
    }
    print "ok " . $ok++ . "\n";

    $b->_entry->delete(0, "end");
    $b->_entry->insert(0, "foobar");
    $b->historyAdd;
    if (scalar $b->history != $hist_entries) {
	_not;
    }
    print "ok " . $ok++ . "\n";
}

{
    # check -history config option
    my $he = $top->SimpleHistEntry(-history => [qw(1 2 3)]);
    if (join(" ",$he->cget(-history)) ne "1 2 3") {
	_not;
    }
    print "ok " . $ok++ . "\n";

    if (join(" ",$he->history) ne "1 2 3") {
	_not;
    }
    print "ok " . $ok++ . "\n";

    my $he2 = $top->HistEntry(-history => [qw(1 2 3)]);
    if (join(" ",$he2->cget(-history)) ne "1 2 3") {
	_not;
    }
    print "ok " . $ok++ . "\n";

    if (join(" ",$he2->history) ne "1 2 3") {
	_not;
    }
    print "ok " . $ok++ . "\n";
}

$top->Button(-text => "OK",
	     -command => sub { $top->destroy })->pack->focus;

$top->after(30000, sub { $top->destroy });

MainLoop if $VISUAL;

