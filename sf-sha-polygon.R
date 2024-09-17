library(sf)
library(dplyr)
# x <- st_read("D:/RGISS/RTSD_Southwest_FY24.gdb", "MUPOLYGON")
# x <- subset(x, AREASYMBOL == "CA673")
x <- st_read("D:/RGISS/Certification-archive/2024/TODO/CA673/export/ca673/ca673_a.shp")
y <- st_read("D:/RGISS/Certification-archive/2024/TODO/CA673/FGDB_CA673_VSFB_TCM.gdb", "ca673_a")

x2 <- select(as.data.frame(x)["MUSYM"], "MUSYM") |> 
  group_by(MUSYM) |> 
  count()

y2 <- select(as.data.frame(y)["MUSYM"], "MUSYM") |> 
  group_by(MUSYM) |> 
  count()
which(x2$n != y2$n)

x$sha <- sapply(x$SHAPE, digest::sha1)
y$sha <- sapply(y$Shape, digest::sha1)
y[!y$sha %in% x$sha,]


