#  Makefile for Pan utility files.
#
CFLAGS = -g 
CPPFLAGS = -g
LINTFLAGS = -bxu -lc -lm

HFILES =
CFILES = mex.c
CCFILES= 
FFILES = 
YFILES = 
LFILES = 
OFILES = mex.o

MPANSUITE = ./MPanSuite
MEX  = $(MPANSUITE)/mex_so/*.c 
MEX += $(MPANSUITE)/mex_so/panMat.so
MEX += $(MPANSUITE)/src/*/*.m
MEX += $(MPANSUITE)/MPanSuiteInit.in
MEX += $(MPANSUITE)/MPanSuiteInstall.m


DIRECTORY = matlab
MPANSUITEZIP = ../bin/MPanSuite.zip
LIBRARY = $(DIRECTORY).a
SOURCE = $(CFILES) $(FFILES) $(YFILES) $(LFILES) $(HFILES) 
DEPEND = ../mkdep
SHELL = /bin/sh
CC  = cc
CXX = gcc

TAGS = ctags

#::::: Rules ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::#

$(LIBRARY)   : $(OFILES) 
	ar cr $(LIBRARY) $?
	ranlib $(LIBRARY)

.PHONY: matlab

zip          : $(LIBRARY) 
	rm -f $(MPANSUITEZIP)
	zip $(MPANSUITEZIP) $(MEX) 

lint         : 
	@lint $(LINTFLAGS) ../llib-lPan.ln $(CFILES) 

cleangcov    : 
	rm -f *.bbg *.bb *.da *.c.gcov

clean        :
	rm -f $(OFILES)  $(LIBRARY) *.bb *.da *.c.gcov *.mex* *.o \
	      $(MPANSUITEZIP) 

grind        :
	tgrind -lc $(CFILES) 

cfiles       : $(CFILES)
hfiles       : $(HFILES)
ofiles       : $(OFILES)

listsource   : listcfiles listhfiles
listcfiles   :
	@for i in $(CFILES); do echo $(DIRECTORY)/$$i; done
listhfiles   :
#	@for i in $(HFILES); do echo $(DIRECTORY)/$$i; done

touch        :
	touch -c  $(OFILES) $(LIBRARY)
	ranlib $(LIBRARY)

spell        :
	@echo spell $(DIRECTORY):
	@cdict $(CFILES) $(HFILES)

tags         : /tmp
	$(TAGS) -f tags -w [a-zA-Z]*.[chf] ../*/[a-zA-Z]*.[chf] 

%.o: %.c
	$(CXX) $(CFLAGS) -fPIC -DREADLINE_LIBRARY \
	`locate /extern/include/mex.h | sed -e "s/mex.h//" | sed -e"s/^/-I/"` \
	-c $< -o $*.o

uilex.hash : uilex.gperf
	gperf -o -i 1 -C -k 1-3,$$ -L C -H UiFunctionHash -N UiFunctionName -t uilex.gperf > uilex.hash

uilex.c : uilex.l uigrammer.h uilex.hash
	lex -PUi -t uilex.l > uilex.c

uigrammer.c uigrammer.h : uigrammer.y
	bison -p Ui -d --output=uigrammer.c uigrammer.y

depend       :
	@echo "Making depend in `pwd`"
	@rm -f makedep
	@for i in $(CFILES); do $(DEPEND) $(CFLAGS) $$i >> makedep; done
#	@echo ${CFILES} | tr ' 	' '\012\012' \
#		| sed -e 's/\([^\.]*\)\.c */\1\.c: RCS\/\1\.c,v/' >> makedep
	@echo '/^# DO NOT DELETE THIS LINE/+2,$$d' >eddep
	@echo '$$r makedep' >>eddep
	@echo 'w' >>eddep
	@\cp Makefile .Makefile.bak
	@\ed - Makefile < eddep > /dev/null
	@\rm eddep makedep 
	@echo '# DEPENDENCIES MUST END AT END OF FILE' >> Makefile
	@echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >> Makefile
	@echo '# see make depend above' >> Makefile

#::::: Dependencies ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::#

# DO NOT DELETE THIS LINE -- make depend uses it
# DEPENDENCIES MUST END AT END OF FILE
mex.o: ../include/Analysis.h
mex.o: ../include/bzlib.h
mex.o: ../include/control.h
mex.o: ../include/Error.h
mex.o: ../include/Globals.h
mex.o: ../include/../include/dq.h
mex.o: ../include/../include/st.h
mex.o: ../include/Macros.h
mex.o: ../include/Numbers.h
mex.o: ../include/parser.h
mex.o: ../include/raw.h
mex.o: ../include/ui.h
mex.o: ../include/utils.h
mex.o: mex.c
# DEPENDENCIES MUST END AT END OF FILE
# IF YOU PUT STUFF HERE IT WILL GO AWAY
# see make depend above
