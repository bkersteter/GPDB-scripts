#!/usr/local/greenplum-db/ext/python/bin/python
#   gpfcd_text.py 
#
#	Python script to examine a file and report on exceptions in a data file.
# 	This program reports the line number and number of fields for exception rows in the file
#
#	This script is designed to work on text-delimited fields.  It is not smart enough
#	to figure out if a delimiter character is embedded in a csv-style text string
#	(i.e. enclosed in double-quotes).   Use gpfcd_csv.py for that.
#
#       This script is meant for use by internal Greenplum tech staff for purposes of
#       keeping POC engagements moving along and getting at least some of the data into
#       a DCA system so you can test.  It should not be distributed to customers.
#
#	Bart Kersteter	bart.kersteter@emc.com
#
#	Usage:   run gpfcd_text.py -h to see usage description.
#
#	Revision History
#
#	1/30/2012	Bart Kersteter		Initial		
#	03/22/2012	Bart Kersteter		Added file buffer sizes to avoid memory errors with larger files.


import fileinput
import time
# optparse is deprecated in python 2.7 but since we still ship with 2.6 it is the best
#   one to use right now.  Eventually replace with argparse
import optparse 

parser = optparse.OptionParser()
parser.add_option("-f", metavar="FILE", dest="filename", help="open FILE for processing (required)")
parser.add_option("-d", dest="delimiter", default='|', help="delimiter enclosed in quotes (optional: default '|')")
parser.add_option("-l", dest="logfile", action="store_true", help="log output to file (optional)")
parser.add_option("-n" , dest="numfields", help="expected number of fields per row/line (required)")
parser.add_option("-s", dest="split_file",  action="store_true", help="Split source file into good and bad record files (optional)")
parser.add_option("--header", dest="has_header", action="store_true", help="Set if the file has a header for the first row. (optional)")
(options, args) = parser.parse_args()
filename=options.filename
delimiter=options.delimiter
split_file=options.split_file
logfile=options.logfile
has_header=options.has_header
# Number of pipes in file should be number of fields -1
numfields=int(options.numfields) - 1

# Split file separates the good records from the bad records and requires
#  opening a few new file handles.

if logfile:
    job_start=time.time()
    log_file=open('%s' % filename+'.log', 'w', 1)
    logmsg="File: %s - Split: %s\n\n" % (filename, split_file)
    log_file.write(logmsg)

if split_file:
    print "Splitting output..."  
    #Open files with 100MB buffers to avoid out-of-memory errors on large files. 
    # If dealing with really large record sizes, change the buffering value to '1' and flush the buffer
    # after every line.
    outfile=open('%s' % filename+'.good', 'w', 1024*1024*100)
    badfile=open('%s' % filename+'.bad', 'w', 1024*1024*100)

currentline=0
badlines=0
for line in open('%s' % filename, 'r'):
   currentline+=1
   num_delim=line.count(delimiter)
   if num_delim != numfields: 
        if num_delim < numfields:
            if logfile:
                logmsg="Line: %s is missing columns - field count: %s\n"  % (currentline, num_delim)
                print logmsg
        else:
            logmsg="Line: %s - detected extra columns in line - field count: %s\n" % (currentline, num_delim + 1) 
            print logmsg
        if logfile:
             log_file.write(logmsg)
        if split_file:
           badfile.write(line)
        badlines += 1
   else:
       if split_file:
           outfile.write(line)
#   if ((currentline % 100)==0) and split_file:     #If using split file, flush the files every 100 rows to avoid memory issues
#      outfile.flush()
#      badfile.flush()

if split_file:
    outfile.close()
    badfile.close()

if logfile:
    job_end=time.time()
    elapsed=round(job_end - job_start, 5)
    pctbad=round(float(badlines)/(currentline-1)*100, 2)
    logmsg="\n\nJob completed.   Runtime: %s seconds. \nTotal Lines: %s  Total Bad Rows: %s   Percentage bad rows: %s\n" % (elapsed, currentline, badlines, pctbad)
    log_file.write(logmsg)
    log_file.close()
