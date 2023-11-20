library(soilDB)

RULES <- c("NCCPI - National Commodity Crop Productivity Index (Ver 3.0)",
           "NCCPI - NCCPI Corn Submodel (I)")

res <- soilDB::get_SDA_interpretation(rulename = RULES, method = "Dominant Component", 
                                      mukeys = c(242963, 164556))

# all nationalmusyms, excluding STATSGO
x0 <- SDA_query("SELECT COUNT(DISTINCT nationalmusym) FROM mapunit 
                INNER JOIN legend ON legend.lkey = mapunit.lkey AND legend.areasymbol != 'US'
                INNER JOIN component ON mapunit.mukey = component.mukey 
                AND majcompflag = 'Yes'")
x0

# all nationalmusyms, excluding STATSGO, have NCCPI v3.0
x <- SDA_query("SELECT COUNT(DISTINCT nationalmusym) FROM mapunit 
                INNER JOIN component ON mapunit.mukey = component.mukey AND majcompflag = 'Yes'
                INNER JOIN cointerp ON component.cokey = cointerp.cokey AND 
                           mrulename = 'NCCPI - National Commodity Crop Productivity Index (Ver 3.0)'")
x

# nationalmusyms with NCCPI Corn Submodel (for example)
y <- SDA_query("SELECT COUNT(DISTINCT nationalmusym) FROM mapunit 
                INNER JOIN component ON mapunit.mukey = component.mukey AND majcompflag = 'Yes'
                INNER JOIN cointerp ON component.cokey = cointerp.cokey AND 
                           mrulename = 'NCCPI - NCCPI Corn Submodel (I)'")
y

# 100% of nationalmusyms have NCCPI 
x$V1 / x0$V1

# and only 9% of nationalmusym have NCCPI corn submodel exported
y$V1 / x0$V1

# general function to see what states export a particular rule
get_states_using_cointerp <- function(rulename) {
  do.call('rbind', lapply(rulename, function(r){
    res <- SDA_query(sprintf("SELECT DISTINCT SUBSTRING(areasymbol, 0, 3) AS state FROM mapunit 
                  INNER JOIN legend ON legend.lkey = mapunit.lkey AND areasymbol != 'US'
                  INNER JOIN component ON mapunit.mukey = component.mukey AND majcompflag = 'Yes'
                  INNER JOIN cointerp ON component.cokey = cointerp.cokey AND mrulename = '%s'", r))
    res$mrulename <- r
    res
  }))
}

get_states_using_cointerp('NCCPI - NCCPI Corn Submodel (I)')

get_states_using_cointerp('NCCPI - NCCPI Soybeans Submodel (I)')

