library(soilDB)

#' Rate taxonomic particle size family classes
#' 
#' This R function based on the particle size class portion of the Alaska "similar soils" guide.
#'
#' @param f A _SoilProfileCollection_ object.
#' @param taxpartsize character. Column name containing taxonomic particle size family Default: `"taxpartsize"`
#' @param claytotest character. Column name containing clay content (%). Default: `"clay"`
#' @param ... Additional arguments are passed to `aqp::estimatePSCS()`
#'
#' @return integer. Ranging from 1 (`"Fragmental"`) to 8 (`"Very fine"`)
#' @noRd
rate_taxpartsize <- function(f, 
                             taxpartsize = "taxpartsize", 
                             claytotest = aqp::guessHzAttrName(f, "clay", c("tot", "est", "_r")), 
                             ...) {
  
  # optional: encode PSCS to a factor using NASIS domain values (not necessary)
  # y <- soilDB::NASISChoiceList(f[[taxpartsize]], taxpartsize)
  
  y <- trimws(tolower(as.character(f[[taxpartsize]])))
  
  z <- dplyr::case_match(y,
    "fragmental" ~ 1,
    c("sandy-skeletal", "ashy-skeletal") ~ 2,
    c("sandy", "ashy", "not used") ~ 3,
    c("coarse-loamy", "coarse-silty", "medial", "loamy") ~ 4,
    c("medial-skeletal", "loamy-skeletal") ~ 5,
    c("fine-loamy", "fine-silty") ~ 6,
    c("fine", "clayey") ~ 7,
    c("very fine") ~ 8
  )
  
  ## optional: calculate PSCS independently of taxonomic history table
  # p <- aqp::estimatePSCS(f, clay.attr = claytotest, ...)
  
  ##  handling of shallow soil PSCS
  f$.claytotest <- f[[claytotest]]
  f2 <- trunc(f, f$psctopdepth, f$pscbotdepth, drop = FALSE) 
  f$.pscs_clay <- aqp::mutate_profile(f2, V1 = weighted.mean(.claytotest, hzdepb - hzdept))$V1
  
  # add 2 to loamy textures with >18% clay
  idx1 <- which(f$.pscs_clay >= 18 & y == "loamy")
  z[idx1] <- z[idx1] + 2
  
  # add 1 to clayey textures with >60% clay
  idx2 <- which(f$.pscs_clay >= 60 & y == "clayey")
  z[idx2] <- z[idx2] + 1
  
  z
}

# load NASIS pedon data
f <- fetchNASIS()

f$taxpartsize_rating <- rate_taxpartsize(f)
d <- data.frame(taxpartsize = f$taxpartsize,
                rating = f$taxpartsize_rating)
d <- d[order(d$rating),]
lbl <- aggregate(d$taxpartsize, by = list(d$rating), 
                 \(x) paste0(sort(unique(x)), collapse = ", "))
d$label <- lbl$x[d$rating]
barplot(table(d$label))
