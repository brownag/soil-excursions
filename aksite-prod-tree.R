# read aksite production and tree info
dsn <- "D:/AccessDBs/AKSite/Roots_seki_1_25_13.accdb"

# basic query
q <- "SELECT * FROM (tdataPROD INNER JOIN vegLUT ON tdataPROD.SYMBOLpr = vegLUT.ID)
      INNER JOIN old_veg_codes ON vegLUT.newid = old_veg_codes.old_veg_code"

# setup connection to our pedon database
channel <- DBI::dbConnect(odbc::odbc(), 
                          .connection_string = paste0(
                            "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=",
                          dsn))

# exec query
d <- DBI::dbGetQuery(channel, q)

# close connection
DBI::dbDisconnect(channel)

d
