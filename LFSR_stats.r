nSims <- 5000 #number of simulated experiments
max_val <-numeric(nSims) #set up empty container for all simulated max values
min_val <-numeric(nSims) #set up empty container for all simulated min values
mean_val <-numeric(nSims) #set up empty container for all simulated mean values
values = read.table("data.txt")

for(i in 1:nSims){ #for each simulated experiment
  y<-values[[i]]
  
  max_val[i]<-max(y)
  min_val[i]<-min(y)
  mean_val[i]<-mean(y)
}
 
#now plot the histogram
hist(max_val, main="Histogram of max values from LFSR", xlab=("Max value"),breaks = c(60,61,62,63,64,65,66))
hist(min_val, main="Histogram of min values from LFSR", xlab=("Min value"),breaks = c(-1,0,1,2,3,4))
hist(mean_val, main="Histogram of mean values from LFSR", xlab=("Mean value"),
     breaks = c(31.90,31.91,31.92,31.93,31.94,31.95,31.96,31.97,31.98,31.99,
                32.00,32.01,32.02,32.03,32.04,32.05,32.06,32.07,32.08,32.09,
                32.10))

t.test(mean_val, mu=32)
