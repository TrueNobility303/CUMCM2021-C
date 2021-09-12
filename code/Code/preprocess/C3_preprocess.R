d <- read.table('DS/data/d.txt', header = F)
s <- read.table('DS/data/s.txt', skip = 1, header = F)
ss <- s[, c(-1, -2)]
dd <- d[, c(-1, -2)]

upboundd <- apply(dd, 1, quantile, .95)
upbound <- apply(ss, 1, quantile, .95)

low.index <- which(upbound < 10)
high.index <- which(upbound >= 10)
ss.low <- ss[low.index, ]
ss.high <- ss[-low.index, ]
dd.high <- dd[-low.index, ]
res <- ss - dd

r <- apply(ss.low, 2, sum)
plot(density(r))

r.sd <- sd(r)

res.mean <- apply(res, 1, mean)
res.mean[low.index] <- 0
res.sd <- apply(res, 1, sd)
res.sd[low.index] <- 0

out <- cbind(res.mean, res.sd)
write.table(out, 'res.txt', row.names = F, col.names = F)
write.table(upboundd,
            'upbound.txt',
            row.names = F,
            col.names = F)
