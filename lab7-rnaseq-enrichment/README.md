# Lab 9 - RNAseq expression analysis, re-revisited (this time with function in mind)

3/9/2018, Harriet Alexander, harriet.xander@gmail.com


With any sort of RNAseq project, you will at some point (depending on your question), want to turn the lists of fold change and significantly differentially abundant genes into some sort of biologically meaningful information. In this lab we will be relying upon the [KEGG](http://www.genome.jp/kegg/pathway.html) database to help get a better idea of the biochemical consequences of the mutation. There are many different metabolic databases/frameworks you can choose from (e.g. GO), but I tend to gravitate towards KEGG for a few reasons: 1) the hierarchy of metabolic pathways is more logical than GO and 2) it can incorporate the co-analysis of genomic/transcriptomic/proteomic data and metabolomic data (more on this later).

### Learning objectives:

1. Think about relating functional annotation and expression values.

2. Visualize shifts in transcript and metabolite (simulated for this exercise) abundance between treatments.

## Start up an instance, install stuff, and start playing around with the edgeR results from last week

1. Start up a new cloud instance (as usual; see [Start up an m1.medium instance running Ubuntu 16.04 on Jetstream.](../lab1-jetstream/boot.md)).

2. Open the web shell. Run `bash`.

3. Clone the course github repo:

         git clone https://github.com/ngs-docs/2018-ggg201b.git

4. Install the R packages [pathview](https://bioconductor.org/packages/release/bioc/html/pathview.html) and [clusterProfiler](https://bioconductor.org/packages/release/bioc/vignettes/clusterProfiler/inst/doc/clusterProfiler.html#kegg-over-representation-test) as well as some annoying dependencies required for these to compile properly:

        cd
        sudo apt-get -y build-dep libcurl4-gnutls-dev
        sudo apt-get -y install libcurl4-gnutls-dev
        sudo apt-get install libcurl4-openssl-dev
        sudo apt-get install libxml2-dev
        sudo apt-get install libssh2-devel
        sudo apt-get -y install gdebi-core r-base
        sudo Rscript --no-save ~/2017-ucdavis-igg201b/lab9/install-pathview-clusterProfiler.R

4. Install RStudio:

        wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb
        sudo gdebi -n rstudio-server-1.0.143-amd64.deb   

4. You should text indicating that RStudio is running like the following. This indicates that the RStudio server is now running (much like a Jupyter Notebook):

        Mar 09 00:36:33 js-169-205.jetstream-cloud.org systemd[1]: Starting RStudio Server...
        Mar 09 00:36:33 js-169-205.jetstream-cloud.org systemd[1]: Started RStudio Server.

4. Now, we can type the following to figure out where the RStudio server is running. Click on the hyperlink and it should take you to the RStudio server. You can then sign in using the same username/password that you use to log in to jetstream.:

        echo My RStudio Web server is running at: http://$(hostname):8787/

4. Finally, navigate into the lab 7 folder and make a directory called functional-analysis:

        cd 2018-ggg201b/lab7-rnaseq-enrichment/
        mkdir functional-analysis
        cd functional-analysis

## Identify the metabolic pathways in KEGG that are statistically over-represented

1. Load the `clusterProfiler` library (for more information on clusterProfiler see [Yu et al. 2012](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3339379/)):

        library(clusterProfiler)
        library(DOSE)

2. Read in the edgeR output from last lab:

        gene.data <- read.csv(file='../yeast-edgeR.csv', row.names=1)

3. Subset the data to identify the significantly DE genes as well as those that are increased in the WT condition:

        de.genes <- subset(gene.data, FDR < 0.05)
        up.genes <-subset(de.genes, logFC > 1)
        up.genes.names <-row.names(up.genes)

4. Run `enrichKEGG` (which calculates a p-value for enrichment using a [hypergeometic distribution](https://en.wikipedia.org/wiki/Hypergeometric_distribution)) to identify the significantly enriched KEGG pathways in the set of genes that are increased in abundance in the WT condition:  

        kegg.up.enrichKEGG<-enrichKEGG(up.genes.names, organism='sce')

5. Look at the results. What do they mean? What is `enrichKEGG` doing? What pathways are most significantly enriched?

        head(summary(kegg.up.enrichKEGG))

6. Modify the above code to run the same calculation for genes with significantly decreased abundance.

## Visualize the enriched pathways:

1. Load the `pathview` library:

        library(pathview)

1. Pathview lets you take advantage of the genomes that are available in the KEGG database. Take a look at all of them [here](http://www.genome.jp/kegg/catalog/org_list.html):

        data(korg)
        head(korg)

2. Pull out our organism of interest with a quick search:

        organism <- "saccharomyces cerevisiae"
        matches <- unlist(sapply(1:ncol(korg), function(i) {agrep(organism, korg[, i])}))
        (kegg.code <- korg[matches, 1, drop = F])

3. Now, grab the log fold change (`logFC`) data from the `gene.data` dataframe:

        gene.fc<-gene.data[1]
        head(gene.fc)

4. Now, we are going to simulate some metabolite data just to show why we are using KEGG in particular and to show how `pathview` can handle both data types:

        cpd.data <- data.frame(FC = sim.mol.data(mol.type = "cpd", nmol = 4000))

5. Now, let's plot a pathway that was identified as significantly enriched by the above analysis. We will start off looking at the pathway map for Meiosis (sce04113), which was signficantly enriched in the analysis with `clusterProfiler`:

        map<-'sce04113'
        pv.out <- pathview(gene.data = gene.fc,  cpd.data = cpd.data, gene.idtype = "KEGG",
        pathway.id = map, species = kegg.code, out.suffix = map,
        keys.align = "y", kegg.native = T, match.data=T, key.pos = "topright")
        plot.name<-paste(map,map,"png",sep=".")

6. Take a look at the pathways that are available for _S. cerevisiae_.

        library(KEGGREST)
        pathways<-keggList("pathway", kegg.code)
        pathways

7. Rerun the `pathview` plotting code for a new pathway (try to find one with more metabolites involved).
