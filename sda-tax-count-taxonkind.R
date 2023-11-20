suppressPackageStartupMessages(library(soilDB))

SDA_query("SELECT COUNT(DISTINCT cokey) FROM component
           WHERE compkind = 'taxon above family'")

SDA_query("SELECT COUNT(DISTINCT cokey) FROM component
           WHERE compkind = 'taxon above family'
           AND taxpartsize IS NOT NULL")

SDA_query("SELECT COUNT(DISTINCT cokey) FROM component
           WHERE compkind = 'taxon above family'
           AND taxtempregime IS NOT NULL")

SDA_query("SELECT COUNT(DISTINCT cokey) FROM component
           WHERE compkind = 'taxon above family'
           AND (taxpartsize IS NOT NULL OR taxtempregime IS NOT NULL)")
