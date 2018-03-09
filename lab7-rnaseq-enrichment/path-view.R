library(clusterProfiler)
library(DOSE)
setwd('/Users/halexand/Projects/DeepDOM/KeggAnalysis')
gene.data <- read.csv(file='Diatom/Full_Comparison_KEGG.edgeR.tab.tps.csv', row.names=1)
de.genes <- subset(gene.data, PValue < 0.1)
up.genes <-subset(de.genes, logFC > 0)
up.genes.names <-row.names(up.genes)
dn.genes <-subset(de.genes, logFC < 0)
dn.genes.names <-row.names(dn.genes)

kegg.up.enrichKEGG<-enrichKEGG(up.genes.names, organism='tps', pvalueCutoff=0.2)
kegg.dn.enrichKEGG<-enrichKEGG(dn.genes.names, organism='tps', pvalueCutoff=0.2)

kegg.up.enrichMKEGG<-enrichMKEGG(up.genes.names, organism='tps', pvalueCutoff=0.2)
kegg.dn.enrichMKEGG<-enrichMKEGG(dn.genes.names, organism='tps', pvalueCutoff=0.2)

summary(kegg.up.enrichKEGG)
summary(kegg.dn.enrichKEGG)
summary(kegg.up.enrichMKEGG)
summary(kegg.dn.enrichMKEGG)

gene.fc<-gene.data[1]

phag<-'tps04145'
nmet<-'tps00910'
aa <-'tps01230'
photo <- 'tps00195'
carb <- 'tps00710'
tca <-'tps00020'
purine <- 'tps00230'
sphingo <-'tps00600'
endo <-'tps04144'
peroxi<-'tps04146'
autophag <-'tps04136'
tpslist<-c(phag, nmet, aa, photo, carb, tca, purine, sphingo,  endo, peroxi, autophag)

for (map in tpslist){
  pv.out <- pathview(gene.data = gene.fc, gene.idtype = "KEGG",
                     pathway.id = map, species = kegg.code, out.suffix = map,
                     keys.align = "y", kegg.native = T, match.data=T, 
                     key.pos = "topright", limit=c(-1, 1), low="blue", mid="snow2", high="orange")
  plot.name<-paste(map,map,"png",sep=".")
  
}



