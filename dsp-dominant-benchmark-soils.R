library(soilDB)
library(sf)
library(data.table)
library(dplyr, warn.conflicts = FALSE)

f <- st_read("/vsizip/C:/Users/Andrew.G.Brown/OneDrive - USDA/SharedGeodata/ESPOLYGON/SWR_ESPOLYGON_2023_v2.gdb.zip")
n <- fread("https://github.com/ncss-tech/SoilWeb-data/raw/main/files/nmsym-mlra-overlap.csv.gz")
f2 <- merge(f, 
            n[, .SD[which.max(membership)], by = "nationalmusym"],
            all.x = TRUE, by = "nationalmusym")

.f <-  function(x) {
  message(x)
  xx <- subset(f2, f2$mlra %in% x)
  p <- get_SDA_property(
    c("taxsubgrp", "taxpartsize", "taxtempregime"),
    "dominant component (category)",
    mukeys = unique(xx$MUKEY)
  )
  if (length(p) > 0) {
    res <- merge(xx, p, 
                 by.x = c("MUKEY", "muname"),
                 by.y = c("mukey", "muname"))
    a <- get_SDA_interpretation(
      c("NCCPI - Irrigated National Commodity Crop Productivity Index",
        "NCCPI - National Commodity Crop Productivity Index (Ver 3.0)",
        "FOR - Potential Fire Damage Hazard",
        "FOR - Potential Seedling Mortality"),
      method = "dominant condition",
      mukeys = unique(xx$MUKEY)
    )
    res <- merge(res, a, 
                 by.x = c("MUKEY", "muname", "areasymbol", "musym"), 
                 by.y = c("mukey", "muname", "areasymbol", "musym"))
    b <- SDA_query(paste0("SELECT mukey, farmlndcl FROM mapunit WHERE mukey IN ",
                   soilDB::format_SQL_in_statement(xx$MUKEY)))
    res <- merge(res, b, by.x = c("MUKEY"), by.y = c("mukey"))
    res
  }
  else NULL
}

m <- lapply(sort(unique(f2$mlra)), .f)
m2 <- data.table::rbindlist(m)
m <- NULL
m2$geometry <- NULL
# m2$totalacres <- round(sum(m2$Shape_Area) / 4046.86)

dir.create("SWR/DSPsoils/by_mlra",
           recursive = TRUE,
           showWarnings = FALSE)

m4 <- m2 |> 
  group_by(mlra) |> 
  mutate(mlraacres = round(sum(Shape_Area) / 4046.86)) |> 
  ungroup() |> 
  group_by(MUKEY) |> 
  mutate(muacres = round(sum(Shape_Area) / 4046.86)) 

m5 <- m4
m5$Shape_Area <- NULL
m5$Shape_Length <- NULL
m5 <- unique(m5)

m6 <- split(m5, m5$mlra)
m6 <- lapply(m6, \(xx) {
  idx <- sapply(xx, \(yy) !all(is.na(yy)))
  subset(xx, select = idx)
})
lapply(names(m6),
       \(ff) {
         write.csv(
           m6[[ff]],
           file = file.path("SWR", "DSPsoils", "by_mlra", paste0(ff, ".csv")),
           na = "",
           row.names = FALSE
         )
       }) -> foo

m4 |>
  group_by(mlra) |> 
  filter(mlra == "15") |> 
  group_by(
    mlra,
    site1name,
    site1compname,
    taxsubgrp,
    taxpartsize,
    taxtempregime,
    farmlndcl,
    class_NCCPIIrrigatedNationalCommodityCropProductivityIndex,
    class_NCCPINationalCommodityCropProductivityIndexVer30,
    class_FORPotentialFireDamageHazard,
    class_FORPotentialSeedlingMortality
  ) |>
  summarize(
    muacres = round(sum(Shape_Area) / 4046.86),
    compacres = round(sum(Shape_Area) / 4046.86 * (site1pct_r[1] / 100)),
    mlraacres = round(mlraacres[1])
    # ,totalacres = round(totalacres[1])
  ) |>
  mutate(prop_acres = round(compacres / mlraacres, 3)) |>
  arrange(mlra, desc(compacres)) -> m3
View(subset(m3, grepl("Millerton", site1compname)))
