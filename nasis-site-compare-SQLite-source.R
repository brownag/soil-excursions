library(aqp)
library(daff)
library(soilDB)

p <- c(
  "area", "legend", "mapunit", "datamapunit", "component",
  "metadata", "lookup", "nasis",
  "transect", "site", "pedon", "vegetation"
)
atz <- unique(c(
  get_NASIS_table_name_by_purpose(p, SS = FALSE),
  get_NASIS_table_name_by_purpose(p, SS = TRUE)
))

x <- fetchNASIS(fill = T, SS = F)
d <- createStaticNASIS(tables = atz, SS = F, output_path = "test.sqlite")
y <- fetchNASIS(dsn = "test.sqlite", fill = T, SS = F)  

diff_data(site(x), site(y)) |> 
  render_diff()
