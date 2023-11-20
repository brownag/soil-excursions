soilDB::downloadSSURGO(destdir = "~/FY24/CA",
                       WHERE = subset(spData::us_states, NAME == "California"))
soilDB::createSSURGO("CAtest_20231002.sqlite", exdir = "~/FY24/CA")
