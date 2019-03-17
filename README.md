# stitchr
For stitching together files from disparate sources

-----

## Installation

You can install `stitchr` with `devtools::install_github("chriscardillo/stitchr")`.


## Quick Start

In two short files, we can can map out, import, and aggregate all desired information in a given directory.

`app.R`
```r
library(stitchr)

sr_stitch("path/to/files", "_mapping.yml", type = "csv")
```

`_mapping.yml`
```yml
output:
  columns:
    - output_column_1
    - output_column_2
inputs:
  source_1:
    output_column_1: source1_colname_1
  source_2:
    output_column_1: source2_colname_1
    output_column_2: source2_colname_2
```

This setup with return a single tibble containing any `source_1` or `source_2` files located in `path/to/files`, where all column names from these sources are now `output_column_1` or `output_column_2`. Additionally in the tibble are the orginal file names and `stitchr`-determined sources in columns `sr_filename` and `sr_source`, respectively.

## Overview

`stitchr` aims to provide a service for aggregating data from multiple sources easily. At the center is the `sr_stitch()` function, which when pointed at a directory reads all files of a specific file type (preferably `.csv`), and organizes them into a single tibble. `sr_stitch()` is informed of each file's potential source by the `_mapping.yml` file. 

`_mapping.yml` contains all of the column names for each of the `inputs`, and all of the desired unified column names that will display in the final `output`. The `.yml` is organized like so:


```yml
output:
  columns:
    - output_column
inputs:
  source_1:
    output_column: source1_colname
  source_2:
    output_column: source2_colname
```

For example, if two reports had different names for `Revenue`, e.g. `Profit` and `Total`:

```yml
output:
  columns:
    - revenue
inputs:
  US Treasury:
    revenue: profit
  Federal Reserve:
    revenue: total
```

When pointed at the directory where these `US Treasury` and `Federal Reserve` files might be, `sr_stitch()` uses the above `.mapping.yml` to identify the source of each file by its column names, and will then proceed to compile together any files matched through the mapping.

## Supporting Functions

Behind `sr_stitchr()` are a few different stages, each with a primary function. When ran in sequence, these primary functions are the equivalent of a call to `sr_stitchr()`.

###Import

```r
library(stitchr)

sr_import("path/to/files", type = "csv") # only looks for .csv files
```

The above creates a tibble all files paths in a certain directory that are of a specific file type and then imports all of those files in the form of nested dataframes. `stitchr` will adhere to column names that start with `sr_` for any column that persist to the final output of `sr_stitchr()`.

Additionally, `sr_import()` defaults to looking for .csv files, but this can be amended with the `type` parameter.

###Mapping

`sr_mapping()` imports and interprets `_mapping.yml`, then converts it into a useful object utilized in all later stages (e.g. `sr_match()`, `sr_cleanup()`).

A reminder of what our boilerplate `_mapping.yml` looks like:

`_mapping.yml`
```yml
output:
  columns:
    - output_column
inputs:
  source_1:
    output_column: source1_colname
  source_2:
    output_column: source2_colname
```

In the above, the topmost levels are `output` and `inputs`.

The `output` level tells `stitchr` what the desired column names should be in the final final aggregated file. These column names are housed under `columns`, and must be in a sequence under the `columns` level.

The `inputs` level tells `stitchr` what potential files its looking for through the use of different input sources. Each input source contains key-value pairs for that map the desired final output column names to the existing column names of the input source.

### Friendly Notes on `_mapping.yml`

- All `output_column`s within the `inputs` layer must also be in the `output`'s `columns`.
- `sr_mapping()` test for other common errors here, and will raise a helpful exception if `_mapping.yml` needs editing.

###Match

`sr_match()` takes the above mapping from `sr_mapping()` along all of the raw data from `sr_import()` then uses column names to identify which files are of a certain input source.

Running sequentially, the below code will provide a list a `matched_files` dataframe and `unmatched_files` dataframe for you:

```r

my_data <- sr_import("path/to/files")

my_mapping <- sr_mapping("path/to/_mapping.yml") # you can name your mapping whatever you want

sr_match(my_data, my_mapping)

```

For the `matched_files` dataframe, an `sr_source` column notes which source the file was determined to be by `sr_match()`, and a `header_row` column denotes on which row of the raw data the headers denoted in the mapping currently are. `header_row` is not preceded with an `sr_` because it is a utility column later discarded during `sr_cleanup()`.

###Cleanup

`sr_cleanup()` expects the list output from `sr_match()`, and will solely focus on `matched_files`.

After files have been matched to a source, `sr_cleanup()` can replace existing inputs' column names with the desired output columns, as well as ensure all columns are prepped for compilation.

Continuing the example:

```r

my_data <- sr_import("path/to/files")

my_mapping <- sr_mapping("path/to/_mapping.yml") # you can name your mapping whatever you want

my_match <- sr_match(my_data, my_mapping)

my_cleanup <- sr_cleanup(my_match, my_mapping)

```

### Compile

Lastly, `sr_compile()` stacks the now-uniform datasets into a single tibble, along with the `sr_filename` and `sr_source` columns, which provide the orginal file name and the source `stitchr` determined to be for each file.

## Other `sr_stitch()` Features

While `sr_stitch()` provides a warning message for any files that could not be matched, both the `matched_files` and `unmatched_files` can be returned in a list by including `with_unmatched = TRUE` in the call to `sr_stitch()`.
