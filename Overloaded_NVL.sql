/*    One way to get around the issue with orafunc's NVL function limitations.

       The orafunc version of NVL only works with INTEGER datatypes and returns and error
       if you try to use anything else.  Postgres/Greenplum's COALESCE feature works properly
       with many datatypes, but for large scale Oracle conversions this means extra porting 
       work since NVL is in common use in many Oracle shops.  To get around the need for changing 
       NVL function calls into COALESCE ones, you can use this method.
       
       This is a series of overloaded functions wrapped around calls to the COALESCE command, one
       for each data type in the integer family.  For other data types, simply create extra copies 
       of the function with the needed datatype for $1.
       
       By default this gets put in the public schema.  Add schema prefixes as necessary and make
       sure they are included in your search path so they get picked up properly.
       
       Bart Kersteter   bart.kersteter@emc.com
       
*/
       
CREATE OR REPLACE FUNCTION NVL(bigint, anyelement) returns bigint
AS 'select coalesce($1, $2::bigint)'
LANGUAGE SQL
IMMUTABLE;

CREATE OR REPLACE FUNCTION NVL(integer, anyelement) returns integer
AS 'select coalesce($1, $2::integer)'
LANGUAGE SQL
IMMUTABLE;

CREATE OR REPLACE FUNCTION NVL(smallint, anyelement) returns smallint
AS 'select coalesce($1, $2::smallint)'
LANGUAGE SQL
IMMUTABLE;

CREATE OR REPLACE FUNCTION oracompat.NVL(timestamp, anyelement) returns timestamp
AS 'select coalesce($1,$2::timestamp)'
LANGUAGE SQL
IMMUTABLE;

 grant execute on function oracompat.NVL(timestamp,anyelement) to etuser;
 
CREATE OR REPLACE FUNCTION oracompat.NVL(numeric, anyelement) returns numeric
AS 'select coalesce($1,$2::numeric)'
LANGUAGE SQL
IMMUTABLE;

grant execute on function oracompat.NVL(numeric,anyelement) to etuser;

-- All three datatypes need to be the same for this to work.  When testing with $1=NULL, you have to cast it to get it to work.
CREATE OR REPLACE FUNCTION oracompat.NVL2(anyelement, anyelement, anyelement) returns anyelement
AS 'select CASE when $1 ISNULL THEN $2 ELSE $3 END'
LANGUAGE SQL
IMMUTABLE;

 grant execute on function oracompat.nvl2(anyelement,anyelement,anyelement) to etuser;