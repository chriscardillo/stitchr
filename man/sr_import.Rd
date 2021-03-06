% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import.R
\name{sr_import}
\alias{sr_import}
\title{Imports files from a directory into nested dataframes and includes file names}
\usage{
sr_import(path = ".", type = "csv")
}
\arguments{
\item{path}{a path to a directory with files}

\item{type}{file type to compile - no . needed!}
}
\value{
a tibble file names and nested dataframes
}
\description{
Imports files from a directory into nested dataframes and includes file names
}
