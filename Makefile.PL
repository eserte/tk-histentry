use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Tk::HistEntry',
    'VERSION_FROM' => 'HistEntry.pm', # finds $VERSION
    'dist'      => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},
);

sub MY::postamble {
        '
demo :: pure_all
	$(FULLPERL) -w -I$(SITELIBEXP)/Tk/demos/widget_lib -Mblib examples/1.pl
	$(FULLPERL) -w -I$(SITELIBEXP)/Tk/demos/widget_lib -Mblib examples/newclass.pl

';
}
