# generate comma-separated lists of suitable size for NASIS queries
# national query parameter limit is ~2100 so longer lists must be "chunked"

fname_prefix <- "LAS_FS_pedon_siteiid"
fname_extension <- "txt"

chunk_size <- 2000

# read in a comma separated list from text file
siteiid <- readLines(paste0(fname_prefix, ".", fname_extension))
x <- strsplit(siteiid, ',')[[1]]
i <- soilDB::makeChunks(x, chunk_size)

lapply(seq(max(i)), function(ii) {
  cat(x[ii == i], sep = ",", file = paste0(fname_prefix, "_", ii, ".", fname_extension))
})