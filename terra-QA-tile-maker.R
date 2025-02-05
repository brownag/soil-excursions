# QA tile maker

dsn <- "D:/RGISS/Certification-archive/2025/UT647/FGDB_UT647_2024_11_9_rl.gdb"
layer <- "UT647_a_2022_07_13_editcopy"

v <- terra::vect(dsn, layer)

# benchmarks (scale vs apprx. tile area in square meters)
scale_lut <- c(
  "1:125000" = 1E8,
  "1:62500" = 2.5E7,
  "1:24000" = 6E6,
  "1:12000" = 1.5E6
)

make_tile_geom <- function(vector, tiledim) {
  g <- terra::rast(vector, res = 10)
  v0 <- terra::vect(as.character(wk::as_wkt(wk::as_rct(getTileExtents(g, tiledim)[, c(1, 3, 2, 4)]))))
  crs(v0) <- crs(vector)
  v0
}

opt_tile_dimensions <- function(tiledim, vector, target_area) {
  abs(expanse(make_tile_geom(vector, tiledim)[1,]) - target_area)
}

res <- lapply(scale_lut, function(target_area) {
  td <- optimize(
    opt_tile_dimensions,
    interval = c(0, 1000),
    vector = v,
    target_area = target_area
  )$minimum
  v2 <- make_tile_geom(v, td)
  intersect(v2, aggregate(v))
})

out <- lapply(seq(res), function(i) {
  writeVector(res[[i]], "output.gpkg", layer = names(res)[i], overwrite = (i == 1), insert = (i > 1))
})
