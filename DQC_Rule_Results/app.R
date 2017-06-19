# To Do
# Show progress bar in app

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("DQC Rule Results: Generate Slides"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
     # textInput(inputId = "directory", label = "Directory for Slides:",
       #        value = "~/Downloads"),
     textInput(inputId = "dbserver", label = "Database Server:"),
     textInput(inputId = "dbname", label = "DB name:"),
     textInput(inputId = "username", label = "DB username:"),
     passwordInput(inputId = "password", label = "DB password:"),
     numericInput(inputId = "dbport", label = "DB port:", value = 8084),
     radioButtons(inputId = "data_source",
                  label = "Rule data from file or DB query:",
                  choices = c("Query" = "database", "csv File" = "file"),
                  selected = "database"),
     # maybe change multiple to TRUE at some point?
     textInput(inputId = "file_input",
               label = "Enter rules csv file if csv file checked:",
               value = ""),
     radioButtons(inputId = "data_source_counts",
                  label = "Error count data from flat file or DB query:",
                  choices = c("Query" = "database",
                              "csv File" = "file"), selected = "file"),
     textInput(inputId = "counts_file_input",
               label = "Enter errors csv file if csv file checked:",
               value = ""),
     dateInput(inputId = "start_date",
               label = "Period start date (inclusive):", value = "2016-01-01"),
     dateInput(inputId = "end_date",
               label = "Period end date (exclusive):", value = "2017-04-01"),
     textInput(inputId = "file_output",
               label = "Slide output file name:",
               value = ,"DQC_Rule_Results.html")
     ),
     
      
      mainPanel(
        textOutput("description"),
        actionButton(inputId = "slides", label = "Generate Slides")#,
        # downloadButton(outputId = "download", label = "Download Plots and
        # Tables")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # setwd("/Users/bradwest/Google_Drive/Projects/DQ_requests/DQC_slides")
  output$description <- 
    renderText(
      "This app generates a Google Slides presentation of the DQC rule errors
      for the given date range.  The presentation is automatically updated in
      the shared Workiva Drive folder and is based on the template in that
      folder. Please be patient while the app processes the request as it
      must first query the database for the errors. For quicker execution, use
      a flat file. To request changes to the errors queried or to the slides 
      template, contact brad dot west at workiva dot com.")
  
  observeEvent(input$slides, {
  
    
    # Can't place parameterized markdown doc in same folder as shiny app.  Need
    # to create temp folder and copy into tempReport <- file.path(tempdir(),
    # "slides_HTML_parameterized.Rmd") 
    # file.copy("/Users/bradwest/Google_Drive/Projects/DQ_requests/DQC_slides/DQC_Rule_Results/slides_HTML_parameterized.Rmd",
    # tempReport, overwrite = TRUE)
    
    # write the command to an R file
      rmarkdown::render(
        "./slides_HTML_parameterized.Rmd",
        output_format = "ioslides_presentation",
        output_file = as.character(input$file_output),
        params = list(  # directory = as.character(input$directory), 
                      username = as.character(input$username),
                      password = as.character(input$password),
                      dbserver = as.character(input$dbserver),
                      dbport = as.numeric(input$dbport),
                      dbname = as.character(input$dbname),
                      data_source = as.character(input$data_source),
                      file_input = as.character(input$file_input),
                      data_source_counts = as.character(
                        input$data_source_counts),
                      counts_file_input = as.character(
                        input$counts_file_input),
                      start_date = as.character(input$start_date),
                      end_date = as.character(input$end_date)
                      )
        )
  })
  #   
  #   table_all_csv <- read.csv("./plots/rule_violations_table_all.csv")
  #   table_laf_csv <- read.csv("./plots/rule_violations_table_laf.csv")
  #   table_src_csv <- read.csv("./plots/rule_violations_table_src.csv")
  #   table_dp_counts <- read.csv("./plots/unique_dp_counts.csv")
  #   library(png)
  #   image1 <- readPNG("./plots/rule_violations_all_all_per1k_stack.png")
  #   image2 <- readPNG("./plots/rule_violations_all_no15_no01_per1k_stack.png")
  #   image3 <- readPNG("./plots/rule_violations_laf_all_per1k_stack.png")
  #   image4 <- readPNG("./plots/rule_violations_laf_no15_no01_per1k_stack.png")
  #   image5 <- readPNG("./plots/rule_violations_src_all_per1k_stack.png")
  #   image6 <- readPNG("./plots/rule_violations_src_no15_no01_per1k_stack.png")
  # 
  # output$download <- downloadHandler(filename = paste0("dqc_slides", Sys.Date(), ".zip"),
  #                                    content = function(file){
  #                                        fs <- c("rule_violations_table_all.csv",
  #                                                "rule_violations_table_laf.csv",
  #                                                "rule_violations_table_src.csv",
  #                                                "rule_violations_all_all_per1k_stack.png"
  #                                                )
  #                                        write.csv(table_all_csv, file = "rule_violations_table_all.csv")
  #                                        write.csv(table_laf_csv, file = "rule_violations_table_laf.csv")
  #                                        write.csv(table_src_csv, file = "rule_violations_table_src.csv")
  #                                        writePNG(image1, target = "rule_violations_all_all_per1k_stack.png")
  #                                        writePNG(image2, target = "./plots/rule_violations_all_no15_no01_per1k_stack.png")
  #                                        writePNG(image3, target = "./plots/rule_violations_laf_all_per1k_stack.png")
  #                                        writePNG(image4, target = "./plots/rule_violations_laf_no15_no01_per1k_stack.png")
  #                                        writePNG(image5, target = "./plots/rule_violations_src_all_per1k_stack.png")
  #                                        writePNG(image6, target = "./plots/rule_violations_src_no15_no01_per1k_stack.png")
  #                                        
  #                                        zip(zipfile = file, files = fs)
  #                                    },
  #                                    contentType = "application/zip")
}

# Run the application 
shinyApp(ui = ui, server = server)
