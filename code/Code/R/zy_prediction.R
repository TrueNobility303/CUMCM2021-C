zy <- read.table('DS/data/zy.txt', header = T)
zy <- zy[-1]
zy[zy == 5] <- 0
zy[zy == 0] <- NA

# 3,4,5 have many NA
apply(zy, 1, function(x) {
  sum(is.na(x))
})

# use mean to fill NA exclude T3,T4,T5
zy.mean <- apply(zy, 1, mean, na.rm = T)
for (i in c(1, 2, 6, 7, 8)) {
  zyi <- zy[i, ]
  zy[i, is.na(zyi)] <- zy.mean[i]
}

# data frame to vector
T1 <- as.vector(as.matrix(zy[1, ]))
T2 <- as.vector(as.matrix(zy[2, ]))
T3 <- as.vector(as.matrix(zy[3, ]))
T4 <- as.vector(as.matrix(zy[4, ]))
T5 <- as.vector(as.matrix(zy[5, ]))
T6 <- as.vector(as.matrix(zy[6, ]))
T7 <- as.vector(as.matrix(zy[7, ]))
T8 <- as.vector(as.matrix(zy[8, ]))
# plot
par(mfrow = c(8,1))
plot(T1)
plot(T2)
plot(T3)
plot(T4)
plot(T5)
plot(T6)
plot(T7)
plot(T8)
par(mfrow = c(1,1))

## T1
# arima model
library(astsa)
# ma(1)
plot(T1,type = "o")
acf2(T1)
T1.pred <- sarima.for(T1, 24, 0, 0, 1)

## T2
# arima(1,1,0)
plot(T2,type = "o")
acf2(T2)
T2.d <- diff(T2)
acf2(T2.d)
T2.pred <- sarima.for(T2, 24, 1, 1, 0)

## T3
# hmm
plot(T3,type = "o")
library(depmixS4)
hmm.T3 <-
  depmix(T3 ~ 1,
         nstates = 2,
         data = data.frame(T3),
         family = gaussian())
set.seed(574846)
summary(fm <- fit(hmm.T3))

plot(
  T3,
  main = "",
  ylab = 'T3',
  type = 'h',
  col = gray(.7)
)
text(
  T3,
  col = 6 * posterior(fm)[, 1] - 2,
  labels = posterior(fm)[, 1],
  cex = .9
)
# parameters
para = as.vector(getpars(fm))
mtrans = matrix(para[3:6], byrow = TRUE, nrow = 2)
mu = para[c(7, 9)]
sigma = para[c(8, 10)]
generate.sample = function(n, m, mu, sigma, Mtrans, ostate)
{
  # n  length
  # m  # of states
  # Mtrans  transition matrix
  # ostate  origin state
  mvect = 1:m
  state = numeric(n)
  state[1] = ostate
  for (i in 2:n)
    state[i] = sample(mvect , 1, prob = Mtrans[state[i - 1] ,])
  y = rnorm(n, mu[state], sigma[state])
  list(y = y, state = state)
}
set.seed(1234567)
T3.pred <- generate.sample(24, 2, mu, sigma, mtrans, 2)
T3.pred
plot(
  T3.pred$y,
  main = "",
  ylab = 'T3 prediction',
  type = 'h',
  col = gray(.7)
)
text(
  T3.pred$y,
  col = 6 * posterior(fm)[, 1] - 2,
  labels = T3.pred$state,
  cex = .9
)

## T4
# hmm
plot(T4,type = "o")
hmm.T4 <-
  depmix(T4 ~ 1,
         nstates = 2,
         data = data.frame(T4),
         family = gaussian())
set.seed(574846)
summary(fm <- fit(hmm.T4))

plot(
  T4,
  main = "",
  ylab = 'T4',
  type = 'h',
  col = gray(.7)
)
text(
  T4,
  col = 6 * posterior(fm)[, 1] - 2,
  labels = posterior(fm)[, 1],
  cex = .9
)

# parameters
para = as.vector(getpars(fm))
mtrans = matrix(para[3:6], byrow = TRUE, nrow = 2)
mu = para[c(7, 9)]
sigma = para[c(8, 10)]
# prediction
set.seed(684586844)
T4.pred <- generate.sample(24, 2, mu, sigma, mtrans, 2)
T4.pred

## T5
# seems no pattern
plot(T5)
T5.narm <- na.exclude(T5)
plot(density(T5.narm),main = 'density of T5')
# exponential distribution
mu <- mean(T5, na.rm = T)
sigma <- var(T5, na.rm = T)
lam <- 1 / mu
x <- seq(0,5,length.out = 100)
lines(x,dexp(x,rate=lam),col = 2)
# prediction
T5.pred <- rexp(24, lam)

## T6
# ar(1)
plot(T6,type = "o")
acf2(T6)
T6.pred <- sarima.for(T6, 24, 1, 0, 0)

## T7
# arima(1,1,0)
plot(T7,type = "o")
acf2(T7)
T7.d <- diff(T7)
acf2(T7.d)
T7.pred <- sarima.for(T7, 24, 1, 1, 0)

## T8
# arima(1,1,0)
plot(T8,type = "o")
acf2(T8)
T8.d <- diff(T8)
acf2(T8.d)
T8.pred <- sarima.for(T8, 24, 1, 1, 0)

zy.pred <- rbind(
  T1.pred$pred,
  T2.pred$pred,
  T3.pred$y,
  T4.pred$y,
  T5.pred,
  T6.pred$pred,
  T7.pred$pred,
  T8.pred$pred
)
row.names(zy.pred) <- c('T1', 'T2', 'T3', 'T4',
                        'T5', 'T6', 'T7', 'T8')
colnames(zy.pred) <- 1:24

write.csv(zy.pred,
            'zy_pred.csv')
