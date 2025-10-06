# export MYDIR=$(pwd)
# 
# docker run -e POSTGRES_PASSWORD="postgres" --detach  --name adventureworks --publish 5432:5432 --mount type=bind,source=$MYDIR,target=/petdir mypsql
# 
# docker exec adventureworks psql -U postgres -c "CREATE DATABASE Adventureworks;"
# 
# docker exec adventureworks psql -U postgres -d Adventureworks -f install.sql
# 
# docker rm --force adventureworks

library(tidyverse)
library(DBI)
library(RPostgres)
library(connections)
library(glue)
require(knitr)
library(dbplyr)
library(sqlpetr)
#library(bookdown)
library(lubridate)
library(gt)

# con <- connection_open(  # use in an interactive session
con <- dbConnect(          # use in other settings
  RPostgres::Postgres(),
  # without the previous and next lines, some functions fail with bigint data 
  #   so change int64 to integer
  bigint = "integer",  
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = "postgres",
  dbname = "Adventureworks" # Capital A here
)

dbExecute(con, "set search_path to sales;") # so that `dbListFields()` works

dbListTables(con)

dbListFields(con, "vsalespersonsalesbyfiscalyearsdata")

### 11.3.1
v_salesperson_sales_by_fiscal_years_data <- 
  tbl(con, in_schema("sales","vsalespersonsalesbyfiscalyearsdata")) %>% 
  collect()

str(v_salesperson_sales_by_fiscal_years_data)

tbl(con, in_schema("sales","vsalespersonsalesbyfiscalyearsdata")) %>% 
  count(salesterritory, fiscalyear) %>% 
  collect() %>% # ---- pull data here ---- # 
  pivot_wider(names_from = fiscalyear, values_from = n, names_prefix = "FY_")

### 11.3.2
view_definition <- dbGetQuery(con, "select 
                   pg_get_viewdef('sales.vsalespersonsalesbyfiscalyearsdata', 
                   true)")
cat(unlist(view_definition$pg_get_viewdef))

soh <- dbGetQuery(con, "SELECT soh.orderdate 
                        FROM salesorderheader soh")

# dbDisconnect(con)

