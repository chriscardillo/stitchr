#' User function for cleanup
#'
#' @importFrom dplyr mutate_if %>%
#'
#' @param df a dataframe in need of characterized uniformity
#'
#' @return a dataframe that is all character
#'
#' @keywords internal


sr_make_character_frames <- function(df){
  
  df %>%
    mutate_if(is.numeric, as.character) %>%
    mutate_if(is.logical, as.character)
  
}


#' User function for compilation
#'
#' @importFrom dplyr mutate tibble everything select_at %>%
#' @importFrom tidyr drop_na spread
#'
#' @param df the final cleaned dataframe from sr_cleanup
#' @param mapping the dataframe mapping from sr_mapping
#'
#' @return a dataframe that is all character
#'
#' @export


sr_compile <- function(df, mapping){
  
  mapping_cols <- attr(mapping, "output_columns")
  
  base <- tibble(mapping_cols) %>%
    mutate(DELETE = NA) %>%
    spread(key = mapping_cols, value = DELETE) %>%
    drop_na()
  
  
  compiled <- df %>%
    mutate(sr_to_compile = map(sr_ready, sr_make_character_frames)) %>%
    select(-sr_ready) %>%
    tidyr::unnest() 
  
  base %>%
    select_at(mapping_cols) %>%
    bind_rows(compiled) %>%
    select(sr_filename, sr_source, everything())
  
}
