library(soilDB)
library(SoilTaxonomy)

# setup:
# - set up a workspace for multiple project folders and navigate to it
# - create child directory for this project in workspace folder
# - `git clone https://github.com/ncss-tech/SoilKnowledgeBase` into workspace folder
# - use an RStudio project, or set R working directory to project folder

# this uses a _local_ cloned instance of SKB repo (pretty fast)
path <- "../SoilKnowledgeBase/inst/extdata/OSD"

# list all
series <- gsub("(.*).json|(.*log$)", "\\1", basename(list.files(path, recursive = TRUE)))
series <- series[nchar(series) > 0]

#  - base_url = NULL or missing will use GitHub
res <- get_OSD(series, base_url = path)

hz <- data.table::rbindlist(res$HORIZONS)
table(!is.na(hz$eff_class))
table(grepl("k|ca", hz$name))
table(is.na(hz$eff_class) & grepl("k|ca", hz$name))
