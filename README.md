Big Data with R
================

### rstudio::conf 2020

Interested? See registration information here: [RStudio Conference 2020](https://web.cvent.com/event/36ebe042-0113-44f1-8e36-b9bc5d0733bf)


-----

:spiral_calendar: January 27 and 28, 2020  
:alarm_clock:     09:00 - 17:00  
:hotel:           \[ADD ROOM\]  
:writing_hand:    [RStudio Conference 2020](https://web.cvent.com/event/36ebe042-0113-44f1-8e36-b9bc5d0733bf)

-----

* [Overview](#overview)
  * [Learning Objectives](#learning-objectives)
  * [Is this course for me?](#is-this-course-for-me)
* [Pre-work](#prework)
* [Equipment](#equipment)
* [Schedule](#schedule)
* [Instructors](#instructors)
* [Class Outline](#class-outline)

-----

## Overview

This 2-day workshop covers how to analyze large amounts of data in R.  We will focus on scaling up our analyses using the same dplyr verbs that we use in our everyday work. We will use dplyr with data.table, databases, and Spark.  We will also cover best practices on visualizing, modeling, and sharing against these data sources.  Where applicable, we will review recommended connection settings, security best practices, and deployment options.

### Learning objectives

In this 2-day workshop, attendees will learn how to connect to and analyze large scale data

### Is this course for me?

You should take this workshop if you want to learn how to work with big data in R. This data can be in-memory, in databases (like SQL Server), or in a cluster (like Spark).

## Prework

### Helpful reading

Some have asked for material that would be useful to review prior to the class.  The following is a compilation of subjects would be great if you are familiar with already by the time the class begins, but it is not a requirement that you study or review them. 

* Data Transformation - http://r4ds.had.co.nz/transform.html
* Relational Data - http://r4ds.had.co.nz/relational-data.html
* Data visualization - http://r4ds.had.co.nz/data-visualisation.html

For database background, please review the articles in the following links:

* Database Best Practices - http://db.rstudio.com/best-practices/
* Databases using dplyr - http://db.rstudio.com/dplyr/

For spark background, please review the following:

* sparklyr’s website home page: http://spark.rstudio.com/
* Using dplyr with sparklyr: http://spark.rstudio.com/dplyr/
* Machine Learning: http://spark.rstudio.com/mlib/
* Deployment options: http://spark.rstudio.com/deployment/

## Equipment

**We plan to provide a personal server to each student for use during the class.**  The server will contain all of the applications and materials needed, including R and RStudio.  **All you will need is a laptop with a web browser.**  For those of you that need to use their work provided laptops for the class, please ensure that the web browser in it will not be prevented from navigating to Amazon AWS, which is where the servers will be set up.

## Schedule

| Time          | Activity         |
| :------------ | :--------------- |
| 09:00 - 10:30 | Session 1        |
| 10:30 - 11:00 | *Coffee break*   |
| 11:00 - 12:30 | Session 2        |
| 12:30 - 13:30 | *Lunch break*    |
| 13:30 - 15:00 | Session 3        |
| 15:00 - 15:30 | *Coffee break*   |
| 15:30 - 17:00 | Session 4        |

## Instructors

<img src="https://avatars1.githubusercontent.com/u/7875923?s=460&v=4" width="100"/> 

**Edgar Ruiz**

Solutions Engineer @ RStudio

Twitter: [theotheredgar](https://twitter.com/theotheredgar)

LinkedIn: [edgararuiz](https://www.linkedin.com/in/edgararuiz/)

<img src="https://avatars2.githubusercontent.com/u/10444878?s=460&v=4" width="100"/> 

**James Blair** 

Solutions Engineer @ RStudio 

Twitter: [Blair09M](https://twitter.com/Blair09M) 

LinkedIn: [blairjm](https://www.linkedin.com/in/blairjm/) 

## Class Outline

The following is a tentative outline of the subjects that will be covered during the class.  The content and order is subject to change. 

  - Introduction to `vroom`
    - `vroom` basics
    - Load multiple files
    - Load and modify multiple files
  - Introduction to `dtplyr`
    - `dtplyr` basics
    - Object sizes
    - How `dtplyr` works
    - Working with `dtplyr`
    - Pivot data
    - The `mutate()` verb
  - Introduction to `DBI`
    - Local database basics
    - Options for writing tables
    - Error: Table db_mtcars exists in database, and both overwrite and append are FALSE
    - Database operations
    - `knitr` SQL engine
  - Databases and `dplyr`
    - Intro to `connections`
    - Table reference
    - Under the hood
    - Un-translated R commands
    - Using bang-bang
    - Table joins
    - Custom view
  - Data Visualizations
    - Simple plot
    - Plot in one code segment
    - Create a histogram
    - Raster plot
    - Using the `calculate` functions
  - Modeling with databases
    - Single step sampling
    - Multi-step sampling
    - Use Job panel in RStudio
    - Run predictions in DB
    - Fit model in R
    - Score with `tidypredict`
    - Save and reload models
    - Integration with `tidymodels`
    - Run models in DB
    - Intro to `modeldb`
    - `modeldb` with `tidypredict`
  - Advanced Operations
    - Simple wrapper function
    - Multiple variables
    - Multiple queries
    - Characters to field names
  - Intro to `sparklyr`
    - New Spark session
    - Data transfer
    - Spark and `dplyr`
  - Text mining with `sparklyr`
    - Data Import
    - Tidying data
    - Transform the data
    - Data Exploration
  - Spark data caching
    - Map data
    - Caching data

Interested? See registration information here: [RStudio Conference 2020](https://web.cvent.com/event/36ebe042-0113-44f1-8e36-b9bc5d0733bf)

-----

![](https://i.creativecommons.org/l/by/4.0/88x31.png) This work is
licensed under a [Creative Commons Attribution 4.0 International
License](https://creativecommons.org/licenses/by/4.0/).
