# Lab 5 - evaluating assembly content!

Spin up an m1.medium computer on Jetstream.

Then...

## Installing Jupyter Notebook

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

## Downloading files from Lab 4

Let's start with the read and assembly files from [lab 4](https://github.com/ngs-docs/2018-ggg201b/tree/master/lab4-assembly):

```
mkdir ~/work
cd ~/work

curl -L -o ecoli-assembly.fa.gz https://osf.io/7khcr/download
curl -L -o ecoli_ref-5m.fastq.gz https://osf.io/frdz5/download

gunzip ecoli-assembly.fa.gz
```

## Mapping reads

First, let's ask the question: how many of the reads made it into the
assembly?

To do this, we'll need to map the reads to the assembly. Let's do it!

### Install bwa, for mapping

(see [lab 3](https://github.com/ngs-docs/2018-ggg201b/tree/master/lab3-mapping-2))

```
cd
curl -L https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2/download > bwa-0.7.17.tar.bz2

tar xjvf bwa-0.7.17.tar.bz2
cd bwa-0.7.17
make

sudo cp bwa /usr/local/bin
        
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

Also install samtools:

```
sudo apt-get -y install samtools
```

### Split and subsample the reads

Now, we'll do paired-end mapping - this is a way to see how much of the
pairing information made it into the assembly, as BWA will refuse to
map single reads whose pair doesn't map fairly close to the other read.

(Why can we subsample when doing this?)

We'll use `split-paired-reads.py` from 
[the khmer software](https://khmer.readthedocs.io/en/v2.1.1/) to 
split the paired reads into singleton files:

```
cd ~/work

gunzip -c ecoli_ref-5m.fastq.gz | head -1000000 | 
        split-paired-reads.py -1 head.1 -2 head.2 
```
             
### Map the reads:

```
bwa index ecoli-assembly.fa 
bwa aln ecoli-assembly.fa head.1 > head.1.sai 
bwa aln ecoli-assembly.fa head.2 > head.2.sai 
bwa sampe ecoli-assembly.fa head.1.sai head.2.sai head.1 head.2 > head.sam
```
        
### Convert to BAM:

```
samtools import ecoli-assembly.fai head.sam head.bam
samtools sort head.bam head.sorted
samtools index head.sorted.bam
```

### Ask how many reads didn't align to the assembly:

```
samtools view -c -f 4 head.sorted.bam
```

### Ask how many reads **did** align to the assembly:

```
samtools view -c -F 4 head.sorted.bam
```

What percentages mapped and didn't map?

Note, if you leave off the '-c' you can see the actual read sequences!
e.g. `samtools view -f 4 head.sorted.bam`. What could you do with
these?

## Comparing reads to genome with Jaccard containment

Next, let's ask the question: how many of the *words* in the
reads made it into the assembly, and how many of the words in the
assembly are in the reads?

sourmash is a tool developed in my lab for sample comparison. It works
with subsampled populations of DNA "words", or k-mers, to calculate
similarity and do database searches.

First we need to compute the subsampled signaturres of the data sets.

Adjusting [the tutorial](https://sourmash.readthedocs.io/en/latest/tutorials.html) a bit, we can do:

```
cd
pip install -U https://github.com/dib-lab/sourmash/archive/master.zip
cd ~/work
```

Then

```
sourmash compute --scaled 1000 ecoli_ref-5m.fastq.gz -o ecoli-reads.sig -k 31
sourmash compute --scaled 1000 ecoli-assembly.fa -k 31
```

Now we can quickly evaluate
[Jaccard similarity](https://en.wikipedia.org/wiki/Jaccard_index) and
Jaccard containment between the two data sets.

How similar is the assembly to the reads?

```
sourmash search ecoli-assembly.fa.sig ecoli-reads.sig
```

How much of the assembly is contained within the reads?

```
sourmash search ecoli-assembly.fa.sig ecoli-reads.sig --containment
```

How much of the reads is contained within the assembly?
```
sourmash search ecoli-reads.sig ecoli-assembly.fa.sig --containment
```

Let's now use
[the khmer software](https://khmer.readthedocs.io/en/v2.1.1/) to trim
the reads of k-mers that are lower than abundance 10 in the data set --

```
trim-low-abund.py -M 1e9 -C 10 ecoli_ref-5m.fastq.gz
```

this produces a file `ecoli_ref-5m.fastq.gz.abundtrim` that contains the
trimmed reads; let's compute a signature of that, too.

```
sourmash compute --scaled 1000 ecoli_ref-5m.fastq.gz.abundtrim -o ecoli-trimmed-reads.sig -k 31
```

Now you can do:

```
sourmash search ecoli-trimmed-reads.sig ecoli-assembly.fa.sig
```

and

```
sourmash search ecoli-trimmed-reads.sig ecoli-reads.sig
```

or compare all three with

```
sourmash compare *.sig
```
