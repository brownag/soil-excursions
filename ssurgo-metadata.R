# process an SSA for certification
wd <- "D:/RGISS/Certification-archive/2024/symbol-update"
areasymbol <- "UT653"

wda <- file.path(wd, areasymbol)

dir.create(wda, recursive = TRUE, showWarnings = FALSE)

soilDB::downloadSSURGO(areasymbols = areasymbol, 
                       destdir = file.path(wda, "WSS"))

dir.create(file.path(wda, "Metadata"), recursive = TRUE, showWarnings = FALSE)

file.copy(file.path(wda, "WSS", areasymbol, paste0("soil_metadata_", tolower(areasymbol), ".txt")),
          file.path(wda, "Metadata", paste0( tolower(areasymbol), ".txt")))

system(paste0("mp.exe ", file.path(wda, "Metadata", paste0( tolower(areasymbol), ".txt")), 
              " -x ",
              file.path(wda, "Metadata", paste0( tolower(areasymbol), ".met"))), intern = TRUE)

file.copy(file.path(wda, "Metadata", paste0( tolower(areasymbol), ".met")),
          file.path(wda, tolower(areasymbol), paste0( tolower(areasymbol), ".met")),
          overwrite = TRUE)
