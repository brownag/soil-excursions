library(terra)

# considering an interaction method
interaction_SpatRaster <- function(..., drop = FALSE, sep = ".", lex.order = FALSE) {

  arg <- list(...)
  x <- arg[[1]]
  y <- arg[[2]]
  # TODO: ... n rasters > 2

  stopifnot(inherits(x, 'SpatRaster') && is.factor(x) && nlyr(x) == 1)
  stopifnot(inherits(y, 'SpatRaster') && is.factor(y) && nlyr(x) == nlyr(y))

  ca <- cats(x)[[1]] #nlyr==1
  cb <- cats(y)[[1]]
  cab <- interaction(ca[[1]], cb[[1]], drop = drop, sep = sep, lex.order = lex.order)
  ac <- ca[[activeCat(x)]]
  ab <- cb[[activeCat(y)]]
  abc <- interaction(ab, ac, drop = drop, sep = sep, lex.order = lex.order)
  ivalues <- levels(cab)
  i <- seq(ivalues)
  new <- data.frame(ID = i, cmb = ivalues, lbl = abc)
  new2 <- do.call('rbind', strsplit(new$cmb, sep, fixed = TRUE))
  colnames(new2) <- c("x", "y")
  new <- cbind(new, new2)

  .f <- function(u, v) {
    aa <- match(paste0(as.numeric(u), sep, as.numeric(v)),
                paste0(as.numeric(new$x), sep, as.numeric(new$y)))
    res <- new$ID[aa]
    # print(res)
    res
  }

  xy <- as.numeric(c(x, y))
  res <- lapp(xy, fun = .f)
  levels(res) <- list(new)
  activeCat(res) <- "lbl"
  res
}

# fully overlapping category values
a <- rast(matrix(1:9, nrow = 3))
b <- rast(matrix(1:9, nrow = 3))
levels(a) <- data.frame(ID = 1:9, label = letters[1:9])
levels(b) <- data.frame(ID = 1:9, label = LETTERS[1:9])
interaction_SpatRaster(a, b) -> x

plot(x)
cats(x)

# no overlapping category values
a <- rast(matrix(101:109, nrow = 3))
b <- rast(matrix(201:209, nrow = 3))
levels(a) <- data.frame(ID = 101:109, label = letters[1:9])
levels(b) <- data.frame(ID = 201:209, label = LETTERS[1:9])
interaction_SpatRaster(a, b) -> x

plot(x)
cats(x)
