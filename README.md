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

`stitchr` takes this mapping and converts it to a dataframe which is then used to identify which files are of a certain input source, and then alters the input source's column names in order to compile all files from every source into an aggregated state.
