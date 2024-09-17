library(soilDB)
destdir <- "~/FY24/SQLiteTest/"
soil_db <- file.path(destdir, "ca041.sqlite")
downloadSSURGO(areasymbols = "CA041", destdir = destdir)
createSSURGO(soil_db, exdir = destdir)

x <- get_SDA_interpretation(
  rulename    = "NCCPI - National Commodity Crop Productivity Index (Ver 3.0)",
  method      = "Dominant Component",
  areasymbols = "CA041",
  wide_reason = TRUE,
  dsn = soil_db
)
