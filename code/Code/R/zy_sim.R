# data
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
  zyi <- zy[i,]
  zy[i, is.na(zyi)] <- zy.mean[i]
}

# data frame to vector
T1 <- as.vector(as.matrix(zy[1,]))
T2 <- as.vector(as.matrix(zy[2,]))
T3 <- as.vector(as.matrix(zy[3,]))
T4 <- as.vector(as.matrix(zy[4,]))
T5 <- as.vector(as.matrix(zy[5,]))
T6 <- as.vector(as.matrix(zy[6,]))
T7 <- as.vector(as.matrix(zy[7,]))
T8 <- as.vector(as.matrix(zy[8,]))

# simulation
library(depmixS4)
# T3
hmm.T3 <-
  depmix(T3 ~ 1,
         nstates = 2,
         data = data.frame(T3),
         family = gaussian())
fm <- fit(hmm.T3)
para3 = as.vector(getpars(fm))
mtrans3 = matrix(para3[3:6], byrow = TRUE, nrow = 2)
mu3 = para3[c(7, 9)]
sigma3 = para3[c(8, 10)]

# T4
hmm.T4 <-
  depmix(T4 ~ 1,
         nstates = 2,
         data = data.frame(T4),
         family = gaussian())
fm <- fit(hmm.T4)
para4 = as.vector(getpars(fm))
mtrans4 = matrix(para4[3:6], byrow = TRUE, nrow = 2)
mu4 = para4[c(7, 9)]
sigma4 = para4[c(8, 10)]


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
    state[i] = sample(mvect , 1, prob = Mtrans[state[i - 1] , ])
  y = rnorm(n, mu[state], sigma[state])
  list(y = y, state = state)
}

mu <- mean(T5, na.rm = T)
lam <- 1 / mu
for (i in 1:10000) {
  T3.pred <- generate.sample(24, 2, mu3, sigma3, mtrans3, 2)
  T4.pred <- generate.sample(24, 2, mu4, sigma4, mtrans4, 2)
  T5.pred <- rexp(24, lam)
  zy.pred <- rbind(
    T1.pred$pred,
    T2.pred$pred,
    abs(T3.pred$y),
    abs(T4.pred$y),
    T5.pred,
    T6.pred$pred,
    T7.pred$pred,
    T8.pred$pred
  )
  row.names(zy.pred) <- c('T1', 'T2', 'T3', 'T4',
                          'T5', 'T6', 'T7', 'T8')
  colnames(zy.pred) <- 1:24
  
  write.table(zy.pred,
            'zy_simulation.txt',
            sep = ',',
            col.names = F,
            append = T)
}
