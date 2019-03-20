#' Utility function for keeping column names consistent in terms of white space and case
#'
#' @importFrom dplyr %>%
#'
#' @param colnames a vector of column names
#'
#' @return a vector of uniform column names with no leading/trailing whitespace and all lowercase
#'
#' @keywords internal

sr_clean_colnames <- function(colnames){
  colnames %>% tolower() %>% trimws(which = "both")
}


#' Utility function for putting inputs' column names in to a place they can be evaluated against nested raw data 
#'
#' @importFrom dplyr select group_by mutate %>%
#' @importFrom tidyr gather nest
#' @importFrom purrr map
#'
#' @param file_mapping a dataframe of our file mapping
#'
#' @return a nested dateframe where each row is a source and each row has clean vectorized column names
#'
#' @keywords internal

sr_make_input_colnames <- function(file_mapping){

  file_mapping %>%
    dplyr::select(-output) %>%
    tidyr::gather(sr_source, column_name) %>%
    dplyr::group_by(sr_source) %>%
    tidyr::nest() %>%
    dplyr::mutate(source_colnames = purrr::map(data, ~ as_vector(.x) %>% sr_clean_colnames() %>% na.omit())) %>%
    dplyr::select(-data)
    
}


#' Utility function for finding the row in a dataframe where column names from an input source are. (Sometimes meta data lives at the top of csv reports. We want to get rid of that)
#'
#' @importFrom dplyr select group_by mutate pull %>%
#' @importFrom tidyr nest
#' @importFrom purrr map
#'
#' @param df a dataframe we want to find the header row of
#' @param source_colnames a vector of column names we wish to evaluate the dataframe against
#' @param check_length in the event df's colnames are not the desired source_colnaes, the number of rows under the column headers to check for the column names
#'
#' @return an integer with the row number of the correct column names - 0 if the column names are correct already, NA if the column names were not found
#'
#' @keywords internal


sr_find_header_row <- function(df, source_colnames, check_length = 100){
  
  df_col_names <- colnames(df) %>% sr_clean_colnames()
  
  source_colnames <- source_colnames %>% sr_clean_colnames()
  
  if(all(source_colnames %in% df_col_names)){
    0
  } else {
    
    if (nrow(df) < check_length){
      check_length <- nrow(df) - 1
    }
    
    df[1:check_length, ] %>%
      mutate(rownum = row_number()) %>%
      group_by(rownum) %>%
      nest() %>%
      mutate(data_colnames = map(data, sr_clean_colnames),
             eval = map(data_colnames, ~ all(source_colnames %in% .x)) %>% unlist()) %>%
      filter(eval == TRUE) %>%
      select(rownum) %>%
      utils::head(1) %>%
      pull(rownum)
  }
  
}


#' Takes raw nested data and nested input mapping to identify header rows / which files could be matched
#'
#' @importFrom dplyr group_by ungroup mutate %>%
#' @importFrom tidyr crossing
#' @importFrom purrr map_int map2
#'
#' @param df_nested_imports dataframe of file names and nested data
#' @param input_colnames_df dataframe of input sources and nested desired colnames
#'
#' @return a crossing table with all input sources and which ones matched to each file. WARNING: FILES CAN MATCH TO MULTIPLE SOURCES AT THIS STAGE. DO NOT USE THIS FUNCTION AS AN END USER.
#'
#' @keywords internal

sr_match_sources <- function(df_nested_imports, input_colnames_df){

  df_nested_imports %>%
    crossing(input_colnames_df) %>%
    mutate(header_row = map2(sr_data, source_colnames, sr_find_header_row) %>% as.integer(),
           source_col_length = map_int(source_colnames, length)) %>%
    group_by(sr_filename) %>%
    mutate(file_not_matched = all(is.na(header_row))) %>%
    ungroup()

}


#' Takes full matched and unmatched files then reduces them down to their top matches / separates unmatched files
#'
#' @importFrom dplyr select filter distinct arrange group_by ungroup mutate desc row_number %>%
#' @importFrom tidyr crossing
#' @importFrom purrr map_int map2
#'
#' @param matched_df evaluated nested data with sources attached
#'
#' @return a list with two items: one for matched files (matched_files) and one for unmatched files (unmatched_files)
#'
#' @keywords internal

sr_handle_matched_files <- function(matched_df){

  unmatched_files <- matched_df %>%
    dplyr::filter(file_not_matched == TRUE) %>%
    dplyr::distinct(sr_filename)

  matched_files <- matched_df %>%
    dplyr::select(-file_not_matched) %>%
    dplyr::filter(!is.na(header_row)) %>%
    dplyr::arrange(sr_filename, desc(source_col_length)) %>%
    dplyr::group_by(sr_filename) %>%
    dplyr::mutate(row_num = row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::filter(row_num == 1) %>%
    dplyr::select(-row_num, -source_colnames, -source_col_length)


  list(matched_files = matched_files, 
       unmatched_files = unmatched_files)
  

}


#' User function for taking nested raw data and file mapping to identify matched and unmatched files
#'
#'
#' @param nested_raw_data that comes from sr_import_data
#' @param file_mapping file map that comes from sr_yml_map
#'
#' @return a list with two items: one for matched files (matched_files) and one for unmatched files (unmatched_files)
#'
#' @export

sr_match <- function(nested_raw_data, file_mapping){

  input_colnames_df <- sr_make_input_colnames(file_mapping)
  matched_sources <- sr_match_sources(nested_raw_data, input_colnames_df)
  sr_handle_matched_files(matched_sources)

}
