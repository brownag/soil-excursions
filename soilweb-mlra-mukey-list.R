### SETUP

# select MLRA(s) of interest
target_mlra <- c("18", "22A")

# minimum overlap threshold [0, 1] (increase above 0 to exclude mapunits with acre fraction in a target MLRA below threshold)
overlap_threshold <- 0

# number of MUKEYs to write to each file (NASIS queries have a limit of 2100 values in comma-separated list)
chunk_size <- 2000

# output path (defaults to current R working directory)
output_path <- getwd()

### SCRIPT

# create gzip connection to remote URL
con <- gzcon(url("https://github.com/ncss-tech/SoilWeb-data/raw/refs/heads/main/files/mukey-mlra-overlap.csv.gz"))

# read data
dat <- readLines(con)

# convert data to table
x <- read.csv(textConnection(dat))

# subset to MLRA(s) of interest
xsub <- subset(x, mlra %in% target_mlra & membership >= overlap_threshold)

# calculate chunks if number of mukeys is more than the chunk size
chunk_ids <- rep(seq(from = 1, to = floor(nrow(xsub) / chunk_size) + 1), each = chunk_size)[seq(nrow(xsub))]

# write output to files and print paths
out <- paste("Wrote comma-separated MUKEY list for MLRA(s)", paste0(target_mlra, collapse = ", "), "to file(s):\n")
for (i in unique(chunk_ids)) {
  fn <- file.path(output_path, paste0("MLRA", paste(target_mlra, collapse = "-"), "_mukey_", i, ".txt"))
  cat(xsub$mukey[chunk_ids == i], sep = ",", file = fn)
  out <- c(out, paste0(" - ", fn, "\n"))
}

message(out)
