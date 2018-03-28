#PBS -S /bin/bash
#PBS -e /pandata/varaldi/RNAseq_fev2018_cuffmerge/logs/FICHIER_htseq.error
#PBS -o /pandata/varaldi/RNAseq_fev2018_cuffmerge/logs/FICHIER_htseq.out
#PBS -N FICHIER
#PBS -l nodes=1:ppn=2 -l mem=10gb
#PBS -q q1day
hostname
uname -a

# Count reads falling into each gene

##############################################
#   INPUT1 : BAM FILE
##############################################
BAM=/pandata/varaldi/RNAseq_fev2018/OUT/FICHIER/alns_sorted_for_cufflinks.bam

##############################################
#   INPUT2 : GTF FILE (merged)
##############################################
GTF=/pandata/varaldi/RNAseq_fev2018/MERGE/merged_Lb_plus_LbFV.gtf

##############################################
#   HTSEQ version 0.6.0
##############################################
HTSEQ_COUNT=/panhome/varaldi/.local/bin/htseq-count

##############################################
#   run
##############################################
cd /pandata/varaldi/RNAseq_fev2018_cuffmerge/HTSEQ

$HTSEQ_COUNT -r pos -f bam --stranded=no $BAM $GTF > $BAM'.table' 

