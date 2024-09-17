library(sf)

az695 <- st_read("D:/RGISS/Certification-archive/2024/TODO/AZ695/FGDB_AZ695_Initial_2024_0807_ra.gdb/","az695_b")
plss <- st_read("D:/Geodata/AZ/cadastral/plsstownship_a_az.gdb/", "plsstownship_a_az")
az695 <- st_transform(az695, st_crs(plss))

ov <- st_intersects(az695, plss)
st_write(plss[unlist(ov),], "D:/RGISS/Certification-archive/2024/TODO/AZ695/plss.gdb", append=F)
plot(plss[unlist(ov),] |> st_geometry())
