library(soilDB)
library(aqp)

x <- fetchKSSL(mlra = c("22A", "22B"))
y <- fetchLDM(unique(x$pedlabsampnum))

y2 <- subsetHz(y, grepl("O1|Oi", hzn_desgn))
quantile(y2$fiber_rubbed, na.rm=T)
quantile(y2$fiber_unrubbed,na.rm=T)

y3 <- subsetHz(y, grepl("O2|Oe", hzn_desgn))
quantile(y3$fiber_rubbed, na.rm=T)
quantile(y3$fiber_unrubbed,na.rm=T)

y4 <- subsetHz(y, grepl("O3|Oa", hzn_desgn))
quantile(y4$fiber_rubbed, na.rm=T)
quantile(y4$fiber_unrubbed,na.rm=T)
