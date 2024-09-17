library(terra)
x <- rast("D:/2SON/2SON_CA732_10DEM.tif")
y <- terrain(x[[1]], unit = "radians", filename = "D:/2SON/2SON_CA732_10SLOPE.tif", ov=T)
# y <- rast("D:/2SON/2SON_CA732_10SLOPE.tif")
y <- tan(y)*100
writeRaster(y, "D:/2SON/2SON_CA732_10SLOPE.tif", ov=T)
