# soilDB::SDA_query("SELECT* FROM legend
#                    INNER JOIN mapunit ON mapunit.lkey = legend.lkey
#                                        AND legend.areasymbol LIKE 'NV%'
#                                        AND mapunit.muname LIKE 'Playa%'") |>
#   View()

library(soilDB)
library(rgeedim)
library(terra)

# for example, download LiDAR associated with published SSURGO mupolygons
b <- vect(fetchSDA_spatial("2z77h", by.col = "nationalmusym"))
b$id <- seq(nrow(b))
r <- convHull(b[c(106,124,108,103,130,140), ])

# 2mf0b
# b <- vect(fetchSDA_spatial("2mf0b", by.col = "nationalmusym"))
# b$id <- seq(nrow(b))

# take first delineation (for testing)
# r <- buffer(b[1, ], 1000)

# inspect
plot(r)
# plot(b[1,],add=T)

# interactive plot of location
plet(r)

## set up geedim if needed
# gd_authenticate(auth_mode="notebook")

# initialize geedim
gd_initialize()

# search the 3DEP 1m data
a <- "USGS/3DEP/1m" |>
  gd_collection_from_name() |>
  gd_search(region = r)

# inspect individual image metadata in the collection (overlapping region `r`)
gd_properties(a)

# usually, you want to do the cropping and compositing on Earth engine side, much faster
# so we call gd_composite() before download. This calculates a single image for download.
x <- a |>
  gd_composite(resampling = "bilinear") |>
  gd_download(region = r,
              crs = "EPSG:5070",
              scale = 100,
              filename = "image.tif",
              bands = list("elevation"),
              overwrite = TRUE,
              silent = FALSE) |>
  rast()

# # sometimes you may want the constituent tiles, or portions of them.
# # leave off the gd_composite() call, and set composite=FALSE in gd_download,
# # filename is a directory name where multiple layers will be saved
# y <- a |>
#   gd_download(# region = r, # optional: include only overlapping portion of the tile of interest
#               crs = "EPSG:5070",
#               resampling = "bilinear",
#               scale = 1,
#               composite = FALSE,
#               filename = "images",
#               bands = list("elevation"),
#               overwrite = TRUE,
#               silent = FALSE)
#
# # this small playa requires 2 portions of tiles to be downloaded
# plot(rast(y))
#
# # if using `region = r`, result is two tiles ~25MB each (raw) with same extent (matching `r`)
# # with unbounded region, result is two complete (10000x10000) tiles ~401MB each (raw)

# calculate % slope, mask to input boundary
x2 <- tan(terra::terrain(x$elevation, unit = "radians")) * 100
x3 <- mask(x2, project(r, x2), filename = "playa_slope.tif", overwrite = TRUE)

# inspect
plot(x3, range = c(0, 100))
plot(project(r, x), add = TRUE)

