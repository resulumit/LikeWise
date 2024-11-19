# load the libraries
library(shiny)
library(bskyr)
library(httpuv)
library(DT)
library(dplyr)
library(stringr)
source("the_keys.R")

# Define the server function
function(input, output) {
  
  # Event reactive function to fetch likes
  clicked <- eventReactive(input$search_now, {
    
    # Process the liked_by input to include domain if missing
    processed_liked_by <- trimws(input$liked_by)
    
    # If input ends with a dot, append 'bsky.social'
    if (grepl("\\.$", processed_liked_by)) {
      processed_liked_by <- paste0(processed_liked_by, "bsky.social")
    }
    # If input does not contain any dot, append '.bsky.social'
    else if (!grepl("\\.", processed_liked_by)) {
      processed_liked_by <- paste0(processed_liked_by, ".bsky.social")
    }
    # Else, keep processed_liked_by as is (it already contains a domain)
    
    # Initialize error_message
    error_message <- NULL
    
    # Try to fetch likes using bs_get_likes() with processed_liked_by
    likes_data <- tryCatch(
      {
        bs_get_likes(actor = processed_liked_by)
      },
      error = function(e) {
        # Store the error message
        error_message <<- e$message
        # Return NULL to indicate failure
        return(NULL)
      }
    )
    
    # Validate the result and include the processed_liked_by in the message
    validate(
      need(!is.null(likes_data), 
           paste0("\n",
                  "Something went wrong.\n",
                  "- It could be that there is a spelling error in the username: ", processed_liked_by, "\n",
                  "- It could also be that the servers are overloaded.\n",
                  "\n",
                  "Original Error message: ", error_message)
      )
    )
    
    # Return the likes data
    likes_data
  })
  
  # Render the data table
  output$table <- renderDataTable({
    
    # Process the data
    clicked() %>% 
      # Filter based on inputs
      filter(
        # Filter by posted_by pattern matching in handle or display name
        if (input$posted_by != "") {
          (str_detect(str_to_lower(post_author_handle), str_to_lower(input$posted_by)) | 
             str_detect(str_to_lower(post_author_display_name), str_to_lower(input$posted_by)))
        } else TRUE,
        
        # Filter by date range
        as.Date(post_record_created_at) >= input$daterange[1] & as.Date(post_record_created_at) <= input$daterange[2],
        
        # Filter by text search pattern
        if (input$text_search != "") str_detect(str_to_lower(post_record_text), str_to_lower(input$text_search)) else TRUE,
        
      ) %>% 
      # Create link and formatted date
      mutate(
        rkey = gsub("^.*app.bsky.feed.post/", "", post_uri),
        bs_link = paste0(
          "<a href='https://bsky.app/profile/", 
          post_author_handle, 
          "/post/", 
          rkey, 
          "' target='_blank'>Click here</a>"
        ),
        bs_date = format(as.Date(post_record_created_at), "%Y/%m/%d")
      ) %>% 
      # Select columns to display (removed "Handle")
      select(
        "Post" = post_record_text, 
        "By" = post_author_display_name, 
        "On" = bs_date, 
        "Link" = bs_link
      ) %>% 
      # Return the datatable
      datatable(
        options = list(pageLength = 20),
        rownames = FALSE,
        escape = FALSE
      )
  })
}
