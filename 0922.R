library(tidyverse)
library(DBI)
library(RPostgres)
library(glue)
require(knitr)
library(dbplyr)
# library(sqlpetr)
# library(bookdown)
# library(here)
# library(connections)

con <- dbConnect(          # use in other settings
  RPostgres::Postgres(),
  # without the previous and next lines, some functions fail with bigint data 
  #   so change int64 to integer
  bigint = "integer",  
  host = "localhost",
  port = 5432,  # this version still using 5432!!!
  user = "postgres",
  password = "postgres",
  dbname = "Adventureworks"
)
print(con)
dbExecute(con, "set search_path to sales;")
dbListTables(con)

dbListFields(con, "salesorderheader")

tbl(con, in_schema("sales", "salesorderheader")) %>%
  head()
# dbDisconnect(con)
