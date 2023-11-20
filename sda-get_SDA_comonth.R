get_SDA_comonth <- function(areasymbols = NULL, mukeys = NULL, WHERE = NULL,
                            include_minors = FALSE, miscellaneous_areas = FALSE) {
  
  if (is.null(mukeys) && is.null(areasymbols) && is.null(WHERE)) {
    stop("Please specify one of the following arguments: mukeys, areasymbols, WHERE", call. = FALSE)
  }
  
  if (!is.null(mukeys)) {
    WHERE <- paste("mapunit.mukey IN", format_SQL_in_statement(as.integer(mukeys)))
  } else if (!is.null(areasymbols)) {
    WHERE <- paste("legend.areasymbol IN", format_SQL_in_statement(areasymbols))
  } 
  
  q <- paste0(
    "SELECT mapunit.mukey, component.cokey, mapunit.muname, 
            component.compname, component.comppct_r, component.taxsubgrp, component.taxclname,
                     COUNT(DISTINCT month) wet_months,
                     MIN(soimoistdept_l) min_soimoistdept_l,
                     MIN(soimoistdept_r) min_soimoistdept_r,
                     MIN(soimoistdept_h) min_soimoistdept_h
                    FROM legend
                     INNER JOIN mapunit ON mapunit.lkey = legend.lkey
                     INNER JOIN component ON component.mukey = mapunit.mukey ", 
                      ifelse(include_minors, "", " AND majcompflag = 'yes' "), " ",
                      ifelse(miscellaneous_areas, "", " AND compkind != 'miscellaneous area' "), "
                     INNER JOIN comonth ON comonth.cokey = component.cokey
                     INNER JOIN cosoilmoist ON comonth.comonthkey = cosoilmoist.comonthkey
                    WHERE ", WHERE, " AND soimoiststat = 'Wet' AND areasymbol != 'US'
                    GROUP BY mapunit.mukey, component.cokey, muname, compname, comppct_r"
  )
  suppressMessages(soilDB:::.SDA_query_FOR_JSON_AUTO(q))
}

x <- get_SDA_comonth(WHERE = "1=1")
xx <- x

xx[[3]] <- lapply(1:nrow(x), function(i) {
  y <- x[[3]][[i]]
  y$mukey <- x[i,]$mukey
  y
})

x <- merge(
  x[1:2],
  data.table::rbindlist(xx[[3]], fill = TRUE),
  by = "mukey",
  all.x = TRUE,
  sort = FALSE
)

View(x)
