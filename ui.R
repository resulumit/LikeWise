# ui.R

# load libraries
library(shiny)
library(shinyWidgets)
library(shinyBS)
library(DT)

# Start the UI
fluidPage(
  
  # Style the validation message
  tags$head(tags$style(HTML(".shiny-output-error-validation { color: #ff0000; font-weight: bold; font-size: 15px;}"))),
  
  tags$head(
    
    # CSS Styles for Input Background Colors
    tags$style(HTML("
      /* Define colors for specific inputs */
      .input-background1 {
          background-color: #d4f0f0;
          padding: 10px;
          border-radius: 10px;
          margin-bottom: 10px;
      }
      .input-background2 {
          background-color: #fff5d6;
          padding: 10px;
          border-radius: 5px;
          margin-bottom: 10px;
      }
      .input-background3 {
          background-color: #EAD4EB;
          padding: 10px;
          border-radius: 5px;
          margin-bottom: 10px;
      }
    "),
               HTML(".shiny-output-error-validation { color: #ff0000; font-weight: bold; font-size: 15px;}")  
               ),
    
    # Meta tag for UTF-8 encoding
    tags$meta(charset = "UTF-8")
    
    # Google Analytics
    #, includeHTML("google_analytics.html")
  ),
  
  
  # App title
  titlePanel("LikeWise"),
  
  # Help text
  helpText(
    "An app that filters users' likes on Bluesky", HTML("&mdash;"),
    "by", a("Resul Umit", href = "https://resulumit.com"), "(2024)."
  ),
  
  # Sidebar layout
  sidebarLayout(
    
    # Sidebar panel for inputs
    sidebarPanel(
      
      div(class = "input-background1",
          
      helpText("1. Retrieve the posts"),
      
      # Input: Liked by
      textInput(
        inputId = "liked_by", 
        label = "Liked by", 
        placeholder = "Bluesky handle"
      ),
      
      # Tooltip for Liked by
      bsTooltip(
        id = "liked_by", 
        title = "Handles ending with .bsky.social can be entered with or without the domain ending",
        placement = "top", 
        options = list(container = "body")
      ),
      
      # Input: Search button
      actionButton(inputId = "search_now", label = "Submit")
      
      ),
      
      div(class = "input-background3",
          
      helpText("2. Filter the posts"),
      
      # Input: Posted by
      textInput(
        inputId = "posted_by", 
        label = "Posted by", 
        placeholder = "Bluesky handle or display name includes ..."
      ),
      
      # Tooltip for Posted by
      bsTooltip(
        id = "posted_by", 
        title = "Filter by text pattern",
        placement = "top", 
        options = list(container = "body")
      ),
      
      # Input: Date range
      dateRangeInput(
        "daterange", 
        label = "...within the date range", 
        format = "yyyy/mm/dd", 
        separator = HTML("&ndash;"),
        start = as.POSIXct(Sys.Date() - 365), 
        end = as.POSIXct(Sys.Date())
      ),
      
      # Input: Text search
      textInput(
        inputId = "text_search", 
        label = "...including the pattern", 
        placeholder = "Filter by text pattern"
      ),
      
      # Tooltip for Text search
      bsTooltip(
        id = "text_search", 
        title = "Searching <i>us</i> catches <i>us</i>, <i>bus</i>, <i>US</i>, <i>USA</i> ...",
        placement = "top", 
        options = list(container = "body")
      )
      
      )
      
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      tabsetPanel(
        tabPanel("Table", DT::dataTableOutput(outputId = "table")),
        tabPanel(
          "Notes",
          br(),
          p(
            "The source code is available at", 
            a("https://github.com/resulumit/likewise.", href = "https://github.com/resulumit/likewise")
          ),
          p(
            "Bluesky may limit the number of likes returned. In practice, it may return fewer than the maximum at any given request."
          )
        )
      )
    )
  )
)
