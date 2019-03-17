#' Single function for stitching together data from disparate sources
#'
#' @importFrom dplyr %>%
#'
#' @param file_path path to the directory of files
#' @param mapping_path path to the .yml mapping file
#'
#' @return a compiled dataframe of all files that were able to be successfully matched
#'
#' @examples
#' sr_stitch("my/csvs/path", "_mapping.yml")
#'
#' @export

sr_stitch <- function(file_path, mapping_path, file_type = "csv"){
  
  import <- sr_import(file_path, type = file_type)
  
  mapping <- sr_mapping(mapping_path)
  
  match <- sr_match(import, mapping)
  
  cleanup <- sr_cleanup(match, mapping) 
  
  if(length(match$unmatched_files) > 0){
    warning(
      paste0("Some files were unable to be matched: ", 
             paste0(match$unmatched_files %>% distinct() %>% pull(), collapse = ", "))
      )
  }
  
  
  
  return(sr_compile(cleanup, mapping))
  
  
  
}