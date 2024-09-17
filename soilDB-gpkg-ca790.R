# prepare ssurgo
library(soilDB)
library(RSQLite)

downloadSSURGO(areasymbols = "CA790", destdir="D:/workspace/CA790/Geodata")

fn <- "D:/workspace/CA790/Geodata/ca790.gpkg"

createSSURGO(
  filename = fn,
  exdir = "D:/workspace/CA790/Geodata",
  include_spatial = TRUE
)
gpkg::gpkg_list_tables(fn)
gpkg::gpkg_contents(fn)


fn2 <- "D:/workspace/CA790/Geodata/ca790_2.sqlite"
conn <- DBI::dbConnect(DBI::dbDriver("SQLite"),
                       fn2, 
                       loadable.extensions = TRUE)
createSSURGO(
  exdir = "D:/workspace/CA790/Geodata",
  include_spatial = TRUE,
  conn = conn
)

gpkg::gpkg_list_tables(fn2)
gpkg::gpkg_contents(fn2)

gpkg::gpkg_update_contents(fn2)
