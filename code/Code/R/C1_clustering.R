d <- read.table('DS/data/d.txt', header = F)
s <- read.table('DS/data/s.txt', skip = 1, header = F)

sA <- s[s[2]=='A',]
sB <- s[s[2]=='B',]
sC <- s[s[2]=='c',]
sA.w <- sA[,c(-1,-2)]/0.6
sB.w <- sB[,c(-1,-2)]/0.66
sC.w <- sC[,c(-1,-2)]/0.72
s.w <- s
s.w[s[2]=='A',c(-1,-2)] <- sA.w
s.w[s[2]=='B',c(-1,-2)] <- sB.w
s.w[s[2]=='C',c(-1,-2)] <- sC.w

feature <- function(s) {
 s.mean <- apply(s[,c(-1,-2)], 1, mean)
 s.rate <- s[,c(-1,-2)]/d[,c(-1,-2)]
 s.rate[is.nan(as.matrix(s.rate))] <- NA
 s.rate.mean <- apply(s.rate, 1, mean, na.rm = T)
 s.rate.var <- apply(s.rate, 1, var, na.rm = T)
 return(cbind(s.mean, s.rate.mean, s.rate.var))
}
s.w.feature <- feature(s.w)

X <- scale(s.w.feature)
X[1] <- X[1]
hc.complete <- hclust(dist(X), method="complete")
hc.average <- hclust(dist(X), method="average")
opar <- par(no.readonly = T)
par(mfrow=c(1,2))
plot(hc.complete, main="Complete Linkage", 
     xlab="", sub="", cex=.9)
plot(hc.average, main="Average Linkage", 
     xlab="", sub="", cex=.9)
par(opar)
class.c <- cutree(hc.complete, 2)
table(class.c)
aggregate(s.w.feature, by=list(cluster=class.c), median)

class.a <- cutree(hc.average, 3)
table(class.a)
aggregate(s.w.feature, by=list(cluster=class.a), mean)
