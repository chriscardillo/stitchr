#' \code{stitchr} package
#'
#' For stitching together files from disparate sources
#'
#' See the README on
#' or \href{https://github.com/chriscardillo/stitchr#readme}{GitHub}
#'
#' @docType package
#' @name stitchr

NULL

## quiets concerns of R CMD check re: any non-standard evaluation
if(getRversion() >= "2.15.1"){
  utils::globalVariables(c("passing",
                           "sr_data",
                           "header_row",
                           "sr_trimmed",
                           "sr_source",
                           "sr_renamed",
                           "sr_filename",
                           "sr_ready",
                           "DELETE",
                           "input",
                           "rownum",
                           "data",
                           "data_colnames",
                           "file_not_matched",
                           "sr_filename",
                           "source_col_length",
                           "source_colnames",
                           "sr_path",
                           "output",
                           "column_name",
                           "row_num"))
}
