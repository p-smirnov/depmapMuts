library(data.table)

depMapMapped <- fread("DepMap_cell_info - Manual Review.csv")

cell.all <- fread("~/Code/Github/pachyderm/Annotations/cell_annotation_all.csv")

cell.all[,DepMap.cellid := NA_character_]


depMapIntersect <- depMapMapped[depMapMapped$RRID %in% cell.all$Cellosaurus.Accession.id,]

myx <- match(depMapIntersect$RRID, cell.all$Cellosaurus.Accession.id)

cell.all[myx, DepMap.cellid := depMapIntersect$DepMap_ID]

depMapNoIntersect <- depMapMapped[(!depMapMapped$RRID %in% cell.all$Cellosaurus.Accession.id) & depMapMapped$RRID != "",]

cell.all.new.rows <- data.frame(cell.all)[rep(NA_real_, nrow(depMapNoIntersect)),]

rownames(cell.all.new.rows) <- NULL


source("~/Code/cellosaurus/parseCellosaurus.R")

unique.cellids.new <- returnCelloColumn("~/Code/cellosaurus/cellosaurus.txt", depMapNoIntersect$RRID, "ID")


cell.all.new.rows$unique.cellid <- unique.cellids.new

cell.all.new.rows$Cellosaurus.Accession.id <- depMapNoIntersect$RRID

cell.all.new.rows$DepMap.cellid <- depMapNoIntersect$DepMap_ID

cell.all.new.rows$unique.tissueid <- depMapNoIntersect$unique.tissueid


depMapNoRRID <- depMapMapped[depMapMapped$RRID == "",]


cell.all.new.rows.2 <- data.frame(cell.all)[rep(NA_real_, nrow(depMapNoRRID)),]

rownames(cell.all.new.rows.2) <- NULL

cell.all.new.rows.2$unique.cellid <- depMapNoRRID$stripped_cell_line_name
cell.all.new.rows.2$DepMap.cellid <- depMapNoRRID$DepMap_ID

my.dups <- which(cell.all.new.rows$unique.cellid %in% cell.all$unique.cellid) 

cell.all.new.rows.dups <- cell.all.new.rows[my.dups,]

myx2 <- match(cell.all.new.rows.dups$unique.cellid, cell.all$unique.cellid)
cell.all[myx2, Cellosaurus.Accession.id := cell.all.new.rows.dups$Cellosaurus.Accession.id]

cell.all[myx2, DepMap.cellid := cell.all.new.rows.dups$DepMap.cellid]

cell.all.new.rows <- cell.all.new.rows[-my.dups,]

cell.all.new <- rbind(cell.all, cell.all.new.rows)
cell.all.new <- rbind(cell.all.new, cell.all.new.rows.2)
cell.all.new[which(duplicated(cell.all.new$unique.cellid)), unique.cellid]

toCollapse <- which(cell.all.new$unique.cellid == cell.all.new[duplicated(cell.all.new$unique.cellid), unique.cellid])

source("~/Code/misc/collapseRows3.R")

cell.all.new <- data.frame(cell.all.new)

cell.all.new.test <- collapseRows3(cell.all.new, toCollapse)

any(duplicated(cell.all.new.test$unique.cellid))


cell.all.new.test <- cell.all.new.test[,-1] ## removing X column

write.csv(cell.all.new.test, file="~/Code/Github/pachyderm/Annotations/cell_annotation_all.csv")

# cell.all <- read.csv("~/Code/Github/pachyderm/annotations/cell_annotation_all.csv")

# matchedByDepMap <- matchToIDTable(cellData$DepMap_ID, cell.all, "DepMap.cellid")
# matchedByDepMap.tissueid <- matchToIDTable(cellData$DepMap_ID, cell.all, "DepMap.cellid", "unique.tissueid")



