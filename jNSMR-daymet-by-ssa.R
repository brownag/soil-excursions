library(jNSMR)
library(soilDB)
library(terra)

b <- fetchSDA_spatial(c("CA760","CA732","CA792","CA663",
                        "CA802","CA668","CA740"), by.col = "areasymbol", geom="sapolygon")
x <- jNSMR::newhall_daymet_subset(b)

y <- app(x[names(x)[grep("^p", names(x))]], sum)
z <- app(x[names(x)[grep("^t", names(x))]], mean)

d <- rast("D:/Geodata/project_data/MUSum_30m_SSR2/DEM_30m_SSR2.tif")
plot(z)

z2 <- project(z, d)
z3 <- crop(z2, project(as.polygons(z, ext=TRUE), d))
d2 <- crop(d, z3)
plot(z3/d2)
