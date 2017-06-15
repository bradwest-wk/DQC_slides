-- Creates a prepared table that can be passed to a bash script/psql script

PREPARE gaap_ext_counts (date, date) AS
    CREATE TEMPORARY TABLE _tmp_period_of_interest AS
    SELECT * FROM _mv_research_base_2014_ongoing
    WHERE (filing_date >= $1 AND filing_date < $2) AND form_type <> '485BPOS' AND  form_type <>  '485APOS' AND form_type <> '497';

    --Creating a table of datapoints and their sources.
    CREATE TEMPORARY TABLE _tmp_datapoint AS
    SELECT a.name, a.qname, a.aspect_id, dp.report_id, dp.datapoint_id, rb.cik,
    CASE
    WHEN (rb.filing_date >= '2014-01-01' AND rb.filing_date < '2015-01-01') THEN 2014
    WHEN (rb.filing_date >= '2015-01-01' AND rb.filing_date < '2016-01-01') THEN 2015
    WHEN (rb.filing_date >= '2016-01-01' AND rb.filing_date < '2017-01-01') THEN 2016
    WHEN (rb.filing_date >= '2017-01-01' AND rb.filing_date < '2018-01-01') THEN 2017
    ELSE date_part('year', rb.filing_date)
    END
    AS filing_year,
    CASE
    WHEN a.qname LIKE '{http://xbrl.sec.gov%' THEN 'gaap'
    WHEN a.qname LIKE '{http://fasb.org/%' THEN 'gaap'
    WHEN a.qname LIKE '{http://xbrl.us/%' THEN 'gaap'
    WHEN a.qname LIKE '{http://arelle.org/%' THEN 'arelle'
    ELSE 'extension'
    END
    AS source
    FROM
    data_point dp
    JOIN aspect a ON a.aspect_id = dp.aspect_id
    JOIN _tmp_period_of_interest rb ON rb.report_id = dp.report_id;

    --Creating a table of non-arelle datapoint counts.
    CREATE TEMPORARY TABLE _tmp_datapoint_count
    AS SELECT sq.cik, sq.filing_year, count(distinct sq.report_id) AS filings_per_cik, sum(sq.count) AS fact_count
    FROM
        (SELECT dp.cik, dp.filing_year, dp.report_id, count(dp.datapoint_id) AS count
        FROM _tmp_datapoint dp
        WHERE dp.source <>'arelle'
        GROUP BY dp.filing_year, dp.cik, dp.report_id
        ORDER BY dp.cik, dp.filing_year, dp.report_id) AS sq
    GROUP BY sq.cik, sq.filing_year;

    --Count of distinct aspect ID
    SELECT dp.source, dp.filing_year, count(distinct(dp.aspect_id)) AS unique_elements,
     count(distinct(dp.datapoint_id)) AS fact_count
    FROM _tmp_datapoint dp
    GROUP BY dp.filing_year, dp.source
    ORDER BY dp.source, filing_year DESC;

-- To access query: EXECUTE gaap_ext_counts('yyyy-mm-dd', 'yyyy-mm-dd');
