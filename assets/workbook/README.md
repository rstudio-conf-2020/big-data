

```r
usethis::use_course("https://github.com/rstudio-conf-2020/big-data")
```

```r
install.packages(
  c("vroom", "fs", "purrr", "dplyr", "data.table", "dtplyr", "lobstr", 
    "ggplot2", "tidyr", "DBI", "RSQLite", "connections", "dbplyr", "dbplot", 
    "leaflet", "sparklyr", "wordcloud2", "readr")
    )
```

```r
source("assets/setup/data_setup.R")
```

```r
setup_sqlite(100)
```

```r
source("assets/workbook/_build.R")
```


