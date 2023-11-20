library(soilDB)
library(sf)
library(dplyr)

x <- st_read("D:/CA732/Geodata/CA732_Derived.sqlite", layer = "ca732_notcom_b")
y <- st_read("D:/CA732/Geodata/FGDB_CA732_2022.gdb", layer = "ca732_a")
z <- st_crop(y, x)
z |>
  group_by(MUSYM) |>
  summarise(ACRES = sum(units::set_units(st_area(SHAPE), "acre"))) |>
  arrange(desc(ACRES))

