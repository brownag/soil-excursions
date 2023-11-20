get_soilgrids <- function(x, filename = NULL, overwrite = TRUE,
                          target_resolution = c(250, 250),
                          depth = c("0-5cm", "5-15cm", "15-30cm", "30-60cm", "60-100cm", "100-200cm"),
                          summary_type = c("Q0.05", "Q0.5", "Q0.95", "mean"),
                          variables = c("bdod", "cec", "cfvo", "clay", "nitrogen",
                                        "phh2o", "sand", "silt", "soc", "ocd"),
                          verbose = TRUE) {

  stopifnot(requireNamespace("sf"))

  if (inherits(x, 'Spatial')) {
    x <- sf::st_as_sf(x) # sp support
  }

  if (!inherits(x, 'bbox')) {
    # sf/sfc/stars/Raster*/SpatVector/SpatRaster support
    xbbox <- sf::st_bbox(x)
  } else xbbox <- x

  sg_crs <- '+proj=igh'

  # specifying vsicurl parameters appears to not work with GDAL 3.2.1
  # sg_url <- paste0("/vsicurl?max_retry=", max_retry,
  #                  "&retry_delay=", retry_delay,
  #                  "&list_dir=no&url=https://files.isric.org/soilgrids/latest/data/")

  # WORKS
  sg_url <- "/vsicurl/https://files.isric.org/soilgrids/latest/data/"

  # calculate homolosine bbox
  xbbox <- sf::st_bbox(sf::st_transform(sf::st_as_sfc(xbbox), sg_crs))

  # numeric values are returned as integers that need to be scaled to match typical measurement units
  data.factor <- c(0.01, 0.1, 0.1, 0.1, 0.01, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1)
  names(data.factor) <- c("bdod", "cec", "cfvo", "clay", "nitrogen",
                          "phh2o", "sand", "silt", "soc" , "ocd", "ocs")

  # calculate temporary file names for each variable*depth*summary grid
  vardepth <- apply(expand.grid(variables, summary_type, depth), 1, paste0, collapse = "_")
  tfs <- tempfile(pattern = paste0(vardepth, "_"), fileext = ".tif")
  names(tfs) <- vardepth

  # helper function for gdal_utils options
  .gdal_utils_opts <- function(lst) do.call('c', lapply(names(lst), function(y) c(y, lst[[y]])))

  # iterate over variable*depth
  for (i in seq_along(tfs)) {

    # translate remote .vrt -> local .tif
    vd <- strsplit(vardepth[i], "_")[[1]]
    v <- vd[1]; d <- vd[2]; s <- vd[3]

    sf::gdal_utils(
      util = "translate",
      source = paste0(sg_url, paste0(v, '/', v, '_', s, '_', d, '.vrt')),
      destination = tfs[i],
      options = .gdal_utils_opts(
        list(
          "-of" = "GTiff",
          "-tr" = target_resolution,
          "-projwin" = as.numeric(xbbox)[c(1, 4, 3, 2)],
          "-projwin_srs" = sg_crs
        )
      ),
      quiet = !verbose
    )
  }

  stk <- terra::rast(tfs)
  names(stk) <- vardepth

  if (!is.null(filename)) {
    terra::writeRaster(stk, filename = filename, overwrite = overwrite)
  }

  if (interactive()) {
    terra::plot(stk)
  }

  # apply conversion factor
  stk2 <- terra::app(stk, function(x) x * data.factor[gsub("([a-z]+)_.*", "\\1", names(x))])

  stk2
}

library(sf)
library(terra)

# paste alternate lat/lon in here ----

d <- read.table(text = "id	lat	lon
WJUC_16_26	47.950061	32.534079",
header = TRUE)
x <- vect(d,
          geom = c("lon", "lat"),
          crs = "OGC:CRS84")

b <- buffer(x, 1e5)
b

res <- get_soilgrids(
  b,
  filename = "sg_test.tif",
  depth = "0-5cm",
  variables = c("bdod", "clay"),
  summary_type = "mean"
)

# smp <- terra::spatSample(res, 1000, xy = TRUE, method = "regular")
# smp

par(mfrow = c(2, 1))
ix <- project(x, res)
plot(crop(res$`bdod_mean_0-5cm`, buffer(ix, 5000)) > 0, col = "blue")
title("Has Data")
plot(ix, col = rgb(0, 0, 0, 0.5), add = TRUE)

plot(crop(res$`bdod_mean_0-5cm`, buffer(ix, 5000)))
title("bdod_mean_0-5cm")
plot(ix, col = rgb(0, 0, 0, 0.5), add = TRUE)
