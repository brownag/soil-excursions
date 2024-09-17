# esmap v2
library(soilDB)
library(terra)

x <- SDA_query("SELECT DISTINCT areasymbol FROM legend")

# x <- vect("C:/Users/Andrew.G.Brown/FY24/RTSD_Southwest_FY24.gdb", "SAPOLYGON")
#
# unique(substr(x$AREASYMBOL, 0, 2))
areasyms <- unique(x$areasymbol)
chunk <- makeChunks(areasyms, size = 500)
z <- data.table::rbindlist(lapply(1:max(chunk), function(i)
             get_SDA_coecoclass(method = "all", areasymbols = areasyms[chunk == i],
                                threshold = -1e5)), fill = TRUE)

# fill=TRUE introduces NA
fillna <- names(z)[grepl("site\\d+[name]*$", names(z))]
for (f in fillna) {
  z[[f]] <- ifelse(is.na(z[[f]]), "Not assigned", z[[f]])
}

View(z)

z$mukey <- as.character(z$mukey)
dir.create("D:/SWR2023/ESMap/US/",showWarnings = FALSE)
openxlsx::write.xlsx(z, "D:/SWR2023/ESMap/US/US_ESPOLYGON_FY24.xlsx")

# z <- as.data.frame(data.table::fread("D:/SWR2023/ESMap/US/US_ESPOLYGON_FY24.csv"))
v0 <- do.call('rbind', lapply(list.dirs("D:/SWR2023/SSURGO2023")[2:20],
                              function(i) terra::merge(terra::vect(i, "MUPOLYGON"),
                                                       z, by.x = "MUKEY", by.y = "mukey")))
# v0
dir.create("D:/SWR2023/ESMap/NWR/",
           recursive = TRUE,
           showWarnings = FALSE)
terra::writeVector(v0, "D:/SWR2023/ESMap/NWR/NWR+SWR_ESPOLYGON_FY24.gdb",
                   layer = "ESPOLYGON", overwrite = TRUE)

v0 <- vect("D:/SWR2023/ESMap/SWR/SWR_ESPOLYGON_FY24.gdb", "ESPOLYGON")
vold <- vect("D:/SWR2023/ESMap/SWR/SWR_ESPOLYGON_FY23.gdb", "ESPOLYGON")
vold0 <- as.data.frame(vold)
v1 <- as.data.frame(v0)
v1$Shape_Area <- NULL
v1$Shape_Length <- NULL
vold0$Shape_Area <- NULL
vold0$Shape_Length <- NULL
v1 <- unique(v1)
vold0 <- unique(vold0)

v2 <- merge(data.table::data.table(v1), vold0,
            all.x = TRUE, sort = FALSE,
            suffixes = c(".new", ".old"),
            by = "MUKEY")

# general comparison of old versus new

# TODO: do better

.check_site <- function(x) {
  sapply(1:15, function(i) {
    !is.na(x[[paste0("site", i, ".new")]]) &
      !is.na(x[[paste0("site", i, ".old")]]) &
      x[[paste0("site", i, ".new")]] != x[[paste0("site", i, ".old")]] &
      x[[paste0("site", i, "name.new")]] != x[[paste0("site", i, "name.old")]]
  })
}

test <- .check_site(data.frame(v2))

v3 <- subset(data.frame(v2), apply(test, 1, any, na.rm = TRUE))
updated_areas <- v3[sort(colnames(v3))]
updated_sp <- subset(v0, v0$MUKEY %in% updated_areas$MUKEY)
plot(updated_sp, col = "RED")
plot(project(vect(spData::us_states), updated_sp), add = TRUE)

# visualize new assignments (old=="Not assigned" -> new=something)
.check_new_assignment <- function(x) {
  .f <- function(i) {
    !is.na(x[[paste0("site", i, ".new")]]) &
      !is.na(x[[paste0("site", i, ".old")]]) &
      x[[paste0("site", i, ".old")]] != x[[paste0("site", i, ".new")]] &
      x[[paste0("site", i, ".new")]] != "Not assigned" &
      x[[paste0("site", i, ".old")]] != "Not assigned"
  }
  sapply(1:15, .f)
}

test2 <- .check_new_assignment(data.frame(v2))
v4 <- subset(data.frame(v2), apply(test2, 1, any, na.rm = TRUE))
new_areas <- v4[sort(colnames(v4))]
new_sp <- subset(v0, v0$MUKEY %in% new_areas$MUKEY)

updated_areas <- v4[sort(colnames(v4))]
plot(new_sp, col = "RED")
plot(project(vect(spData::us_states), new_sp), add = TRUE)

openxlsx::write.xlsx(updated_areas, "D:/SWR2023/ESMap/SWR/SWR_ESPOLYGON_FY24_update-from-FY23.xlsx")

# tabulate compositional labels (top n classes, summing to >=70% comppct_r, alpha sorted)
.check_top_3 <- function(x) {
  y <- c(x$site1.new, x$site2.new, x$site3.new)
  y <- y[!is.na(y) & y != "Not assigned"]
  yy <- c(x$site1.old, x$site2.old, x$site3.old)
  yy <- yy[!is.na(yy) & yy != "Not assigned"]
  z <- c(x$site1pct_r.new, x$site2pct_r.new, x$site3pct_r.new)
  zz <- c(x$site1pct_r.old, x$site2pct_r.old, x$site3pct_r.old)
  data.table::data.table(areasymbol = x$AREASYMBOL.new,
                         musym = x$MUSYM.new,
                         mukey = x$MUKEY.new,
                         nationalmusym = x$nationalmusym.new,
                         top3.new = paste0(sort(y), collapse = "/"),
                         top3.old = paste0(sort(yy), collapse = "/"),
                         top3pct.new =  sum(z, na.rm = TRUE),
                         top3pct.old =  sum(zz, na.rm = TRUE))
}

top3 <- v2[, .check_top_3(.SD), by = list(seq(nrow(v2)))]
top3

top3sub <- subset(top3, top3.new != top3.old)
top3sub$seq <- NULL
openxlsx::write.xlsx(top3sub, "D:/SWR2023/ESMap/SWR/SWR_ESPOLYGON_FY24_update-top3-from-FY23.xlsx")

## NB: check multiple RVs
.total_comppct <- function(x) {
  y <- rowSums(data.frame(x)[colnames(x)[grep("pct_r.new", colnames(x))]], na.rm=TRUE)
  data.table::data.table(areasymbol = x$AREASYMBOL.new,
                         musym = x$MUSYM.new,
                         mukey = x$MUKEY.new,
                         nationalmusym = x$nationalmusym.new,
                         totalsitepct_r.new = y)
}

over100 <- v2[, .total_comppct(.SD), by = list(seq(nrow(v2)))]
over100sub <- subset(over100, totalsitepct_r.new > 100)
over100sub
