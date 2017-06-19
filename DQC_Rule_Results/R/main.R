rmarkdown::render(
  "./slides_HTML_parameterized.Rmd",
  output_format = "ioslides_presentation",
  params = list(
    # directory = "/Users/bradwest/Google_Drive/Projects/DQC_slides",
    username = "web_query",
    password = "W0rkiv@",
    dbserver = "rltest.markv.com",
    dbport = 8084,
    dbname = "debug3_db",
    data_source = "file",
    file_input = "~/Google_Drive/Projects/DQC_slides/DQC_Rule_Results/inst/extdata/data_raw_16_17.csv",
    data_source_counts = "file",
    counts_file_input =
      "~/Google_Drive/Projects/DQC_slides/DQC_Rule_Results/inst/extdata/gaap_v_ext_unique_dp.csv",
    start_date = "2016-01-01",
    end_date = "2017-04-01")
)


