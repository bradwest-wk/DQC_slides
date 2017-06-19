# DQC Errors Slides

This project provides a method for automatically generating a Google Slides presentation of historical Data Quality Committee (DQC) rule violations.  Specifically, the project provides functionality for querying the errors from an arelle database, generating barcharts, and updating an existing Google Slides presentation.

## Getting Started

These instructions will aid you in obtaining a copy of the project and generating the slides.

### Prerequisites

You you will need to have up-to-date copies of Python (3 recommended):


https://www.python.org/downloads/


And R:
 

https://cran.r-project.org/

The user will need to install the following R packages:

```R
install.packages(c('tidyverse', 'lubridate', 'stringr', stringi'))
```

### Generating Slides

There are two entry points for the script:

1. The user can run the R shiny app from the command line by navigating to the project folder and running the command in a shell:
    
```bash
R -e "shiny::runApp('.')"
```
The shiny application will be started on a randomly selected port, and the user can navigate their browser to the given url in order to enter database parameters.

2. Alternatively, the user can modify the file ```./R/main.R``` by specifying the correct database and query parameters.  Then execute:

```bash
sh ./main.sh
```

after making sure the script is executable.  

The script will then use either a flat file or database query to generate the images and data, and then use OAuth2 authentication to gain access to Google Drive and Google Slides in order to generate the slides.
 
## Authors

* **Brad West**

## Acknowledgements

* This project depends heavily on parsing code in R  written by**Allen Bross**and**Michael Lerch**. 

