#GPVI parameter analysis
library(ggplot2)
library(dplyr)
matchdf<-read.table("gpvi_topmatch/gpvi_ranking.txt",sep="\t",header=TRUE)

#plot(matchdf[,c("iptm","ptm","ranking_score")])

datac <- gsub("\\[|\\]","",matchdf$chain_iptm,fixed = FALSE)
datal<-sapply(datac,
      function(x){y=strsplit(x,",");a=as.numeric(y[[1]][1]);b=as.numeric(y[[1]][2]);return(c(a,b))},simplify = TRUE)

datachain<-t(datal)
data=matchdf[,c("iptm","ptm")]

ggplot(data, aes(x=iptm, y=ptm) ) + geom_bin2d(bins = 80) +
  scale_fill_continuous(type = "viridis") + theme_bw()


ggplot(data, aes(x=iptm, y=ptm) ) + 
  stat_density_2d(aes(fill = ..level..), geom = "polygon")




plot(density(matchdf$iptm))

library(LSD)
par(mfcol=c(3,2))
hist(matchdf$iptm,breaks=100,xlab="iptm",main=paste("Histogram of" , "iptm"))
hist(matchdf$ptm,breaks=100,xlab="ptm",main=paste("Histogram of" , "ptm"))
hist(matchdf$ranking_score,breaks=100,xlab="ranking_score",main=paste("Histogram of" , "ranking_score"))
heatscatter(matchdf$iptm,matchdf$ptm,xlab="iptm",ylab="ptm")
heatscatter(matchdf$iptm,matchdf$ranking_score,xlab="iptm",ylab="ranking_score")
heatscatter(matchdf$ptm,matchdf$ranking_score,xlab="ptm",ylab="ranking_score")

