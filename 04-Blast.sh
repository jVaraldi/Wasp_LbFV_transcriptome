#PBS -S /bin/bash
#PBS -l nodes=1:ppn=4
#PBS -e /pandata/varaldi/RNAseq_fev2018/logs/blast_MONFICHIER.error
#PBS -o /pandata/varaldi/RNAseq_fev2018/logs/blast_MONFICHIER.out
#PBS -N MONFICHIER
#PBS -q q1day

hostname
uname -a

# dure environ 10h avec 4cpu, 5h avec 8cpu..

# Blast transcripts in order to annotate it with BLAST2GO

# EXECUTABLE
BLASTX=/panusr/ncbi-blast-2.2.25+/bin/blastx

# FASTA FILE (transcripts)
cp /pandata/varaldi/RNAseq_fev2018/SPLIT_FASTA2/MONFICHIER ./INPUT.fa


# where to put the output ?
DESTINATION_FOLDER=/pandata/varaldi/RNAseq_fev2018/SPLIT_FASTA2/

# DB downloaded on 26/02/18
DB=/data/blast/refseqprot

# run blast
time $BLASTX -query INPUT.fa -db $DB -outfmt 5 -evalue 1e-5 -show_gis -num_alignments 20 -num_threads 4 -out OUTPUT.xml
 
 mv OUTPUT.xml $DESTINATION_FOLDER'/MONFICHIER.xml'
 
