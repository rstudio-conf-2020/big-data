## Early view 

1. Download the course using `usethis`
```r
usethis::use_course("https://github.com/rstudio-conf-2020/big-data/archive/master.zip")
```

2. Make sure that the necessary packages are installed (optional)
```r
install.packages(
  c("vroom", "fs", "purrr", "dplyr", "data.table", "dtplyr", "lobstr", 
    "ggplot2", "tidyr", "DBI", "RSQLite", "connections", "dbplyr", "dbplot", 
    "leaflet", "sparklyr", "wordcloud2", "readr", "bookdown")
    )
```

3. Load the functions that create the data
```r
source("assets/setup/data_setup.R")
```

4. Run `setup_sqlite()` with 100 as the number of daily transactions. Increasing that number will make the data larger.
```r
setup_sqlite(100)
```

5. Start using the exercises in the Rmd files (except for index.Rmd)
