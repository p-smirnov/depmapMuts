### Here we download the broad depmap processing for mutations, and the sample info from their website. This is Public20q3.

outdir <- "/pfs/out"

download.file("https://ndownloader.figshare.com/files/24613355", destfile = file.path(outdir, "CCLE_mutations.csv"))

download.file("https://ndownloader.figshare.com/files/24613394", destfile = file.path(outdir, "sample_info.csv"))


