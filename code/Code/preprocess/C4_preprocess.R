# from C3
d <- read.table('DS/data/d.txt', header = F)
s <- read.table('DS/data/s.txt', skip = 1, header = F)
ss <- s[, c(-1,-2)]
dd <- d[, c(-1,-2)]

upboundd <- apply(dd, 1, quantile, .95)
upbounds <- apply(ss, 1, quantile, .95)

low.index <- which(upbounds < 10)
high.index <- which(upbounds >= 10)

ss.low <- ss[low.index,]
ss.high <- ss[-low.index,]
dd.low <- dd[low.index,]
dd.high <- dd[-low.index,]

## for high, epsilon gaussian
ss.high.mean <- apply(ss.high, 1, mean)
ss.high.sd <- apply(ss.high, 1, sd)
dd.high.mean <- apply(dd.high, 1, mean)
dd.high.sd <- apply(dd.high, 1, sd)
alpha <- 0.75
ss.high.upbound <- ss.high.mean + 1.645 * ss.high.sd
dd.high.upbound <- dd.high.mean + 1.645 * dd.high.sd
high.upbound <-
  alpha * ss.high.upbound + (1 - alpha) * dd.high.upbound
high.sd <- alpha * ss.high.sd + (1 - alpha) * dd.high.sd


## for low, poisson
ss.low.lam <- apply(ss.low, 1, mean)
low.upbound <-
  apply(as.data.frame(ss.low.lam), 1, function(x) {
    qpois(.95, x)
  })

hsd <- upbound <- matrix(0,402,1)
upbound[high.index] <- high.upbound
upbound[low.index] <- low.upbound
hsd[high.index] <- high.sd
write.table(cbind(upbound,hsd),
            'upbound_new.txt',
            row.names = F,
            col.names = F)
