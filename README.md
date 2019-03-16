# stitchr
An R Package for stitching together files

-----

### Overview

The goal of `stitchr` is to provide an easy interface for taking many files and turning them into one. This is done with a series of functions that build on top of one another.

*For importing:*

```r
library(stitchr)

sr_list_files("path/to/files", type = "csv") %>% # only looks for .csv files
  sr_nested_import()
```

The above simply creates a tibble all files paths in a certain directory that are of a specific file type and then imports all of those files in the form of a nested dataframe. `stitchr` will adhere to column names that start with `sr_` for any tibble columns it creates.
