# Makefile

JC     = javac
JFLAGS = -d . -classpath .
SRCS   = $(wildcard *.java)

PROGS = $(patsubst %.java,%,$(SRCS))

all:	$(PROGS)

%: %.java
	$(JC) $(JFLAGS) $< 

clean: 
	rm -f *.class
	rm -f *~
