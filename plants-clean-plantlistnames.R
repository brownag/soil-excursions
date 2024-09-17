x <- data.table::fread('https://plants.usda.gov/assets/docs/CompletePLANTSList/plantlst.txt')

cleannames <- function(x) {
  gsub(
    "^(\u00d7?[A-Z][a-z\\-]+ [\u00d7a-z\\-]+)[^\\.]*( [A-Za-z\\(\\)\\. ]+)?.*( [varssp]{3}\\. [a-z\\-]+)?.*( [varssp]{3}\\. [a-z\\-]+).*$|^([\u00d7?A-Z][a-z\\-]+) [A-Z]\\..*$|(\u00d7?[A-Z][a-z\\-]+) .*|^([A-Z]?[a-z]+-?[A-Z]?[a-z]+ [a-z]+-?[a-z]+) ?.*$|.*",
    "\\1\\3\\4\\5\\6\\7",
    x
  )
}

y <- data.frame(
  code = x$Symbol,
  syn = x$`Synonym Symbol`,
  old = x$`Scientific Name with Author`,
  new = cleannames(stringi::stri_enc_toascii(x$`Scientific Name with Author`))
)

fff <- subset(y, grepl("ssp\\.", y$old) & !grepl("ssp\\.",y$new))

fff$old[1] |> cleannames()

# subset(y, y$code == "ACMIO") |>
#   View()
subset(y, y$new == "") |>
  View()

write.csv(y, "plantlistclean.csv")

