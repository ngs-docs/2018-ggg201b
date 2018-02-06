# Lab 3 - mapping

2/2/18, Titus Brown

Follows from [Lab 2](../lab2-mapping-etc/README.md).

Learning objectives:

* define and explore the concepts and implications of shotgun
  sequencing;
  
* explore coverage;

* understand the basics of mapping-based variant calling;

* learn basics of actually calling variants & visualizing.

## Boot up an Amazon instance

[Boot an m1.medium Jetstream instance](../lab1-jetstream/boot.md) and log in.

## Download data

Goal: get the sequence data!

1. Run:

```
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR258/007/SRR2584857/SRR2584857_1.fastq.gz
```
        
...and take a quick look at it ;).

## Map data

Goal: execute a basic mapping

1. Run the following commands to install bwa:

```
cd
curl -L https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2/download -o bwa-0.7.17.tar.bz2

tar xjvf bwa-0.7.17.tar.bz2
cd bwa-0.7.17
make

sudo cp bwa /usr/local/bin
```
        
2. Make & change into a working directory:

```
mkdir ~/work
cd ~/work
```

3. Copy and gunzip the reference:

```
git clone https://github.com/ngs-docs/2018-ggg201b.git ~/2018-ggg201b
cp ~/2018-ggg201b/lab2-mapping-etc/ecoli-rel606.fa.gz .
gunzip ecoli-rel606.fa.gz
```

and look at it:

```
head ecoli-rel606.fa.gz
```
        
4. Prepare it for mapping:

```
bwa index ecoli-rel606.fa
```
        
5. Map!

```
bwa mem -t 4 ecoli-rel606.fa ../SRR2584857_1.fastq.gz > SRR2584857.sam
```
        
6. Observe!

```
head SRR2584857.sam
```

what does all this mean??
        
## Visualize mapping

Goal: make it possible to go look at a specific bit of the genome.

1. Install samtools:

```
sudo apt-get -y install samtools
```
        
2. Index the reference genome:

```
samtools faidx ecoli-rel606.fa
```
        
3. Convert the SAM file into a BAM file:

```
samtools import ecoli-rel606.fa.fai SRR2584857.sam SRR2584857.bam
```
        
4. Sort the BAM file by position in genome:

```
samtools sort SRR2584857.bam SRR2584857.sorted
```
        
5. Index the BAM file so that we can randomly access it quickly:

```
samtools index SRR2584857.sorted.bam
```
        
6. Visualize with `tview`:

```
samtools tview SRR2584857.sorted.bam ecoli-rel606.fa
```
        
   `tview` commands of relevance:
   
   * left and right arrows scroll
   * `q` to quit
   * CTRL-h and CTRL-l do "big" scrolls
   * `g ecoli:3930990` will take you to a specific location with a variant.
   
## Call variants!

Goal: find places where the reads are systematically different from the
genome.
   
Now we can call variants using
[samtools mpileup](http://samtools.sourceforge.net/mpileup.shtml):

```
samtools mpileup -uD -f ecoli-rel606.fa SRR2584857.sorted.bam | \
    bcftools view -bvcg - > variants.raw.bcf
    
bcftools view variants.raw.bcf > variants.vcf
```

## Discussion points / extra things to cover

* What are the drawbacks to mapping-based variant calling? What are
  the positives?

* Where do reference genomes come from?

## REMEMBER TO TURN OFF YOUR JETSTREAM INSTANCE
