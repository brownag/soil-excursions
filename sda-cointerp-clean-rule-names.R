library(soilDB)
x <- SDA_query("SELECT DISTINCT mrulename FROM cointerp")[[1]]
c(x[(grepl(">", x))],
x[(grepl("<", x))],
x[(grepl("=", x))]) |> unique() |> cat(sep="\n")

y <- .cleanRuleColumnName(x[(grepl("=", x))])

length(x)
length(unique(y))

xx <- c(x[duplicated(y)], x[duplicated(y, fromLast = TRUE)])
sort(xx)

