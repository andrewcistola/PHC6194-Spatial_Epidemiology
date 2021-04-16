library('rjags')
setwd('/home/vmuser/Desktop/PHC6194SPR2021/WK11') 

dfsbp<-read.csv("dat/sbp.csv",header=T)

#prepare the data to import into JAGS
y<-dfsbp$sbp
x<-dfsbp$bmi
id<-dfsbp$id
N<-nrow(dfsbp) #the total number of measurements
K<-length(unique(id)) #the total number of groups

#count the number of measurements for each group
dfsbp$count=1
nk<-aggregate(count~id,data=dfsbp,sum)$count

#sets up model object
jags<-jags.model('JAGS.bug',data=list('y'=y,'x'=x,'N'=N,'K'=K,'id'=id),n.chains=4,n.adapt=100)
#burn-in period
update(jags,10000)
#draw 1,0000 samples from the sampler
k<-jags.samples(jags,c('gamma','b','precy','preca','a'),10000)

#A function to plot the posterior distribution of the parameter of interest
inference=function(num,nome){
  k1=k[[num]][]
  plot(NA,NA,xlim=c(0,10000),ylim=range(k1))
  for (i in 1:4) lines(1:10000,k[[num]][1,,i],col=i)
  k2=density(k1)
  plot(k2,type='l',xlab='',main=nome)
  z=quantile(k1,c(0.025,0.975))
  abline(v=z,col='red',lty=3)
  print(c(mean(k1),z))
}
#inference on the parameters of interest
par(mfrow=c(2,2))
inference(3,'gamma')
inference(2,'b')
par(mfrow=c(1,1))

par(mfrow=c(2,2))
inference(5,'precy')
inference(4,'preca')
par(mfrow=c(1,1))

#intercept for the 51st group
mean(k$a[51,,])
quantile(k$a[51,,],c(0.025,0.975))
