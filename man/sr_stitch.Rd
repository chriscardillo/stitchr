% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stitch.R
\name{sr_stitch}
\alias{sr_stitch}
\title{Single function for stitching together data from disparate sources}
\usage{
sr_stitch(file_path = ".", mapping_path, file_type = "csv",
  with_unmatched = FALSE)
}
\arguments{
\item{file_path}{path to the directory of files}

\item{mapping_path}{path to the .yml mapping file, including the file name}

\item{file_type}{the type of file to compile - no . needed!}

\item{with_unmatched}{if TRUE, will return a list with both the compiled files in 'matched_files' and a tibble of unmatched files in 'unmatched_files'}
}
\value{
a compiled dataframe of all files that were able to be successfully matched
}
\description{
Single function for stitching together data from disparate sources
}
