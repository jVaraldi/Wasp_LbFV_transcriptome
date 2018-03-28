library(data.table)

liste_files=read.table("/pandata/varaldi/RNAseq_fev2018/OUT/liste_count_tables.txt", comment.char="")


liste=list()
liste[[1]] = read.table(as.character(liste_files$V1[1]))

for (i in (2:32)){
	print(i)
	liste[[i]] = fread(as.character(liste_files$V1[i]), header=F, select =2)
	}
	
tab_finale=do.call(cbind.data.frame, liste)

# import sample information to put explicit names
sample_info=read.table("/pandata/varaldi/RNAseq_fev2018_cuffmerge/sample_information.txt", h=T)

col_names=strsplit(as.character(liste_files$V1), split="/", fixed=T)
col_names=unlist(lapply(col_names, FUN=function(x){
			samp_number=strsplit(x[6], split="_", fixed=T)[[1]][1]
			# corresponding explicit name
			name=sample_info$name[sample_info$sample==as.numeric(samp_number)]
			return(name)
			}))



names(tab_finale) = c("gene_id",as.character(col_names))
head(tab_finale)
rownames(tab_finale)=tab_finale[,1]
tab_finale=tab_finale[,-1]

# order columns
tab_finale=tab_finale[, order(colnames(tab_finale))]

# remove te last five lines (not aligned etc...) 
mapping_stats=tab_finale[c(16792:16788),]

tab_finale=tab_finale[-c(16792:16788),]

# order rows
orf_number=sub(pattern="ORF", replacement="", x=rownames(tab_finale))

tab_finale=tab_finale[order(as.numeric(orf_number), decreasing=F),] 

# write to disk
write.table(tab_finale, "/pandata/varaldi/RNAseq_fev2018_cuffmerge/gene_count_matrix.csv", col.names=T, quote=F)
write.table(mapping_stats, "/pandata/varaldi/RNAseq_fev2018_cuffmerge/mapping_stats_hisat2.csv", col.names=T, quote=F)
