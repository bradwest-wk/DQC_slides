rmarkdown::render(
        "./slides_HTML_parameterized.Rmd",
                        output_format = "ioslides_presentation",
                        output_file = as.character("DQC_Rule_Results.html"),
                        params = list(username = as.character("web_query"),
                        password = as.character("W0rkiv@"),
                        dbserver = as.character("rltest.markv.com"),
                        dbport = as.numeric(8084),
                        dbname = as.character("debug3_db"),
                        data_source = as.character("database"),
                        file_input = as.character(""),
                        data_source_counts = as.character(
                        "file"),
                        counts_file_input = as.character(
                        "~/Google_Drive/Projects/DQC_slides/DQC_Rule_Results/inst/extdata/gaap_v_ext_unique_dp.csv"),
                        start_date = as.character("2015-10-01"),
                        end_date = as.character("2017-04-01")
                        ))
