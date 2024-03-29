###################################################
## sequencing statistics
## a) total amount of reads
## b) mapping hits
## c) number of splicing spanning reads
###################################################

system('mkdir plots')
# system('mkdir tables')


## star stats files
files = list.files(path="star",pattern="Log.final.out$", full.names=T)
samples = sapply(files, function(x) gsub(".Log.final.out", "",(gsub("star/", "", x))))
cols = c("TotalReads", "Multihits", "TooManyLoci", "OtherUnmapped", "TooManyMM", "TooShort", "UniqueHits", "TotalSplice")

star = c("Number of input reads", "% of reads mapped to multiple loci", "% of reads mapped to too many loci", "% of reads unmapped: other", "% of reads unmapped: too many mismatches", "% of reads unmapped: too short", "Uniquely mapped reads %", "Number of splices: Total")

i = 1
stats = read.csv(files[i], sep="\t",as.is=T)
for (i in 2:length(samples)) {
	stats = merge(stats, read.csv(files[i], sep="\t",as.is=T), by="Started.job.on..")
}
colnames(stats) = c("category", samples)
stats$category = gsub("\\|", "", stats$category)
stats$category = trimws(stats$category)
stats = stats[match(star, stats$category),]
rownames(stats) = cols
stats = t(stats[,-1])
stats[,-1] = gsub("%","",stats[,-1])
stats = t(matrix(as.numeric(stats), length(samples), length(cols), dimnames=list(samples, cols)))
stats = rbind(stats, sumOther=stats[1,]/100*colSums(stats[2:5,]))
# stats = rbind(stats, sumOther=stats[1,]/100*sum(stats[2:5,]))
stats = rbind(stats, short=stats[1,]/100*stats[6,])
stats = rbind(stats, unique=stats[1,]/100*stats[7,])
    

expname  = paste("_", basename(getwd()),sep='')

pdf(paste('plots/ReadStats',expname,'.pdf',sep=''), height=10,width=7)
par(mar=c(4,9,2,1))
bp=barplot(stats[11:9,]/10^6,main='Mapping results', las=1, border=NA, horiz=T, xlab='Reads in Mio',ylab='',xlim=c(0,max(stats[1,])*1.15/10^6), col=c("yellowgreen", "gray88", "gray48"))
legend("bottomright", dimnames(stats)[[1]][11:9], bty='n', col=c("yellowgreen", "gray88", "gray48"),pch=15)
mtext(side=2, las=1, line=-2, at=bp, text=paste(round(stats[11,]/stats[1,]*100),"%",sep="") )
abline(v=30,col="grey30", lty=3)
dev.off()

pdf(paste('plots/ReadStats_splice',expname,'.pdf',sep=''), height=10,width=7)
par(mar=c(4,9,2,1))
bp=barplot(stats[c(11,8),]/10^6,main='Mapping results', las=1, border=NA, horiz=T, beside=T, xlab='Reads in Mio',ylab='',xlim=c(0,max(stats[1,])*1.15/10^6), col=c("yellowgreen", "mediumblue"))
legend("bottomright", dimnames(stats[c(11,8),])[[1]], bty='n', col=c("yellowgreen", "mediumblue"),pch=15)
dev.off()


sessionInfo()

