library(soilDB)
library(terra)
b <- vect("D:/Geodata/soils/mlra/MLRA_52.shp") |> 
  # subset(MLRARSYM %in% c("15","16","17"), NSE = TRUE) 
  subset(MLRARSYM %in% c("17"), NSE = TRUE) 
i <- SDA_spatialQuery(b)
r <- mukey.wcs(b, res = 300)
s <- get_SDA_pmgroupname(mukeys = i$mukey)
p <- get_SDA_property("taxsuborder", "dominant component (category)",
                      mukeys = i$mukey)
a <- SDA_query(paste("SELECT mukey, muacres FROM mapunit WHERE mukey IN", 
               format_SQL_in_statement(i$mukey)))
s <- data.table::setDT(s)
s2 <- s[p, on = "mukey"][a, on = "mukey"]
r2 <- classify(r, cbind(i$mukey, i$mukey), others = NA)
levels(r2) <- as.data.frame(s2[,.SD[1,], .SDcols = c("pmgroupname"), by = "mukey"])
plot(catalyze(r2=="Organic Deposits"))
# par(mfrow=c(1,2), mar=c(1,1,1,1))
plot(r2, col = hcl.colors(50))
plot(project(b, r2), lwd=2, col=NA, add=TRUE)
# pl <- plet(r2$pmgroupname,
#            alpha = 0.5,
#            col = hcl.colors(5),
#            tiles = "Esri.WorldImagery")
# lines(pl, project(b, r2))
r3 <- deepcopy(r2)
levels(r3) <- unique(s2[,c("mukey","taxsuborder")])
activeCat(r3) <- "taxsuborder"

plot(r3, col = rev(hcl.colors(50, palette = "cividis")))
plot(r3=="Xeralfs", col=terrain.colors(2) |> rev())
plot(project(b, r3), lwd = 2, col = NA, add = TRUE)
