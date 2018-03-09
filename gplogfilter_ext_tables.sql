#
#   Examples of creating external web table running gplogfilter against master segment DB only and pulling back rows that contain 
#	errors (ERROR, FATAL, PANIC)
#
#   Please see sections on external web tables and gplogfilter in the Greenplum Admin guide for more details about how
#   to set up similar views.  Basically you need to figure out the right gplogfilter options to give you the data you want to see
#   and then create a listing of columns to match what you're pulling back.
#
#	Bart Kersteter    bkersteter@gmail.com    4/2012
#

drop external web table gp_log_errs_master;

#  logsessiontime is created as text instead of timestamptz because it is not always populated and null timestamps cause errors
#    with the view.
create external web table gp_log_errs_master (logtimestamp timestamptz, 
loguser text, logdatabase text,  loghost text,  logsessiontime text,  logsegment text, logseverity text, logmessage text)
execute '/usr/local/greenplum-db/bin/gplogfilter -t -C ''1,2,3,6,8,12,17,19'' | grep ^20' ON MASTER FORMAT 'TEXT' (DELIMITER '|');

drop external web table gp_log_errs_all;

#  logsessiontime is created as text instead of timestamptz because it is not always populated and null timestamps cause errors
#    with the view.
create external web table gp_log_errs_all (logtimestamp timestamptz, 
loguser text, logdatabase text,  loghost text,  logsessiontime text,  logsegment text, logseverity text, logmessage text)
execute '/usr/local/greenplum-db/bin/gplogfilter -t -C ''1,2,3,6,8,12,17,19'' | grep ^20' ON ALL FORMAT 'TEXT' (DELIMITER '|');


##############################################################################################################################


