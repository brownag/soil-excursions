library(soilDB)

# get dominant component parent material group for each mukey
#  - concatenating multiple copm records within copmgrp using semicolon
q <- "SELECT DISTINCT (SELECT STRING_AGG(value, '; ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(STRING_AGG(CONVERT(NVARCHAR(max), pmgroupname), ';'), ';')) t) AS pmgroupnames,
                      (SELECT STRING_AGG(value, '; ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(STRING_AGG(CONVERT(NVARCHAR(max), pmkind), ';'), ';')) t) AS pmkinds,
                      (SELECT STRING_AGG(value, '; ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(STRING_AGG(CONVERT(NVARCHAR(max), pmorigin), ';'), ';')) t) AS pmorigins,
                      (SELECT STRING_AGG(value, '; ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(STRING_AGG(CONVERT(NVARCHAR(max), copmgrp.rvindicator), ';'), ';')) t) AS rvindicators,
                      component.mukey, component.cokey, component.comppct_r,
                      (SELECT STRING_AGG(value, '; ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(STRING_AGG(CONVERT(NVARCHAR(max), copmgrp.copmgrpkey), ';'), ';')) t) AS copmgrpkeys
    FROM legend
    INNER JOIN mapunit ON mapunit.lkey = legend.lkey
    INNER JOIN component ON component.mukey = mapunit.mukey AND
               component.cokey = (SELECT TOP 1 c1.cokey FROM component AS c1
                                  INNER JOIN mapunit AS mu1 ON c1.mukey = mu1.mukey AND
                                                               c1.mukey = mapunit.mukey
                                  ORDER BY c1.comppct_r DESC, c1.cokey )
               AND NOT component.compkind = 'Miscellaneous area'
    INNER JOIN copmgrp on copmgrp.cokey = component.cokey AND copmgrp.rvindicator = 'Yes'
    INNER JOIN copm on copm.copmgrpkey = copmgrp.copmgrpkey
    WHERE legend.areasymbol != 'US' AND legend.areasymbol LIKE '%CA%'
    GROUP BY component.cokey, component.mukey, component.cokey, component.comppct_r
"

# run the query
res <- SDA_query(q)

# check
View(res)
