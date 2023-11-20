library(SoilTaxonomy)
library(jsonlite)
library(openxlsx)

data("ST_higher_taxa_codes_13th")
st_db13_crit <- jsonlite::fromJSON("https://raw.githubusercontent.com/ncss-tech/SoilKnowledgeBase/main/inst/extdata/KST/2022_KST_criteria_EN.json")

# taxa that start with "Dur"
x <- subset(ST_higher_taxa_codes_13th, grepl('^[Dd]ur', taxon))

y <- split(x, taxon_to_level(x$taxon))
y

z <- lapply(y, function(i) {
  subset(do.call('rbind', st_db13_crit[i$code]), logic != "LAST")
})

openxlsx::write.xlsx(z, "dur-example.xlsx")
