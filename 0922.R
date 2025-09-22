library(DBI)
library(RPostgres)

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
dbDisconnect(con)
