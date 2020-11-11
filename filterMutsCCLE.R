library(data.table)
library(RaggedExperiment)
library(GenomicRanges)
library(rtracklayer)

# source("~/Code/Github/PharmacoGx-private/R/matchToIDTable.R")

inputDir <- "/pfs/input/"
outDir <- "/pfs/out"


cellData <- read.csv(file.path(inputDir, "sample_info.csv")


allMuts <- fread(file.path(inputDir, "CCLE_mutations.csv"))

ccle.muts <- allMuts[CGA_WES_AC!="" | HC_AC != "" | RD_AC != "" | WGS_AC != ""]

fwrite(ccle.muts, file = "ccleAllMafs.maf",sep="\t", quote=FALSE)


ccle.muts <- ccle.muts[,"SangerWES_AC" := NULL]
ccle.muts <- ccle.muts[,"SangerRecalibWES_AC" := NULL]



ccleGRanges <- makeGRangesFromDataFrame(ccle.muts, start.field="Start_position", end.field="End_position", keep.extra.columns=TRUE)



ccleGRangesSplit <- split(ccleGRanges, ccleGRanges$DepMap_ID)

ccleRag <- RaggedExperiment(ccleGRangesSplit)

colData(ccleRag)$DepMap_ID <- colnames(ccleRag)
colData(ccleRag)$stripped_cell_line_name <- cellData[match(colnames(ccleRag), cellData$DepMap_ID),"stripped_cell_line_name"]


saveRDS(ccleRag, file=file.path(outDir,"ccleMutationExtended.rds"))