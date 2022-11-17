This is some code you can use to create some golden vectors to see if
your SystemVerilog is working correctly.  It is currently configured
for a 4x4 grid but can easily be expanded to 8x8.  To run, make sure
you compile the Java code.  This can be done with the Makefile by
typing make where appropriate.

make

If this does not work, you can compile individually, similar to Lab 2.

javac -d . -classpath . life.java 

To run the code, type:

java life

which should output some iterations dependent on the "gens" variable.

<PRE>
Generation 0:
1011
0011
1111
0000
Generation 1:
0111
1000
0101
0110
Generation 2:
0110
1001
1100
0110
Generation 3:
0110
1000
1000
1110
</PRE>

Note:  There is a C version here for those that like C, but it may be
somewhat non-intuitive.  However, feel free to use the version you
feel comfortable with.