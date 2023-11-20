library(aqp)

i <- 1:10000

x <- aqp::combine(lapply(i, random_profile, SPC = TRUE))

system.time(max(x))

system.time(max(tapply(
  x$bottom, x$id, FUN = max, na.rm = TRUE
)))

spctapply <- function(spc, cx, FUN, ...) {
  tapply(spc[[cx]], horizons(spc)[[idname(spc)]], FUN, ...)
}
spctapply(x, "p1", max)
