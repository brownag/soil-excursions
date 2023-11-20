library(rgeedim)
library(terra)
library(soilDB)

lb <- vect("D:/8TUS/landsat_buffer.shp")
x <- buffer(project(as.polygons(lb, ext = TRUE), "OGC:CRS84"), 1000)

gd_initialize()

gd_collection_from_name("LANDSAT/LC09/C02/T1_L2") |>
  gd_search(region = x,
            start_date = "2023-06-01",
            end_date = "2023-08-31") |>
  gd_composite(
    method = "medoid",
    date = '2023-07-14'
  ) |>
  gd_download(
    filename = "image3.tif",
    region = x,
    scale = 30,
    crs = 'EPSG:5070',
    max_tile_dim = 256,
    bands = list("SR_B1", "SR_B2", "SR_B3", "SR_B4",
                 "SR_B5", "SR_B6", "SR_B7", "ST_B10"),
    dtype = 'uint16',
    overwrite = TRUE,
    silent = FALSE
  )

y <- rast("image3.tif")
y2 <- writeRaster(y[[c("SR_B1", "SR_B2", "SR_B3",
           "SR_B4", "SR_B5", "SR_B6",
           "SR_B7", "ST_B10")]], "subset.tif", overwrite=TRUE)

plot(y)
names(y)
plot(y)
plot(y$SR_B1)
y2 <- project(lb, y)
plot(y2, add = T)

ndvi <- mask(scale((y$SR_B5 - y$SR_B4) / (y$SR_B5 + y$SR_B4)), y2)
ndvi_c <- k_means(ndvi, 5, algorithm="Lloyd")
plot(ndvi_c)


plot(ndvi, col = hcl.colors(50, "cividis"))
plot(y2, add = T)

title('scaled NDVI')

plot(vect(fetchSDA_spatial(
      unique(SDA_spatialQuery(x, "areasymbol", db = "SAPOLYGON")[[1]]),
      by.col = "areasymbol",
      geom.src = "sapolygon"
    )) |> project(y2), add = TRUE)
