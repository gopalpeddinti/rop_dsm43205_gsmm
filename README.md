# Rhodococcus opacus DSM43205 genome assembly, annotation, and metabolic model simulations

This repository contains the _Rhodococcus opacus_ DSM43205 genome scale
metabolic model in SBML format associated with the genome assembly available at
the European Nucleotide Archive (ENA) project PRJEB45460. The documentation for
how the model was produced is given below.

## Genome Assembly

Unicycler (https://github.com/rrwick/Unicycler) was used for the hybrid (long
and short read) _de novo_ assembly of the _Rhodococcus opacus_ DSM43205 genome.
The software versions used during the Unicycler assembly are listed in the table
below.


| Software | version |
|:--------:|:-------:|
| Unicycler | 0.4.6 |
| spades | 3.12.0 |
| racon | 1.3.1 |
| NCBI-BLAST+ | 2.5.0 |
| bowtie2 | 2.3.4.2 |
| samtools | 1.9 |
| java | 1.8.0_121 |
| pilon | 1.22 |

Note that, the PacBio reads and Illumina paired-end reads should be downloaded
from ENA study PRJEB45460 (PacBio reads, ERR6004137; Illumina reads, ERR6004016)
to be able to perform the assembly with the commands shown below.

```{bash}
RAW_PACBIO_READS="data/rawdata/3-E143388-gDNA_33337_subreads.fastq.gz"
RAW_ILLUMINA_R1_READS="data/rawdata/e143388_R1_deduped.fq.gz"
RAW_ILLUMINA_R2_READS="data/rawdata/e143388_R2_deduped.fq.gz"

FASTP_PACBIO_READS="results/fastp/e143388_pb_fastp.fq.gz"
FASTP_ILLUMINA_R1_READS="results/fastp/e143388_R1_deduped_fastp.fq.gz"
FASTP_ILLUMINA_R2_READS="results/fastp/e143388_R2_deduped_fastp.fq.gz"

fastp --qualified_quality_phred=20 \ 
  --dont_overwrite \
  --cut_by_quality3 \
  --cut_by_quality5 \
  --low_complexity_filter \
  --trim_poly_g \
  --trim_poly_x \
  --overrepresentation_analysis --thread 6 \
  --json=illumina_fastp.json \
  --html=illumina_fastp.html \
  -i "${RAW_ILLUMINA_R1_READS}" -I "${RAW_ILLUMINA_R2_READS}" \
  -o "${FASTP_ILLUMINA_R1_READS}" -O "${FASTP_ILLUMINA_R2_READS}"
  
fastp --dont_overwrite \
  --low_complexity_filter \
  --disable_quality_filtering \
  --trim_poly_g --trim_poly_x \
  --overrepresentation_analysis --thread 6 \
  --json=pacbio_fastp.json \
  --html=pacbio_fastp.html \
  -i "${RAW_PACBIO_READS}" \
  -o "${FASTP_PACBIO_READS}"
  
unicycler --keep 3 \
  -1 "${FASTP_ILLUMINA_R1_READS}" -2 "${FASTP_ILLUMINA_R2_READS}" \
  -l "${FASTP_PACBIO_READS}" --threads 24 -o assembly
```

## Gene prediction and annotation

The genome annotation was performed using prokka
(https://github.com/tseemann/prokka). The software versions used during the
prokka annotations are listed in the table below.

| Software | version |
|:--------:|:-------:|
| prokka | 1.13.3 |
| aragorn | 1.2 |
| barrnap | 0.9 |
| NCBI-BLAST+ | 2.7 |
| cmpress, cmscan | 1.1 |
| hmmscan, hmmpress | 3.2 |
| minced | 3.2 |
| prodigal | 2.6 |
| tbl2asn | 25.6 |
| BioPerl | 1.007002 |

```{bash}
prokka --outdir annotation --prefix prokka assembly.fasta
```

## Metabolic model reconstruction

The metabolic model was reconstructed using CarveMe
(https://github.com/cdanielmachado/carveme). The software versions used during
the reconstruction of the model provided in this repository. Note that GLPK (GNU
Linear Programming kit, https://www.gnu.org/software/glpk/) can be used as an
open source alternative to the CPLEX
(https://www.ibm.com/analytics/cplex-optimizer).

| Software | version |
|:--------:|:-------:|
| carveme | 1.2.2 |
| cplex (CPLEX studio and python interface) | 12.8.0.1 |
| framed | 0.5.2 |


Note that, the set of all protein sequences from the Rhodococcus opacus DSM43205
data set should be obtained by either performing the genome assembly and
annotation as described above or by downloading the protein fasta file from ENA
project PRJEB45460 (genome assembly, ERZ2486663), to be able to perform the
metabolic model reconstruction.


```{bash}
PROTEIN_FASTA_FILE=prokka.faa
OUTPUT_SBML_FILE=e143388.xml

carve "${PROTEIN_FASTA_FILE}" -o "${OUTPUT_SBML_FILE}"
```

## Metabolic model simulations

The code for metabolic model simulations are presented in the python notebook `ROP_simulations.ipynb`.
