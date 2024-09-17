library(soilDB)
destdir <- "C:/workspace"
soil_db <- file.path(destdir, "ca041.gpkg")
con <- RSQLite::dbConnect(RSQLite::SQLite(), soil_db)
system.time(x <- get_SDA_interpretation(
  rulename    = "NCCPI - National Commodity Crop Productivity Index (Ver 3.0)",
  method      = "Dominant Component",
  areasymbols = "CA041",
  wide_reason = TRUE,
  dsn = soil_db, query_string=TRUE
))
DBI::dbListTables(con)

soilDB:::.SSURGO_query("SELECT * FROM cointerp LIMIT 1", con) |> View()
