# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::HistEntry;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use Tk;
$top = new MainWindow;

$f = $top->Frame->grid(-row => 0, -column => 0,  -sticky => 'n');
$b = $f->HistEntry(-textvariable => \$foo)->pack;
$bb = $f->Button(-text => 'Add current',
		 -command => sub {
		     return unless $foo;
		     $b->historyAdd($foo);
		     $lb->delete(0, 'end');
		     foreach (@{$b->{'history'}}) {
			 $lb->insert('end', $_);
		     }
		     $foo = '';
		 })->pack;
$lb = $top->Scrolled('Listbox', -scrollbars => 'osoe'
		    )->grid(-row => 0, -column => 1);
$b->bind('<Return>' => sub { $bb->invoke });

$f2 = $top->Frame->grid(-row => 1, -column => 0, -sticky => 'n');
$b2 = $f2->HistEntry(-textvariable => \$bla,
		     -bell => 0,
		     -dup => 1,
		     -command => sub {
			 my $w = shift;
			 # automatic historyAdd
			 $lb2->delete(0, 'end');
			 foreach (@{$b2->{'history'}}) {
			     $lb2->insert('end', $_);
			 }
		     })->pack;
$f2->Button(-text => 'Add current',
	   -command => sub { $b2->invoke })->pack;
$lb2 = $top->Scrolled('Listbox', -scrollbars => 'osoe'
		     )->grid(-row => 1, -column => 1);

# Autodestroy
$seconds = 60;
$autodestroy_text = "Autodestroy in " . $seconds . "s\n";
$top->Label(-textvariable => \$autodestroy_text,
	   )->grid(-row => 2, -column => 0, -columnspan => 2);
$top->repeat(1000, sub { if ($seconds <= 0) { $top->destroy }
			 $seconds--;
			 $autodestroy_text = "Autodestroy in " . $seconds
			   . "s\n";
		     });
MainLoop;

print "ok 2\n";
