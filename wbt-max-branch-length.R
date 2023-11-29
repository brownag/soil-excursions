library(whitebox)
library(terra)
library(rgeedim)

x <- sample_dem_data()
r <- vect(crs = "OGC:CRS84",
          "POLYGON((-118.4306 36.3208,
          -118.4306 36.4167,-118.1640 36.4167,
          -118.1640 36.3208,-118.4306 36.3208))")
gd_initialize()

gd_image_from_id("USGS/3DEP/10m") |>
  gd_download(
    filename = './dem.tif',
    region = r,
    crs = "EPSG:5070",
    resampling = "bilinear",
    scale = 100,
    bands = list("elevation"),
    overwrite = TRUE,
    silent = FALSE
  ) -> dem

# resm <- 10
# demt <- rast(rast(dem))
# res(demt) <- resm
# dem2 <- resample(rast(dem), demt, overwrite = TRUE,
#                  filename = sprintf("dem_%sm.tif", resm))

wbt("FillSingleCellPits", dem = dem, output = "./dem_fill.tif") |>
  wbt("BreachDepressionsLeastCost",
      output = "./dem_bdlc.tif",
      dist = 30) -> res0

res0 |>
  wbt("D8Pointer", output = "./d8_pointer.tif") |>
  wbt("FlowLengthDiff", output = "./fld.tif") -> res1

res0 |>
  wbt("MaxBranchLength", output = "./mbl.tif") -> res2

plot(rast("fld.tif"))
plet(rast("mbl.tif"))
plet(rast("mbl.tif")>1e3,tiles=c("Esri.WorldImagery"))
plet(classify(rast("mbl.tif")>5e2, cbind(1,1), others=NA),tiles=c("Esri.WorldImagery"))
plet(classify(rast("mbl.tif")<300, cbind(1,1), others=NA),tiles=c("Esri.WorldImagery"))
