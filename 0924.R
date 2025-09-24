library(tidyverse)
library(DBI)
library(RPostgres)
library(glue)
#require(knitr)
library(dbplyr)
library(sqlpetr)
# library(bookdown)
library(here)
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

sqlpetr::sp_docker_start("adventureworks")
#Sys.sleep(sleep_default)

dbExecute(con, "set search_path to sales, humanresources;") 

### 7.2.1
salesorderheader_tibble <- DBI::dbReadTable(con, "salesorderheader")
str(salesorderheader_tibble)

salesorderheader_tibble <- salesorderheader_tibble[,1:13]

### 7.2.2
salesorderheader_table <- dplyr::tbl(con, "salesorderheader")
class(salesorderheader_table)

### 7.2.3
salesorderheader_table %>% dplyr::collect(n = 3) %>% dim()
salesorderheader_table %>% dplyr::collect(n = 500) %>% dim()


### 7.2.4
one_percent_sample <- DBI::dbGetQuery(
  con,
  "SELECT orderdate, subtotal, taxamt, freight, totaldue
  FROM salesorderheader TABLESAMPLE BERNOULLI(3) LIMIT 20;
  "
)

print(one_percent_sample)

# DBI::dbListFields(con, "salesorderheader")

salesorderheader_df <- DBI::dbReadTable(con, "salesorderheader")

(max_id <- max(salesorderheader_df$salesorderid))
(min_id <- min(salesorderheader_df$salesorderid))

set.seed(123)
sample_rows <- sample(min_id:max_id, 10)
salesorderheader_table <- dplyr::tbl(con, "salesorderheader")

salesorderheader_sample <- salesorderheader_table %>% 
  dplyr::filter(salesorderid %in% sample_rows) %>% 
  dplyr::collect()

str(salesorderheader_sample)

### 7.2.5
salesorderheader_table %>% dplyr::select(orderdate, subtotal, taxamt, freight, totaldue) %>% 
  head() 

DBI::dbGetQuery(
  con,
  'SELECT "orderdate", "subtotal", "taxamt", "freight", "totaldue"
    FROM "salesorderheader"
    LIMIT 6') 

tbl(con, "salesorderheader") %>%
  dplyr::rename(order_date = orderdate, sub_total_amount = subtotal,
                tax_amount = taxamt, freight_amount = freight, total_due_amount = totaldue) %>% 
  dplyr::select(order_date, sub_total_amount, tax_amount, freight_amount, total_due_amount ) %>%
  show_query()

### 7.3
salesorderheader_table %>%
  dplyr::tally() %>%
  dplyr::show_query()

salesorderheader_table %>% dim()

DBI::dbGetQuery(
  con,
  'SELECT COUNT(*) AS "n"
     FROM "salesorderheader"   '
)

### 7.4
