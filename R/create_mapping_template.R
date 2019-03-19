#' User function for standing up a short .yml mapping template to get started
#'
#' @importFrom yaml write_yaml
#' @importFrom tools file_ext
#'
#' @param mapping_file_name the desired name of the .yml map. Defaults to "_mapping.yml", but can be called anything that ends in ".yml"
#'
#' @return a new .yml mapping template
#'
#' @examples
#' sr_create_mapping_template()
#' sr_create_mapping_template("my_awesome_map.yml")
#' 
#' @export

sr_create_mapping_template <- function(mapping_file_name = "_mapping.yml"){

if(tools::file_ext(mapping_file_name) != "yml"){
  
  stop(paste0(mapping_file_name, " is not an acceptable file type. Variable 'mapping_file_name' must end with '.yml'."))
  
}
  
mapping_template <- list(output = list(columns = c("output_column_1", 
                                                   "output_column_2")), 
                         inputs = list(source_1 = list(output_column_1 = "source_1_colname_1",
                                                       output_column_2 = "source_1_colname_2"),
                                       source_2 = list(output_column_1 = "source_2_colname_1",
                                                       output_column_2 = "source_2_colname_2")))


yaml::write_yaml(mapping_template, mapping_file_name)

file.edit(mapping_file_name)

}
