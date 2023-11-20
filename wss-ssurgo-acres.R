library(soilDB)
library(terra)
library(data.table)

bd <- "C:/workspace/RGISS/"

AREASYMBOL <- c("CA707")
wd <- file.path(bd, AREASYMBOL)
if (!dir.exists(wd))
  dir.create(wd, recursive = TRUE)

downloadSSURGO(areasymbols = AREASYMBOL,
               include_template = TRUE, 
               destdir = wd,
               exdir = wd)

x <- list.files(wd,
                pattern = "soilmu_a_[a-z]{2}\\d{3}\\.shp$",
                recursive = TRUE,
                full.names = TRUE) |> 
  vect() |> project("EPSG:5070")

res <- data.table(musym = x$MUSYM,
           muacres = expanse(x) / 4046.86)[, list(sum_acres = round(sum(muacres, na.rm = TRUE))),
                                           by = "musym"]
write.table(res[order(res$musym),], file.path(wd, paste0("musymacres_", AREASYMBOL, ".txt")),
            sep = "|", col.names = FALSE, row.names = FALSE, quote = FALSE)
sf::sf_use_s2(FALSE)
((sf::st_as_sf(x) |>
  sf::st_transform("EPSG:5070") |> 
  sf::st_area()) / 4046.86) |> round() |> sum()
sum(res$sum_acres)
