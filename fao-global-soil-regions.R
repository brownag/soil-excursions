library(terra)
library(rnaturalearth)
library(rnaturalearthdata)

world <- vect(ne_countries(scale = "medium", returnclass = "sf"))
# download from https://www.nrcs.usda.gov/wps/portal/nrcs/detail/soils/use/worldsoils/?cid=nrcs142p2_054013
r <- rast("D:/Geodata/soils/global_soil_regions_geoTIFF/so2015v2.tif")
v <- vect(data.frame(x = -3.4028, y = 50.7613),
          geom = c("x", "y"),
          crs = "EPSG:4326")
v <- project(v, r)
x <- buffer(v, 300000)
levels(r) <- read.table("D:/Geodata/soils/global_soil_regions_geoTIFF/2015_suborders_and_gridcode.txt", sep = "\t", header = TRUE)
activeCat(r) <- "SUBORDER"
r2 <- project(crop(r, x), "+proj=igh")
plot(
  r2,
  asp = F,
  ext = ext(project(x, r2)) / 2,
  col = c(rgb(1, 1, 1, 0), viridisLite::viridis(length(unique(
    values(r2)
  )) - 1))
)
world2 <- project(world, r2)
plot(world2, add = TRUE, asp = F, lwd = 2)
