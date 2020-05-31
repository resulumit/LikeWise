# server.R

# load the libraries
library(shiny)
library(rtweet)
library(DT)
library(dplyr)
library(stringr)


# start the function
function(input, output) {
  
  # start eventReactive
  clicked <- eventReactive(input$search_now,{
    
    # validate for any problems
    validate(need(length(get_favorites(user = input$liked_by, n = 1)) != 0, 
                  "Something went wrong. 
                   - It could be that there is a spelling error in the username.
                   - It could also be that the servers are overloaded."))

    # get_favorites() from the rtweet package
    get_favorites(user = input$liked_by, n = 10)
      
  # end eventReactive  
  }
  )
  
  # start the table
  output$table <- renderDataTable(
    
    # the table
    clicked() %>% 
      
      filter(if (!is.null(input$tweeted_by)) str_detect(str_to_lower(screen_name), str_to_lower(input$tweeted_by)),
             as.Date(created_at) >= input$daterange[1] & as.Date(created_at) <= input$daterange[2],
             if (!is.null(input$text_search)) str_detect(str_to_lower(text), str_to_lower(input$text_search))) %>% 
      
      # 
      mutate(tw_link = paste0("<a href='","https://twitter.com/", screen_name, "/status/", status_id, "' target='_blank'>", "Click here","</a>"),
             tw_date = format(as.Date(created_at), "%d/%m/%Y")) %>% 
      
      # select variables
      select("Tweet" = text, "By" = screen_name, "On" = tw_date, "Link" = tw_link),
                                      
      # Options: DT
      options = list(pageLength = 20),
      
      # Options: datatable
      rownames = FALSE,
      escape = FALSE
    
    # end the table
    )

# end the function
}
