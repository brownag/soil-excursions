x <- get_soilseries_from_NASIS()
x2 <- subset(x, taxminalogy == "mixed")
x3 <- SDA_query(
    sprintf(
      "SELECT pedlabsampnum FROM lab_combine_nasis_ncss WHERE LOWER(corr_name) IN %s",
      format_SQL_in_statement(tolower(trimws(gsub("'", "", x2$soilseriesname))))
    )
  )
x4 <- fetchLDM(x3$pedlabsampnum, chunk.size=1000)
