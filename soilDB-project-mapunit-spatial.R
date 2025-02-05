# last update: 2025/02/04

### SETUP

# set the project name to download using NASIS web report
project_name <- "MLRA 35 - San Juan River Corridor LRU subset"

# set output directory and filename for shapefile
output_directory <- file.path(getwd(), "output")
output_filename <- file.path(output_directory, gsub("\\.", "", make.names(project_name)))
###

dir.create(output_directory, showWarnings = FALSE, recursive = TRUE)

required_packages <- c("sf", "mapview", "soilDB")
sapply(required_packages, function(p) {
  if (!requireNamespace(p)) {
    install.packages(p)
  }
})

f <- soilDB::get_projectmapunit_from_NASISWebReport(projectname = project_name)
x <- soilDB::fetchSDA_spatial(
  unique(f$nationalmusym),
  by.col = "nationalmusym",
  add.fields = c("mapunit.musym", "mapunit.muname")
)
x2 <- subset(x, x$nationalmusym %in% f$nationalmusym[f$pmu_seqnum == 86])
mapview::mapview(x2)

fn <- paste0(output_filename, ".shz")
sf::write_sf(x2, dsn = fn, driver = "ESRI Shapefile", append = FALSE)
file.copy(fn, gsub("\\.shz$", ".zip", fn))
unlink(fn)

