# Lab 6 - RNAseq expression analysis

Learning objectives:

@CTB
1. Dig into some statistical thoughts.

2. Think about the pipeline, and maybe the github.

## Running an RNAseq analysis.

0. Start up a new cloud instance; m1.medium is probably fine for this.

1. Installing Jupyter Notebook and run Terminal.

```
pip install jupyter
```

then

```
jupyter notebook --generate-config
```

and

```
cat >> ~/.jupyter/jupyter_notebook_config.py <<EOF
c = get_config()
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'sha1:5d813e5d59a7:b4e430cf6dbd1aad04838c6e9cf684f4d76e245c'
c.NotebookApp.port = 8000

EOF
```

These commands will install Jupyter Notebook and configure it to run on
port 8000 with a password.

Now, run it!

```
jupyter notebook &
```

You can figure out what Web address to connect to this way:
```
echo http://$(hostname):8000/
```

and note things like file view, download, etc. etc.

Now go to that Web address in your browser and start a terminal!
(New... Terminal...)


2. Install base R.

```
sudo apt-get -y install r-base-core
```

3. Install edgeR using [this script](https://github.com/ngs-docs/2018-ggg201b.git/blob/master/lab6-rnaseq/install-edgeR.R):

```
cd
git clone https://github.com/ngs-docs/2018-ggg201b.git

sudo Rscript --no-save ~/2018-ggg201b/lab6-rnaseq/install-edgeR.R
```

4. Install [salmon](https://salmon.readthedocs.io):

```
cd
curl -L -O https://github.com/COMBINE-lab/salmon/releases/download/v0.9.1/Salmon-0.9.1_linux_x86_64.tar.gz
tar xzf Salmon-0.9.1_linux_x86_64.tar.gz
export PATH=$PATH:$HOME/Salmon-latest_linux_x86_64/bin
```

5. Run:

```
mkdir yeast
cd yeast
```

6. Download some data from [Schurch et al, 2016](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4878611/):

@CTB

```
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458500/ERR458500.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458501/ERR458501.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458502/ERR458502.fastq.gz

curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458493/ERR458493.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458494/ERR458494.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458495/ERR458495.fastq.gz
```

7. Download the yeast reference transcriptome:

```
curl -O https://downloads.yeastgenome.org/sequence/S288C_reference/orf_dna/orf_coding.fasta.gz
```

8. Index the yeast transcriptome:

```
salmon index --index yeast_orfs --type quasi --transcripts orf_coding.fasta.gz
```

9. Run salmon on all the samples:

```
for i in *.fastq.gz
do
   salmon quant -i yeast_orfs --libType U -r $i -o $i.quant --seqBias --gcBias
done
```

Read up on [libtype, here](https://salmon.readthedocs.io/en/latest/salmon.html#what-s-this-libtype).

10. Collect all of the sample counts using [this Python script](https://github.com/ngs-docs/2016-aug-nonmodel-rnaseq/blob/master/files/gather-counts.py):


@CTB
```
python2 ~/2018-ggg201b/lab6-rnaseq/gather-counts.py
```

11. Run edgeR (in R) using [this script](https://github.com/ngs-docs/2018-ggg201b/blob/master/lab6-rnaseq/yeast.salmon.R) and take a look at the output:

```
Rscript --no-save ~/2018-ggg201b/lab6-rnaseq/yeast.salmon.R
```

This will produce two plots, `yeast-edgeR-MA-plot.pdf` and
`yeast-edgeR-MDS.pdf`. You can view them by going to your Jupyter
console and looking in the directory `yeast`.

 The `yeast-edgeR.csv` file contains the fold expression & significance information in a spreadsheet.

## Questions to ask/address

1. What is the point or value of the [multidimensional scaling (MDS)](https://en.wikipedia.org/wiki/Multidimensional_scaling) plot?

2. Why does the MA-plot have that shape?

   Related: Why can't we just use fold expression to select the things we're interested in?

   Related: How do we pick the FDR (false discovery rate) threshold?

3. How do we know how many replicates (bio and/or technical) to do?

   Related: what confounding factors are there for RNAseq analysis?

   Related: what is our false positive/false negative rate?

## More reading

"How many biological replicates are needed in an RNA-seq experiment and which differential expression tool should you use?" [Schurch et al., 2016](http://rnajournal.cshlp.org/content/22/6/839).

"Salmon provides accurate, fast, and bias-aware transcript expression estimates using dual-phase inference" [Patro et al., 2016](http://biorxiv.org/content/early/2016/08/30/021592).

Also see [seqanswers](http://seqanswers.com/) and [biostars](https://www.biostars.org/).
