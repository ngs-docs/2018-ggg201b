# Lab 4 - Assembly!

Learning objectives:

* run a simple sequence assembly and think about evaluation techniques.

## Running an assembler

### Start up a Jetstream instance

### Install the MEGAHIT assembler

Check out and build [MEGAHIT](https://www.ncbi.nlm.nih.gov/pubmed/27012178):

```
git clone https://github.com/voutcn/megahit.git
cd megahit
make -j 4
```

### Download an E. coli data set

Grab the following E. coli data set:

```
mkdir ~/work
cd ~/work

curl -L -o ecoli_ref-5m.fastq.gz https://osf.io/frdz5/download
```
    
### Run the assembler

Assemble the E. coli data set with MEGAHIT:

```
~/megahit/megahit --12 ecoli_ref-5m.fastq.gz -o ecoli
```

(This will take about 4 minutes.)  You should see something like:

```
--- [STAT] 117 contigs, total 4577284 bp, min 220 bp, max 246618 bp, avg 39122 bp, N50 105708 bp
--- [Fri Feb 10 14:33:59 2017] ALL DONE. Time elapsed: 342.060158 seconds ---
```

at the end.

Questions while we're waiting:

* how many reads are there?

* how long are they?

* are they paired end or single-ended?

* are they trimmed?

...and how would we find out?

Also, what expectation do we have for this genome in terms of size,
content, etc?

### Looking at the assembly

First, save the assembly:

```
cp ecoli/final.contigs.fa ecoli-assembly.fa
```

How big is it? How big is it compared to the reads? (Why the size disparity?)
    
Now, look at the beginning:

```
head ecoli-assembly.fa
```
    
It's DNA! Yay! ...but it doesn't look super useful at the moment...

* We could BLAST some specific genes;
* We could compare against a known genome if we have one (but this is evaluating the assembler, not the assembly!)

### Measuring the assembly

Install [QUAST](http://quast.sourceforge.net/quast):

```
cd ~/
git clone https://github.com/ablab/quast.git -b release_4.2
export PYTHONPATH=$(pwd)/quast/libs/
```

Run QUAST on your assembly:

```
cd ~/work
~/quast/quast.py ecoli-assembly.fa -o ecoli_report
```
   
```
python2.7 ~/quast/quast.py ecoli-assembly.fa -o ecoli_report
```

Now, type `cat ecoli_report/report.txt`.
This contains a set of summary stats. Are they good?

(What is "good"? How do you measure it? Etc. etc.)

## Digression: downloading files

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

## End of days

Question: why so many contigs?!
