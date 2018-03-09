#!/bin/ksh

# quick script to strip quote characters from data files
# Bart Kersteter - bkersteter@gmail.com
#
# Run in the directory the load files are sitting in or modify
# the code to cd to that directory.
#
# Better option is to just specify load file as CSV format
# in most cases.
#

for fname in `ls -1 *final`
do
   sed 's/"//g' ${fname} > foo
   mv foo ${fname}
done

