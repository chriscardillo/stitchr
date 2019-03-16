#' Creates a tibble of file paths, preferably for csv files
#'
#' @importFrom dplyr tibble
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
sr_list_files <- function(path = ".", type = "csv"){
  
  file_pattern <- paste0(".", type, "$")
  tibble(sr_path = list.files(path = path, pattern = file_pattern, full.names = TRUE))
  
}

#' Imports files into nested dataframes
#'
#' @importFrom dplyr mutate %>%
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
  
 df %>%
    mutate(sr_filename = basename(sr_path),
           sr_data = map(sr_path, import))
}
