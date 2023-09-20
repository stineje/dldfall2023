We will use software for Verification and use a piece of software
written in Java.  You do not need to understand Java, but just use the
output of the program to help you debug things.

If you need to install Java on your machine at home
or laptop, go to
https://www.oracle.com/java/technologies/downloads/#java16
and download the appropriate version.

Verification is extremely difficult and this is why I indicated in
class that some companies can spend close to 70% of their time
verifying designs.

Use the Java program to verify each block out of the
HDL. Although the Java works based on bytecodes that are interpreted,
I have found that some machines have problems reading the Java
bytecodes. I am still not quite sure why this is the case, however,
there is an easy fix. Therefore, I included a Makefile that I wrote
that allows you to compile the Java correctly. Please type the
following if you are having problems running the code at the terminal.

<pre>
make clean
make
</pre>

To run the tool, type <pre>java DES</pre> axt the command prompt.

If you cannot run make on your Windows box, just type the javac
commands once you have installed the Java JDK at the terminal
<pre>javac -d . -classpath . DES.java</pre>

