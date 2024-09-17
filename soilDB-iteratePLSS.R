iterate_PLSS <- function(x) {
  # prototype function to move PLSS functionality to soilDB
  stopifnot(requireNamespace("sharpshootR"))
  
  d <- data.frame(plssid = sharpshootR::formatPLSS(x), 
                  id = x$id)
  res <- PLSS2LL(d)
  res$id <- d$id
  res <- res[!is.na(res$lat), ]
  
  ldx <- !x$id %in% res$id
  x$qq <- NA_character_
  x$q <- NA_character_
  d2 <- data.frame(plssid = sharpshootR::formatPLSS(x[ldx,]),
                   id = x$id[ldx])
  res2 <- PLSS2LL(d2)
  res2$id <- d2$id
  res2 <- res2[!is.na(res2$lat),]
  res <- rbind(res, res2)
  
  ldx2 <- !x$id %in% c(res$id, res2$id)
  x$s <- NA_integer_
  d3 <- data.frame(plssid = sharpshootR::formatPLSS(x[ldx2,]),
                   id = x$id[ldx2])
  res3 <- PLSS2LL(d3)
  res3$id <- d3$id
  res3 <- res3[!is.na(res3$lat),]
  
  res <- rbind(res, res3)
  rownames(res) <- NULL
  res[match(res$id, d$id),]
}

d <- data.frame(
  id = res$tud_name[1:nrow(r3)],
  qq = "", #r2$qq, #c('SW', 'SW', 'SE'),
  q =  "", #r2$q, #c('NE', 'NW', 'SE'),
  s = r3$section,
  t = r3$township,
  r = r3$range,
  type = 'SN',
  m = 'CA21',
  stringsAsFactors = FALSE
)
res <- iterate_PLSS(d)
