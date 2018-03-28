library(IRanges)
library(Biostrings)

gtf = read.table("merged_Lb_plus_LbFV.gtf", sep="\t")
# split column nine containing gene and transcript
split = strsplit(as.character(gtf$V9), split=" ", fixed=T)
liste = lapply(split, FUN = function (x) {
		gene_id = sub(pattern = ";" ,replacement ="", x = x[2]) 
		transcript_id = sub(pattern = ";" ,replacement ="", x = x[4])
		res =c(gene_id, transcript_id)
		return (res)
		}
		)
		
name_infos=do.call(rbind.data.frame, liste)

tab_infos=data.frame(gtf[, c(1,3,4,5,7)], name_infos)
names(tab_infos) = c("contig", "type", "start", "stop", "strand", "gene_id", "transcript_id")

# n genes
nlevels(tab_infos$gene_id)
# n transcripts
nlevels(tab_infos$transcript_id)


# define gene length (overlap of all exons for a gene)
split2 = split(tab_infos, tab_infos$gene_id)
gene_infos = lapply(split2, FUN=function(x){
		ranges = IRanges(x$start, x$stop)
		total_exons_length = sum(width(reduce(ranges)))
		first_transcript = x$transcript_id[1]
		other_transcripts = unique(x$transcript_id[x$transcript_id!= first_transcript])
		if (length(other_transcripts)>0) {
			other_transcripts=paste(as.character(other_transcripts), collapse=";")}
		if (length(other_transcripts)==0) {other_transcripts=NA}
		
		n_transcripts = length(unique(x$transcript_id))
		gene_id = x$gene_id[1]
		contig = x[1,1]
		start = min(x$start)
		end = max(x$stop)
		strand = x$strand[1]
		res= data.frame(gene_id, contig, start, end ,strand, n_transcripts, total_exons_length, first_transcript, other_transcripts)
		return(res)
		})

gene_infos_table=do.call(rbind.data.frame, gene_infos)


# write to disk
write.table(gene_infos_table, "./gene_infos_table.txt", col.names=T, row.names=F, quote=F)

# import corresponding sequences and subset to the first transcript for further annotation by blastx

seq=readDNAStringSet("/pandata/varaldi/RNAseq_fev2018/MERGE/transcripts.fa")

# subset to the first transcript reported by cuffmerge
seq_subset=seq[gene_infos_table$first_transcript]

length(seq_subset)

# modify the name to include gene_id
names_transcripts_retained=data.frame(names(seq_subset))
names(names_transcripts_retained)="transcript_name"
names_transcripts_retained_full=merge(names_transcripts_retained, gene_infos_table, by.x="transcript_name", by.y="first_transcript")
names_full=paste(names_transcripts_retained_full$gene_id, names_transcripts_retained_full$transcript_name, sep=" ")
names(seq_subset)=names_full

# write to disk
writeXStringSet(seq_subset, "/pandata/varaldi/RNAseq_fev2018/MERGE/transcripts_one_per_gene.fa")





