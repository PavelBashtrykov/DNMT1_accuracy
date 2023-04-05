#!/usr/bin/bash -i

################################################################################
# This script is written by Pavel Bashtrykov
# pavel.bashtrykov@ibtb.uni-stuttgart.de
# pavel.bashtrykov@gmail.com
################################################################################


# PROVIDE ABSOLUTE PATH TO THE GENOME AND SCRIPTS
PATH_GENOME_FASTA=~/HDD/genomes/mm9/mm9.fa
PATH_WGBS2FLANKS=~/tools/WGBS2Flanks/
PATH_DNMT1_ACCURACY=~/tools/DNMT1_accuracy/

# GET DATA FROM GEO
SAMPLES=(GSM3239884_SKO_mES_BS_seq_mCG.txt GSM4809269_SKO_Dnmt1_KO_BS_seq_mCG.txt GSM3239875_QKO_Dnmt3c_KO_BS_seq_mCG.txt GSM3239876_QKO_mES_BS_seq_rep1_mCG.txt)

wget -c https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM3239nnn/GSM3239884/suppl/GSM3239884_SKO_mES_BS_seq_mCG.txt.gz
gzip -dk GSM3239884_SKO_mES_BS_seq_mCG.txt.gz

wget -c https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4809nnn/GSM4809269/suppl/GSM4809269_SKO_Dnmt1_KO_BS_seq_mCG.txt.gz
gzip -dk GSM4809269_SKO_Dnmt1_KO_BS_seq_mCG.txt.gz

wget -c https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM3239nnn/GSM3239875/suppl/GSM3239875_QKO_Dnmt3c_KO_BS_seq_mCG.txt.gz
gzip -dk GSM3239875_QKO_Dnmt3c_KO_BS_seq_mCG.txt.gz

wget -c https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM3239nnn/GSM3239876/suppl/GSM3239876_QKO_mES_BS_seq_rep1_mCG.txt.gz
gzip -dk GSM3239876_QKO_mES_BS_seq_rep1_mCG.txt.gz


# FLANKING SEQUENCE ANALYISIS

analyse_flanks(){
    python ${4}convert_top_strand2bismark.py ${1}

    python ${2}wgbs2bed.py\
        --infile ${1}.bis.txt\
        --outfile ${1}_coordinates.bed

    bedtools getfasta -tab -s -name\
        -fi ${3}\
        -bed ${1}_coordinates.bed\
        -fo ${1}_coordinates_sequences.txt

    python ${2}compute_flanks.py --depth 10\
        --infile ${1}_coordinates_sequences.txt\
        --outfile ${1}_flanks_methylation_d10.csv

    python ${2}compute_flanks.py --depth 5\
        --infile ${1}_coordinates_sequences.txt\
        --outfile ${1}_flanks_methylation_d5.csv
}

for i in ${SAMPLES[@]}; do analyse_flanks "$i" "$PATH_WGBS2FLANKS" "$PATH_GENOME_FASTA" "$PATH_DNMT1_ACCURACY"; done
