# -*- perl -*-
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $^W = 1; $| = 1; $loaded = 0; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::HistEntry;
use strict;
use vars qw($loaded);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Tk;
eval { require Tk::FireButton };
if ($@) {
    print "ok 2\n# Skipping this test (Tk::FireButton missing)\n";
    exit;
}

package MyHistEntry;
@MyHistEntry::ISA = qw(Tk::Frame);
Construct Tk::Widget 'MyHistEntry';

{ my $foo = $Tk::FireButton::INCBITMAP;
     $foo = $Tk::FireButton::DECBITMAP; }

sub Populate {
    my($f, $args) = @_;

    my $e = $f->Component(SimpleHistEntry => 'entry');
    my $binc = $f->Component( FireButton => 'inc',
        -bitmap             => $Tk::FireButton::INCBITMAP,
        -command            => sub { $e->historyUp },
    );

    my $bdec = $f->Component( FireButton => 'dec',
        -bitmap             => $Tk::FireButton::DECBITMAP,
        -command            => sub { $e->historyDown },
    );

    $f->gridColumnconfigure(0, -weight => 1);
    $f->gridColumnconfigure(1, -weight => 0);

    $f->gridRowconfigure(0, -weight => 1);
    $f->gridRowconfigure(1, -weight => 1);

    $binc->grid(-row => 0, -column => 1, -sticky => 'news');
    $bdec->grid(-row => 1, -column => 1, -sticky => 'news');

    $e->grid(-row => 0, -column => 0, -rowspan => 2, -sticky => 'news');

    $f->ConfigSpecs
      (-repeatinterval => ['CHILDREN', "repeatInterval",
			   "RepeatInterval", 100       ],
       -repeatdelay    => ['CHILDREN', "repeatDelay",
			   "RepeatDeleay",   300       ],
       DEFAULT => [$e],
      );

    $f->Delegates(DEFAULT => $e);

    $f;

}

package main;

my $top = new MainWindow;

my($bla);

my($b2, $lb2);
$b2 = $top->MyHistEntry(-textvariable => \$bla,
			-repeatinterval => 30,
			-bell => 1,
			-dup => 1,
			-command => sub {
			    my($w, $s, $added) = @_;
			    if ($added) {
				$lb2->insert('end', $s);
				$lb2->see('end');
			    }
			    $bla = '';
			})->pack;
$lb2 = $top->Scrolled('Listbox', -scrollbars => 'osoe'
		     )->pack;

# Autodestroy
my $seconds = 60;
my $autodestroy_text = "Autodestroy in " . $seconds . "s\n";
$top->Label(-textvariable => \$autodestroy_text,
	   )->pack;
$top->repeat(1000, sub { if ($seconds <= 0) { $top->destroy }
			 $seconds--;
			 $autodestroy_text = "Autodestroy in " . $seconds
			   . "s\n";
		     });

MainLoop;

print "ok 2\n";
