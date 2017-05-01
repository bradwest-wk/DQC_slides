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
     textInput(inputId = "directory", label = "Directory for Slides:", value = "~/Downloads"),
     textInput(inputId = "dbserver", label = "Database Server:"),
     textInput(inputId = "dbname", label = "DB name:"),
     textInput(inputId = "username", label = "DB username:"),
     passwordInput(inputId = "password", label = "DB password:"),
     numericInput(inputId = "dbport", label = "DB port:", value = 8084),
     radioButtons(inputId = "data_source", label = "Rule data from file or DB query:",
                  choices = c("Query" = "database", "csv File" = "file"), selected = "database"),
     # maybe change multiple to TRUE at some point?
     textInput(inputId = "file_input", label = "Enter rules csv file if csv file checked:",
               value = ""),
     radioButtons(inputId = "data_source_counts", label = "Error count data from file or DB query:",
                  choices = c("Query" = "database", "csv File" = "file"), selected = "file"),
     textInput(inputId = "counts_file_input", label = "Enter errors csv file if csv file checked:",
               value = ""),
     dateInput(inputId = "start_date", label = "Period start date (inclusive):", value = "2016-01-01"),
     dateInput(inputId = "end_date", label = "Period end date (exclusive):", value = "2017-04-01"),
     textInput(inputId = "file_output", label = "Slide output file name:", value = ,"DQC_Rule_Results.html")
     ),
     
      
      mainPanel(
        actionButton(inputId = "slides", label = "Generate Slides", width = '100%')
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # setwd("/Users/bradwest/Google_Drive/Projects/DQ_requests/DQC_slides")
  
  observeEvent(input$slides, {
  
    
    # Can't place parameterized markdown doc in same folder as shiny app.  Need to create temp folder and copy into
    # tempReport <- file.path(tempdir(), "slides_HTML_parameterized.Rmd")
    # file.copy("/Users/bradwest/Google_Drive/Projects/DQ_requests/DQC_slides/DQC_Rule_Results/slides_HTML_parameterized.Rmd", tempReport, overwrite = TRUE)
    
    # render the slides
      rmarkdown::render("/Users/bradwest/Google_Drive/Projects/DQ_requests/DQC_slides/slides_HTML_parameterized.Rmd",
                        output_format = "ioslides_presentation",
                        output_file = as.character(input$file_output),
                        params = list(directory = as.character(input$directory),
                                      username = as.character(input$username),
                                      password = as.character(input$password),
                                      dbserver = as.character(input$dbserver),
                                      dbport = as.numeric(input$dbport),
                                      dbname = as.character(input$dbname),
                                      data_source = as.character(input$data_source),
                                      file_input = as.character(input$file_input),
                                      data_source_counts = as.character(input$data_source_counts),
                                      counts_file_input = as.character(input$counts_file_input),
                                      start_date = as.character(input$start_date),
                                      end_date = as.character(input$end_date))
                        )
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

