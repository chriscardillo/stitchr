#' Creates a tibble of file paths, preferably for csv files
#'
#' @importFrom dplyr tibble rename quo %>%
#' 
#' @param path Relative path of file
#' @param type file type, e.g. "csv"
#'
#' @return a tibble of file names
#'
#' @examples
#' sr_list_files("path/to/data")
#'
#' @export
sr_list_files <- function(path = ".", type = "csv", path_column = "path"){
  
  file_pattern <- paste0(".", type, "$")
  tibble(!!path_column := list.files(path = path, pattern = file_pattern, full.names = TRUE))
  
}

#' Imports files into nested dataframes
#'
#' @importFrom dplyr rename mutate quo_name enquo %>%
#' @importFrom purrr map
#' @importFrom rio import
#' 
#' @param df a dataframe with file paths
#' @param path_column the name of the path column
#'
#' @return a tibble of file names
#'
#' @examples
#' sr_list_files("path/to/data") %>% 
#' sr_nested_import()
#'
#' @export
sr_nested_import <- function(df, path_column = NULL){
  
  path_column <- enquo(path_column)
  path_column_name <- quo_name(path_column)
  
  if(path_column_name == "NULL"){
    
    df <- df %>%
      mutate(data = map(path, import))
    
  } else {
    
    df <- df %>%
      mutate(data = map(!!path_column, import))
    
  }
   
  df 
  
}
