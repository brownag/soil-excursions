library(aqp)
data("jacobs2000")

jitterDepths <- function(p, ...) {
  hzd <- horizonDepths(p)
  .THK <- jitter(apply(p[, , .TOP, .BOTTOM], 1, diff), ...)
  lp <- list(p@horizons[[idname(p)]])
  p@horizons[horizonDepths(p)] <-
    list(do.call('c', as.list(
      aggregate(.THK, by = lp, function(x)
        cumsum(c(0, x[1:(length(x) - 1)])))$x
    )),
    do.call('c', as.list(
      aggregate(.THK, by = lp, function(x)
        cumsum(x))$x
    )))
  p
}

jitterDepths(jacobs2000, 5) |> plot()
dice(jacobs2000, 18:22~.) |> plot()
View(dice)

minDepthOf(jacobs2000, pattern = "E")
