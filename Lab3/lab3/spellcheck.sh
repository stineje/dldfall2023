#!/bin/sh
cat $1 | aspell -a -t | cut -d ' ' -f 2 | grep -v '*' | sort | sed '/^$/d' | more
