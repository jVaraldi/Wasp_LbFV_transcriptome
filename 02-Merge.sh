#PBS -S /bin/bash
#PBS -e /pandata/varaldi/RNAseq_fev2018_cufflinks/logs/merge.error
#PBS -o /pandata/varaldi/RNAseq_fev2018_cufflinks/logs/merge.out
#PBS -N merge
#PBS -l nodes=1:ppn=4 -l mem=10gb
#PBS -q q1day
hostname
uname -a

# Script that merges the gtf obtained for the 32 samples to obtain the most comprehensive view of the transcriptome of L. boulardi. The loci of LbFV are removed and the gtf of LbFV (108 ORFs) is added to get an hybrid gtf Lb+LbFV. This gtf will be used to perform the mapping. 

###############################################
# GENOME Lb + LbFV
###############################################
GENOME=/pandata/varaldi/RNAseq_fev2018/Lb_LbFV.fa

###############################################
#LbFV GTF
###############################################
LbFV_GTF=/pandata/varaldi/RNAseq_fev2018/LbFV.gtf

###############################################
# softwares
###############################################
CUFFMERGE=~/TOOLS/cufflinks-2.2.1.Linux_x86_64/cuffmerge
GFFREAD=~/TOOLS/gffread-0.9.11.Linux_x86_64/gffread
GFFCOMPARE=~/TOOLS/gffcompare-0.10.2.Linux_x86_64/gffcompare

# add cufflinks folder to the PATH
PATH=$PATH:~/TOOLS/cufflinks-2.2.1.Linux_x86_64/


###############################################
# list of gtf files to merge
###############################################

LISTE=/pandata/varaldi/RNAseq_fev2018/OUT/liste_gtf_cufflinks.txt

###############################################
# where to write 
###############################################
OUT=/pandata/varaldi/RNAseq_fev2018/MERGE/
mkdir $OUT
cd $OUT

###############################################
# MERGE GTFs 
###############################################
$CUFFMERGE -o $OUT -p 4  $LISTE

# output : merged.gtf 

# prepare gtf (because some transcripts map OUTSIDE the contigs (flanking reads)
Rscript ~/TOOLS/prepare_gtf.R merged.gtf $GENOME merged_fixed.gtf

###############################################
# basic extract of the transcripts
###############################################
$GFFREAD -w $OUT'transcripts_Lb.fa' -g $GENOME $OUT'merged_fixed.gtf'

###############################################
# remove Lb loci from gtf
###############################################
grep -v LbFV $OUT'merged_fixed.gtf' > $OUT'merged_without_LbFV.gtf'

###############################################
# add LbFV 108 orfs to the GTF
###############################################
cat $LbFV_GTF $OUT'merged_without_LbFV.gtf' > $OUT'merged_Lb_plus_LbFV.gtf'

###############################################
# extract the transcripts Lb + LbFV
###############################################
$GFFREAD -w $OUT'transcripts.fa' -g $GENOME $OUT'merged_Lb_plus_LbFV.gtf'

