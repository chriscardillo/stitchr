#' Utility function for getting proper column names of the original file in the column names of the dataframe, as well as trimming an excess space between the headers and the start of the data.
#'
#' @param df a dataframe
#' @param row_number an integer specifying the row of the dataframe with proper column headers
#'
#' @return a vector of uniform column names with no leading/trailing whitespace and all lowercase
#'
#' @examples
#' sr_trim_headers(my_df, 4)
#'

sr_trim_headers <- function(df, row_number){
 
  if(row_number != 0){
    
    colnames(df) <- df[row_number, ]
    
    df <- df[-c(1:row_number),]
    
  }
   
  df
  
}



#' Utility function for renaming columns to output column names and reducing dataframes down to the desired columns in the mapping
#'
#' @importFrom dplyr mutate_if bind_cols %>%
#' @importFrom tidyr drop_na
#'
#' @param df a trimmed dataframe - colnames are the actual colnames
#' @param source the determined input source of the dataframe
#' @param mapping the mapping dataframe in its original form
#'
#' @return a dataframe with the desired columns
#'
#' @examples
#' sr_trim_headers(my_df, 4)
#'

sr_rename_columns <- function(df, source, mapping){
  
  map_cols <- c("output", source)
  
  colnames(df) <- colnames(df) %>% sr_clean_colnames()
  
  map_with_na <- mapping[, map_cols]
  
  clean_map <- map_with_na %>% 
    tidyr::drop_na() %>%
    mutate_if(is.character, tolower) %>%
    mutate_if(is.character, trimws)
  
  col_list <- list()
  
  for (i in 1:nrow(clean_map)){
    
    old_col <- clean_map[[i, source]]
    new_col <- clean_map[[i, "output"]]
    
    temp_df <- tibble(df[, old_col])
    colnames(temp_df) = new_col
    
    col_list[[i]] <- temp_df

  }
  
  bind_cols(col_list)
  
}


#' User function for cleanup
#'
#' @importFrom dplyr mutate select %>%
#' @importFrom purrr map2
#'
#' @param matched_files_list the matched file list from sr_match
#' @param mapping the mapping dataframe in its original form
#'
#' @return a dataframe with cleaned nested dataframes ready for compilation
#'
#' @examples
#' sr_cleanup(my_df, my_mapping)
#'
#' @export

sr_cleanup <- function(matched_files_list, mapping){
  
  matched_files_list$matched_files %>%
    mutate(sr_trimmed = map2(sr_data, header_row, sr_trim_headers),
           sr_renamed = map2(sr_trimmed, sr_source, sr_rename_columns, mapping),
           sr_ready = sr_renamed) %>%
    select(sr_filename, sr_source, sr_ready)
    
  
}


