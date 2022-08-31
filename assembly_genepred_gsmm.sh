#!/bin/bash

# Please check the README.md for the software dependencies and the pointers
# to obtain the raw data.
RAW_PACBIO_READS="data/rawdata/3-E143388-gDNA_33337_subreads.fastq.gz"
RAW_ILLUMINA_R1_READS="data/rawdata/e143388_R1_deduped.fq.gz"
RAW_ILLUMINA_R2_READS="data/rawdata/e143388_R2_deduped.fq.gz"

FASTP_PACBIO_READS="results/fastp/e143388_pb_fastp.fq.gz"
FASTP_ILLUMINA_R1_READS="results/fastp/e143388_R1_deduped_fastp.fq.gz"
FASTP_ILLUMINA_R2_READS="results/fastp/e143388_R2_deduped_fastp.fq.gz"

# Illumina read-library preprocessing (fastp)
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

# PacBio read-library preprocessing (fastp)
fastp --dont_overwrite \
  --low_complexity_filter \
  --disable_quality_filtering \
  --trim_poly_g --trim_poly_x \
  --overrepresentation_analysis --thread 6 \
  --json=pacbio_fastp.json \
  --html=pacbio_fastp.html \
  -i "${RAW_PACBIO_READS}" \
  -o "${FASTP_PACBIO_READS}"

# De novo genome assembly (Unicycler, hybrid assembly)
unicycler --keep 3 \
  -1 "${FASTP_ILLUMINA_R1_READS}" -2 "${FASTP_ILLUMINA_R2_READS}" \
  -l "${FASTP_PACBIO_READS}" --threads 24 -o assembly

# Gene prediction on the genome assembly (prokka)
prokka --outdir annotation --prefix prokka assembly.fasta

# Construction of the genome-scale metabolic model (CarveMe)
PROTEIN_FASTA_FILE=prokka.faa
OUTPUT_SBML_FILE=e143388.xml

carve "${PROTEIN_FASTA_FILE}" -o "${OUTPUT_SBML_FILE}"
