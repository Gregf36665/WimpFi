nSims <- 5000 #number of simulated experiments
p <-numeric(nSims) #set up empty container for all simulated p-values
values = read.table("data.txt")

for(i in 1:nSims){ #for each simulated experiment
  x<-runif(n = 2000, min = 1, max = 63) 
  y<-values[[i]]
  
  
 z<-t.test(x,y) #perform the t-test
 p[i]<-z$p.value #get the p-value and store it
}
 
#now plot the histogram
#plot(x, y)
hist(p, main="Histogram of p-values compared to uniform distribution", xlab=("Observed p-value"))
