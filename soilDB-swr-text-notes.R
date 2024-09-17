# make text notes
x <- openxlsx::read.xlsx("S:/NRCS/430 SOI Soil Survey/430-05 Soil Survey Area Case Files/Projects/FY2022/S26I-2SON-2024-CA732-01-C4/S26I-2SON-2024-CA732-01-C4_TN29_correlation_worksheet.xlsx")

dmu.misc.creation <- data.frame(dmuiid = x$new.dmuid, 
                                textkind = "miscellaneous notes",
                                textcat = "creation",
                                text = glue::glue("This data mapunit was created for the Soil2026 project S26I-2SON-2024-CA732-01-C4 'MLRA 22A, 29, 30 - Golden Trout and South Sierra Wilderness Areas - Initial'. It was copied from the data mapunit ID {x$old.dmuid} which was the representative data mapunit for the {x$old.muname} mapunit (musym: {x$old.musym}; nationalmusym: {x$old.natl.sym}; muiid {x$old.muiid})  from the the adjacent {x$area.symbol} soil survey area. This datamapunit was updated to meet the minimum data standards set forth by the Data Integrity system. Component data were updated by running the full suite of required NASIS calculations, and minor components were populated based on a major component of the same name and typical unit description, resulting in a new MLRA mapunit for use in the NOTCOM portion of the CA732 soil survey area in additon to the original extent in {x$area.symbol} ."))
View(dmu.misc.creation)

dmu.cert.hist.qc <- data.frame(dmuiid = x$new.dmuid,
                               certkind = "quality control",
                               certstatus = "certified, all components",
                               certtext = "The mapunit, datamapunit, and components have received quality control and meet the minimum data requirements of the Data Integrity system and all data elements have passed NASIS validation.")
View(dmu.cert.hist.qc)

mu.hist.final.corr <- data.frame(muiid = x$new.muiid, 
                                 corrkind = "notes to accompany",
                                 correvent = "final correlation",
                                 corrtext = glue::glue("{x$old.muname} ({x$old.musym}; {x$old.natl.sym}) CHANGED TO {x$new.muname} ({x$new.musym}; {x$new.natl.sym})"))
View(mu.hist.final.corr)

dmudesc.lut <- dbQueryNASIS(NASIS(), 'SELECT dmuiid, dmudesc FROM datamapunit')
x$old.dmudesc <- dmudesc.lut$dmudesc[match(x$old.dmuid, dmudesc.lut$dmuiid)]
mu.hist.join.amendment <- data.frame(muiid = x$new.muiid, 
                                 corrkind = "join statement",
                                 correvent = "correlation amendment",
                                 histname = x$old.muname,
                                 corrtext = glue::glue("This mapunit ({x$old.muname}; {x$old.musym}; {x$old.natl.sym}) originated in the {x$area.symbol} soil survey area. The original representative data mapunit was {x$old.dmuid} ({x$old.dmudesc}). In Soils2026 project S26I-2SON-2024-CA732-01-C4 'MLRA 22A, 29, 30 - Golden Trout and South Sierra Wilderness Areas - Initial' the mapunit was extended into the CA732 soil survey area along the boundary with {x$area.symbol}. { ifelse(x$old.muname != x$new.muname, paste0('After updates to modern standards, the new mapunit name is \\'', x$new.muname, '\\'.'), '') } { ifelse(x$old.musym != x$new.musym, paste0('To avoid conflict with existing CA732 mapunits the mapunit symbol assigned was \\'', x$new.musym, '\\' on the CA732 legend.'), '') }"))
View(mu.hist.join.amendment)

mu.misc.creation <- data.frame(muiid = x$new.dmuid, 
                               textkind = "miscellaneous notes",
                               textcat = "creation",
                               text = glue::glue("This mapunit was created for the Soil2026 project S26I-2SON-2024-CA732-01-C4 'MLRA 22A, 29, 30 - Golden Trout and South Sierra Wilderness Areas - Initial'. It was copied from mapunit ID {x$old.muiid} ({x$old.muname}; musym: {x$old.musym}; nationalmusym: {x$old.natl.sym}) from the the adjacent {x$area.symbol} soil survey area. A new data mapunit was created (dmuiid: {x$new.dmuid}) and made representative. The new datamapunit was updated to meet the minimum data standards set forth by the Data Integrity system. Component data were updated by running the full suite of required NASIS calculations, and minor components were populated based on a major component of the same name and typical unit description, resulting in a new MLRA mapunit for use in the NOTCOM portion of the CA732 soil survey area in additon to the original extent in {x$area.symbol}."))
View(mu.misc.creation)

