library(clusterProfiler)
library(DOSE)
setwd('~/2018-ggg201b/lab7-rnaseq-enrichment/functional-analysis')


# get the database
gene.data <- read.csv(file='../yeast-edgeR.csv', row.names=1)

#subset data to identify sig. DE genomes
de.genes <- subset(gene.data, FDR < 0.05)
up.genes <-subset(de.genes, logFC > 1)
up.genes.names <-row.names(up.genes)

# get enrichment
kegg.up.enrichKEGG<-enrichKEGG(up.genes.names, organism='sce')

summary(kegg.up.enrichKEGG)

# do the same for down regulated genes

#FILL ME IN

# look at pathways

library(pathview)

data(korg)
head(korg)

# get organism of interest

organism <- "saccharomyces cerevisiae"
matches <- unlist(sapply(1:ncol(korg), function(i) {agrep(organism, korg[, i])}))
(kegg.code <- korg[matches, 1, drop = F])

#get the fold change data
gene.fc<-gene.data[1]
head(gene.fc)

#simulate compound database

cpd.data <- data.frame(FC = sim.mol.data(mol.type = "cpd", nmol = 4000))
head(cpd.data)

# look at the Meiosis pathways
map<-'sce04113'
pv.out <- pathview(gene.data = gene.fc,  cpd.data = cpd.data, gene.idtype = "KEGG",
pathway.id = map, species = kegg.code, out.suffix = map,
keys.align = "y", kegg.native = T, match.data=T, key.pos = "topright")
plot.name<-paste(map,map,"png",sep=".")

#Do some other pathway!
