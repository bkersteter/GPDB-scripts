#!/bin/ksh

# quick script to strip inon-UTF8 compliant characters from data files
# Bart Kersteter - bkersteter@gmail.com
#
# Run in the directory the load files are sitting in or modify
# the code to cd to that directory.
#
#	NOTE:  Best used for true garbage characters.  If you are 
#	dealing with European accents or similar that UTF8 cannot
#	handle well, create your external table as ENCODING='LATIN9' 
#	or similar otherwise you will corrupt the data even if you 
#	load it successfully.

for fname in `ls -1 *final`
do
   tr -d '\277' < ${fname} > foo
   tr -d '\311' < foo > ${fname}
done

