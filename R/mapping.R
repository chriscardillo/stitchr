#' Tests that there is an output level in the .yml map, and that there is a columns parameter under it
#'
#' @param map_list the list object created from reading in a yaml file
#'
#' @return an error if output does not exist
#'
#' @export

sr_check_yml_output_exists <- function(map_list){
  
  test <- "output" %in% names(map_list)
  
  if(!test){
    stop(message("output missing from top level of yml mapping file."))
  }
  
  test2 <- "columns" %in% names(map_list$output)
  
  if(!test2){
    stop(message("columns level missing from output."))
  }
  
}


#' Tests that output columns are all unique
#'
#' @param output_columns the vector of desired columns in the final output
#'
#' @return an error if output columns are not unique
#'
#' @export

sr_check_yml_unique_output_cols <- function(output_columns){
  
  test <- length(output_columns) == length(unique(output_columns))
  
  if(!test){
    stop(message("output columns are not unique"))
  }
  
}


#' Tests that output columns are all unique
#'
#' @param map_list the list object created from reading in a yaml file
#'
#' @return an error if there is no inputs level at the top of the yaml
#'
#' @export

sr_check_yml_inputs_exists <- function(map_list){
  
  test <- "inputs" %in% names(map_list)
  
  if(!test){
    stop(message("inputs missing from top level of yml mapping file."))
  }
  
}


#' Tests that columns present in the input mappings are all present in the output columns
#'
#' @importFrom purrr map as_vector
#' @importFrom dplyr filter as_tibble %>%
#' @importFrom tidyr gather
#'
#' @param potential_inputs the list of potential input sources from the yaml
#' @param output_columns a vector of output columns from the yaml
#'
#' @return an error if there are designated output values in the inputs that are not present in the output columns
#'
#' @export

sr_check_yml_io_match <- function(potential_inputs, output_columns){
  
  test <- potential_inputs %>% 
    purrr::map(names) %>%
    purrr::map(~ .x %in% output_columns) %>%
    purrr::map(~ all(.x)) %>%
    purrr::as_vector() %>%
    as.list() %>%
    dplyr::as_tibble() %>%
    tidyr::gather(key = "input_source", value = "passing") %>%
    dplyr::filter(passing == FALSE)
  
  if(nrow(test) > 0){
    stop(message(paste0("The following sources have designated output columns not present in the output: ",
                        paste0(test$input_source, collapse = ", "))))
  }
  
}


#' Utility function housing all yml map checks, passes through the map as a list object if all tests pass
#'
#' @importFrom yaml yaml.load_file
#'
#' @param yml_map path to a yml_map file
#'
#' @return an error if any tests fail, otherwise a list object of the file mappings
#'
#' @export

sr_check_yml <- function(yml_map){
  
  map_list <- yaml::yaml.load_file(yml_map)
  
  output_columns <- map_list$output$columns
  
  potential_inputs <- map_list$inputs
  
  sr_check_yml_inputs_exists(map_list)
  sr_check_yml_output_exists(map_list)
  sr_check_yml_unique_output_cols(output_columns)
  sr_check_yml_io_match(potential_inputs, output_columns)
  
  map_list
  
}

#' Converts list map into a dataframe mapping
#'
#' @importFrom purrr map as_vector
#' @importFrom dplyr bind_rows %>%
#' @importFrom tidyr gather spread
#'
#' @param map_list a list object of the yml map
#'
#' @return a dataframe of the file mapping
#'
#' @export

sr_convert_yml <- function(map_list){
  
  mapping <- purrr::map(map_list$inputs, purrr::as_vector) %>% 
    purrr::map(as.list) %>% 
    purrr::map(dplyr::as_tibble) %>%
    dplyr::bind_rows(.id = "sr_source") %>%
    tidyr::gather(key = "output", value = "input", -sr_source) %>%
    tidyr::spread(sr_source, input)
  
  attr(mapping, 'output_columns') <- map_list$output$columns
  
  mapping
  
}


#' User function for reading in a yml mapping and concerting to a dataframe
#'
#' @param yml_map path to a yml_map file
#'
#' @return A dataframe version of the file mapping
#'
#' @export

sr_mapping <- function(yml_map){
  
  sr_check_yml(yml_map) %>%
    sr_convert_yml()
  
}

