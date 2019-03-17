# stitchr
For stitching together files from disparate sources

-----

### Overview

The goal of `stitchr` is to provide an easy interface for taking many files and turning them into one. This is done with a series of functions that build on top of one another.

**For importing data:**

```r
library(stitchr)

sr_import_data("path/to/files", type = "csv") # only looks for .csv files
```

The above creates a tibble all files paths in a certain directory that are of a specific file type and then imports all of those files in the form of a nested dataframe. `stitchr` will adhere to column names that start with `sr_` for any tibble columns it creates.


**For creating file mappings **

The goal of `stitchr` is to make it easy to map multiple files to a single output. It accomplishes this task through the use of a mapping system via a .yml file. The .yml file will look something like this:

```yml
output:
  columns:
    - output_column_1
    - output_column_2
    - output_column_3
inputs:
  input_source_1:
    output_column_1: period start
    output_column_2: spend
    output_column_3: impressions
  input_source_2:
    output_column_1: day
    output_column_2: gross cost
```
