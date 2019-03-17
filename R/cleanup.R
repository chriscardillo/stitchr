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