# esmap v2
library(soilDB)
library(terra)

x <- vect("C:/Users/Andrew.G.Brown/FY24/RTSD_Southwest_FY24.gdb", "SAPOLYGON")

unique(substr(x$AREASYMBOL, 0, 2))

z <- get_SDA_coecoclass("all", areasymbols = unique(x$AREASYMBOL))

z$mukey <- as.character(z$mukey)
z$OBJECTID <- as.integer(z$mukey)

openxlsx::write.xlsx(z, "C:/Users/Andrew.G.Brown/FY24/SWR_ESPOLYGON_FY24.xlsx")
# foreign::write.dbf(z, "C:/Users/Andrew.G.Brown/FY24/SWR_ESPOLYGON_FY24.dbf", max_nchar = 512)
