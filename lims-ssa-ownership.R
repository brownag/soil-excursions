# SWR/NWR legend ownership check script
x <- sf::st_read("D:/ArcPro/RGISS/RGISS.gdb", "SSA_Ownership_chad")
y <- (rvest::read_html("https://nasis.sc.egov.usda.gov/NasisReportsWebSite/limsreport.aspx?report_name=WEB-Official%20Non-MLRA%20SSA") |>
   rvest::html_table(header = TRUE))[[1]]

swr_gis  <- subset(x, x$REGION == "SW")
swr_lims <- subset(y, new_RO_code == "SW")
nwr_gis  <- subset(x, x$REGION == "NW")
nwr_lims <- subset(y, new_RO_code == "NW")

# move to MLRA02_Davis
swr1 <- sort(swr_gis$areasymbol[!swr_gis$areasymbol %in% swr_lims$`Area Symbol`])
swr2 <- sort(nwr_lims$`Area Symbol`[!nwr_lims$`Area Symbol` %in% nwr_gis$areasymbol])
# swr1 == swr2
knitr::kable(subset(y, y$`Area Symbol` %in% swr1))
cat(swr1, sep = ", ")

# move to MLRA04_Bozeman
nwr1 <- sort(swr_lims$`Area Symbol`[!swr_lims$`Area Symbol` %in% swr_gis$areasymbol])
nwr2 <- sort(nwr_gis$areasymbol[!nwr_gis$areasymbol %in% nwr_lims$`Area Symbol`])
# nwr1 == nwr2
knitr::kable(subset(y, y$`Area Symbol` %in% nwr1))
cat(nwr1, sep = ", ")

subset(swr_gis, grepl("ID", swr_gis$areasymbol))
subset(swr_gis, grepl("CO", swr_gis$areasymbol))
subset(swr_gis, grepl("OR", swr_gis$areasymbol))
