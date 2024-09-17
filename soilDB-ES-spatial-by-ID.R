library(soilDB)
library(terra)

x <- as.polygons(ext(c(-80.5566, -80.4819, 39.7082, 39.7346)),
                 crs = "OGC:CRS84")

s <- SDA_spatialQuery(x, what = "mupolygon", geomIntersection = TRUE)
e <- get_SDA_coecoclass("all", mukeys = s$mukey)

y <- merge(s, e, by = "mukey", all.y = TRUE)
plot(y, "site1")

fetchSDA_spatial("R018XI163CA", 
                 by.col = "ecoclassid", add.fields = "muname")-> res
dir.create("D:/ESMap")
res <- vect(res)
writeVector(res, "D:/ESMap/R018XI163CA.gpkg",ov = T)

sap <- SDA_spatialQuery(convHull(res),
                        what = 'areasymbol', 
                        db = 'SAPOLYGON')$areasymbol |> 
  fetchSDA_spatial(geom.src = 'sapolygon') |> 
  vect()
plot(sap)
plot(res, add = TRUE)
