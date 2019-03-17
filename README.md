# stitchr
For stitching together files from disparate sources

-----

## Quick Start

An `.R` file that looks like this:

```r
library(stitchr)

sr_stitch("path/to/files", "_mapping.yml", type = "csv")

```

A `.yml` file that looks like this:

```yml
output:
  columns:
    - output_column_1
    - output_column_2
inputs:
  input_source_1:
    output_column_1: corresponding_input_source_1_col_name
    output_column_2: corresponding_input_source_1_col_name
  input_source_2:
    output_column_1: corresponding_input_source_2_col_name
```

## Overview

The goal of `stitchr` is to provide an easy interface for taking many files and turning them into one. This is done with a series of functions that build on top of one another.

**For importing data:**

```r
library(stitchr)

sr_import("path/to/files", type = "csv") # only looks for .csv files
```

The above creates a tibble all files paths in a certain directory that are of a specific file type and then imports all of those files in the form of a nested dataframe. `stitchr` will adhere to column names that start with `sr_` for any column that persists to the final output.

Additionally, `sr_import()` defaults to looking for .csv files, but this can be amended with the `type` parameter. However, in my experience a .csv is the most trustworthy source of human-editable data due to it's singe-sheet consistency.

**For creating file mappings:**

The goal of `stitchr` is to make it easy to map multiple files to a single output. It accomplishes this task through the use of a mapping system via a `.yml` file. The `.yml` file will look something like this:

```yml
output:
  columns:
    - output_column_1
    - output_column_2
    - output_column_3
inputs:
  input_source_1:
    output_column_1: corresponding_input_source_1_col_name
    output_column_2: corresponding_input_source_1_col_name
    output_column_3: corresponding_input_source_1_col_name
  input_source_2:
    output_column_1: corresponding_input_source_2_col_name
    output_column_2: corresponding_input_source_2_col_name
```

In the above, the topmost levels are `output` and `inputs`.

The `output` level tells `stitchr` what the desired column names should be in the final final aggregated file. These column names are housed under `columns`, and must be in a sequence under the `columns` level.

The `inputs` level tells `stitchr` what potential files its looking for through the use of different input sources. Each input source contains key-value pairs for that map the desired final output column names to the existing column names of the input source.

This `.yml` is converted to a dataframe mapping with the `sr_mapping()` function.

**For matching raw files to mapping:**

`stitchr` takes this above mapping and converts it to a dataframe which is then used to identify which files are of a certain input source. This is done with the `sr_match` function.

If you've set up your `.yml` mapping, the below code will provide a list a `matched_files` dataframe and `unmatched_files` dataframe for you:

```r

my_data <- sr_import("path/to/files")

my_mapping <- sr_mapping("path/to/_mapping.yml") # you can name your mapping whatever you want

sr_match(my_data, my_mapping)

```

For the `matched_files` dataframe, an `sr_source` column notes which source the file was determined to be, and a `header_row` column denotes on which row of the raw data the headers denoted in the mapping currently are.

Ideally all of these column headers would be the column headers of the file, and - of course - the column headers would all be our desired output column headers. For this, we'll utilize `sr_cleanup()`

**For creating file uniformity**

After files have been matched to a source, their column names can be replaced with the desired output columns, and any superfluous space between the column names and the actual data can be removed. This is done with `sr_cleanup()`.

Sticking with the example above:

```r

my_data <- sr_import("path/to/files")

my_mapping <- sr_mapping("path/to/_mapping.yml") # you can name your mapping whatever you want

my_match <- sr_match(my_data, my_mapping)

sr_cleanup(my_match, my_mapping)

```

`sr_cleanup` expects the list output from `sr_match()`, and will solely focus on the matched files.

**For binding uniform files**

Lastly, we'll use `sr_compile()` to safely unnest our uniform data. This is done by coercing all non-character columns to characters.
