-- SET temp_tablespaces = dbdisk1_temp;

--Creating a subset of 2016 filings.
CREATE TEMPORARY TABLE _tmp_period_of_interest AS
SELECT * FROM _mv_research_base_2014_ongoing
WHERE (filing_date >= '2014-01-01' AND filing_date < '2017-06-15') AND form_type <> '485BPOS' AND  form_type <>  '485APOS' AND form_type <> '497';

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

-- --Creating a table of filings by CIK.
-- CREATE TEMPORARY TABLE _tmp_report_count
-- AS SELECT rb.cik, count(rb.cik) AS filings_per_cik,
-- CASE
-- WHEN (rb.filing_date >= '2014-01-01' AND rb.filing_date < '2015-01-01') THEN 2014
-- WHEN (rb.filing_date >= '2015-01-01' AND rb.filing_date < '2016-01-01') THEN 2015
-- WHEN (rb.filing_date >= '2016-01-01' AND rb.filing_date < '2017-01-01') THEN 2016
-- WHEN (rb.filing_date >= '2017-01-01' AND rb.filing_date < '2018-01-01') THEN 2017
-- ELSE date_part('year', rb.filing_date)
-- END
-- AS filing_year
-- FROM _tmp_period_of_interest rb
-- GROUP BY rb.cik, filing_year
-- ORDER BY cik, filing_year;
--
-- --Creating a table of gaap datapoints by CIK.
-- CREATE TEMPORARY TABLE _tmp_datapoint_gaap
-- AS SELECT dp.filing_year, dp.cik, count(dp.datapoint_id) AS gaap_count, count(distinct(dp.aspect_id)) AS unique_gaap_elements FROM
-- _tmp_datapoint dp
-- WHERE dp.source ='gaap'
-- GROUP BY dp.filing_year, dp.cik;
--
-- --Creating a table of extension datapoints by CIK.
-- CREATE TEMPORARY TABLE _tmp_datapoint_extension
-- AS SELECT dp.cik, dp.filing_year, count(dp.datapoint_id) AS extension_count, count(distinct(dp.aspect_id)) AS unique_extended_elements FROM
-- _tmp_datapoint dp
-- WHERE dp.source ='extension'
-- GROUP BY dp.filing_year, dp.cik;
--
-- --Pulling it all into one report.
-- SELECT dp.cik, dp.filing_year, rc.filings_per_cik, dp.fact_count, dp1.gaap_count AS gaap_count, dp2.extension_count AS extension_count, dp1.unique_gaap_elements AS unique_gaap_elements, dp2.unique_extended_elements AS unique_extended_elements
-- FROM _tmp_datapoint_count dp
-- LEFT JOIN _tmp_datapoint_gaap dp1 ON dp1.cik=dp.cik AND dp1.filing_year = dp.filing_year
-- LEFT JOIN _tmp_datapoint_extension dp2 ON dp2.cik=dp.cik AND dp2.filing_year = dp.filing_year
-- LEFT JOIN _tmp_report_count rc ON rc.cik=dp.cik AND rc.filing_year = dp.filing_year
-- ORDER BY cik, filing_year;

--Count of distinct aspect ID
SELECT dp.source, dp.filing_year, count(distinct(dp.aspect_id)) AS unique_elements,
 count(distinct(dp.datapoint_id)) AS fact_count
FROM _tmp_datapoint dp
GROUP BY dp.filing_year, dp.source
ORDER BY dp.source, filing_year DESC;

-- SELECT * FROM _tmp_datapoint_count ORDER BY cik, filing_year
-- SELECT * FROM _tmp_report_count ORDER BY cik, filing_year
-- SELECT * FROM _tmp_datapoint_gaap ORDER BY cik, filing_year
-- DROP TABLE _tmp_report_count
