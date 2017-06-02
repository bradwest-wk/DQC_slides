#!/bin/bash

# queries the errors script using user inputed dates, saves to CSV in
# specified file

# date syntax: '2017-05-11'
start_date="$1"
end_date="$2"
OUTPUT_QUERY="$3"

# For some reason need to use direct path to psql
/Library/PostgreSQL/9.6/bin/psql -h rltest.markv.com -p8084 -d debug3_db -U postgres -q -c 'COPY (SELECT * FROM query_errors ('\'$start_date\'', '\'$end_date\'') AS t(company_name character varying, cik character varying(30), sic integer, form_type character varying(30), filing_date date, taxonomy text, creation_software text, accession_number character varying(30), sec_url text, entry_url text, fact_count bigint, filer_status character varying, message_code character varying, element_name character varying, fact_value text, start_date date, end_date date, dimension_names text, message_value text, element_source text, dimension_source text, message_id bigint, element_name_2 character varying, fact_value_2 text, start_date_2 date, end_date_2 date, dimension_names_2 text, message_value_2 text, element_source_2 text, dimension_source_2 text)) TO STDOUT WITH CSV HEADER;' > $OUTPUT_QUERY

# test example
# /Library/PostgreSQL/9.6/bin/psql -h rltest.markv.com -p8084 -d debug3_db -U postgres -q -c 'COPY (SELECT DISTINCT creation_software, filing_date FROM filing WHERE filing_date > '\'$start_date\'' AND filing_date < '\'$end_date\'' ORDER BY filing_date DESC) TO STDOUT WITH CSV HEADER;' > $OUTPUT_QUERY
