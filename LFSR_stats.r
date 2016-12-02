nSims <- 5000 #number of simulated experiments
max_val <-numeric(nSims) #set up empty container for all simulated max values
min_val <-numeric(nSims) #set up empty container for all simulated min values
mean_val <-numeric(nSims) #set up empty container for all simulated mean values
values = read.table("data.txt")

for(i in 1:nSims){ #for each simulated experiment
  x<-runif(n = 2000, min = 1, max = 63) 
  y<-values[[i]]
  
 max_val[i]<-max(y)
 min_val[i]<-min(y)
 mean_val[i]<-mean(y)
}
 
#now plot the histogram
hist(p, main="Histogram of p-values compared to uniform distribution", xlab=("Observed p-value"))
hist(max_val, main="Histogram of max values from LFSR", xlab=("Max value"),breaks = c(60,61,62,63,64,65,66,67,68))
hist(min_val, main="Histogram of min values from LFSR", xlab=("Min value"),breaks = c(-1,0,1,2,3,4))
hist(mean_val, main="Histogram of mean values from LFSR", xlab=("Mean value"),breaks = c(31,31.5,32,32.5,33,33.5))

t.test(mean_val, mu=32);