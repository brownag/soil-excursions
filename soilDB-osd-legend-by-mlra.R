# OSD legend for MLRAs 38+39
library(data.table)
library(soilDB)
library(openxlsx)

## read from SoilWeb snapshot (2023-10-03)
mlra_overlap <- data.table::fread("https://github.com/ncss-tech/SoilWeb-data/raw/main/files/series-mlra-overlap.csv.gz")

## get series that spatially occur mlra 38+39 (using v5.2 of MLRA database, 2022)
## with at least 2000 acres or at least 25% its extent (for inextensive series) in one of the MLRAs

# NOTE: you do not have to filter on membership or acres, it just makes the
#       set a bit more managable with fewer small extent edge cases that may 
#       only barely come across the line
mlra_overlap_sub <- subset(mlra_overlap, mlra %in% c("38", "39") & (area_ac > 2000 | membership > 0.25))

series_list <- unique(mlra_overlap_sub$series)

# get the data from the Series Classification database
#  can use the web report, or can use your local NASIS database
osd_sc <- get_soilseries_from_NASISWebReport("%")

# get semi-structured JSON "raw" data for further processing
# (this takes a moment b/c the JSON needs to be downloaded from github for each series,
#  you can create a local snapshot of SoilKnowledgeBase, and pass a custom 
#  `base_url=`argument to use local copies)
osd_raw <- get_OSD(series_list)

# get SoilProfileCollection with extended data from soilweb
osd_extended <- fetchOSD(series_list, colorState = "dry", extended = TRUE)

colnames(osd_raw)

# start to select some columns of interest for a legend/additional analysis
osd_legend1 <- osd_raw[c("SERIES", "RANGE.IN.CHARACTERISTICS", "GEOGRAPHIC.SETTING", "USE.AND.VEGETATION", "REMARKS", "ADDITIONAL.DATA")]

# remove section headers
osd_legend1[] <- lapply(osd_legend1, function(x) trimws(gsub("^[A-Z ]+:(.*)", "\\1", x)))

# add the drainage class parsed from drainage and permeability section
osd_legend1$drainage <- data.table::rbindlist(osd_raw$SITE)$drainage

# it is likely that we might want to do additional processing on the above to look for specific data elements, rather than the narrative

# add summary of elevation range to legend
osd_elevation <- subset(osd_extended$climate.annual, climate_var == "Elevation (m)", select = c("series", "minimum", "q05", "q50", "q95", "maximum"))
colnames(osd_elevation)[2:ncol(osd_elevation)] <- paste0("elevation_", colnames(osd_elevation)[2:ncol(osd_elevation)])
osd_legend2 <- merge(osd_legend1, osd_elevation, by.x="SERIES", by.y="series")

# create a table for output
osd_sc2 <-  osd_sc[c("soilseriesname", "soilseriesstatus", "benchmarksoilflag", "taxclname",
                   "taxorder", "taxsuborder", "taxgrtgroup", "taxsubgrp", "taxpartsize", 
                   "taxminalogy", "taxceactcl", "taxreaction","taxtempcl", 
                   "originyear", "establishedyear", "soiltaxclasslastupdated")]
osd_legend_out <- merge(osd_sc2, osd_legend2, by.x = "soilseriesname", by.y = "SERIES", all.x = FALSE, all.y = TRUE)

openxlsx::write.xlsx(osd_legend_out, "MLRA38+39_OSD_legend_draft1.xlsx")
