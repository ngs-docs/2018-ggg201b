# Lab 2

[Boot a Jetstream](../lab1-jetstream/boot.md)

## At the command line:

1. Run `git clone https://github.com/ngs-docs/2017-ucdavis-igg201b.git`

## Look at some FASTQ data

2. In a Web browser, go to [the ENA record for SRX1317384](https://www.ebi.ac.uk/ena/data/view/SRX1317384)

3. Copy the url for `Fastq files (ftp)`, `File 1`.

4. In your terminal, execute `curl -O ` and then paste in the URL.

5. Wait for it to download.

6. Run

        gunzip -c SRR2584857_1.fastq.gz | head
        
   Marvel at the FASTQ!

6. Install [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/):

```
cd ~/
wget https://launchpad.net/ubuntu/+archive/primary/+files/fastqc_0.11.5+dfsg-3_all.deb && \
sudo dpkg -i fastqc_0.11.5+dfsg-3_all.deb && \
sudo apt-get install -f
```

7. Run FastQC:

        fastqc SRR2584857_1.fastq.gz

8. If you know how to download files from a remote host, do so for the file `SRR2584857_1_fastqc.zip`; otherwise you can download the resulting file by [clicking on this link](https://github.com/ngs-docs/2018-ggg201b/raw/master/lab2-mapping-etc/SRR2584857_1_fastqc.zip).  If you open this file, you will see `fastqc_report.html`; double-click on that to open it in a browser.  This is a quality report on that file.

There's a [nice tutorial](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the FastQC web site for those who are interested in more.

## REMEMBER TO DELETE YOUR JETSTREAM INSTANCE.
