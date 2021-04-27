#Adpated from http://www.r-inla.org/examples/case-studies/blangiardo-et-al-2012 
library(maptools)
library(spdep)
library(rgdal)
library(INLA)
library(lattice)

#set wd
setwd("/home/vmuser/Desktop/PHC6194SPR2021/WK12")

#Spatial areal data: london suicides
london.gen<-readOGR(dsn="data/LDNSuicides.shp",encoding="ESRI Shapefile")

#the data
#y: observed number of suicides
y<-c(75,145,99,168,152,173,152,169,130,117,124,119,134,90,98,89,128,145,130,69,246,166,95,135,98,97,202,75,100,100,153,194)
#E: expected number of suicides
E<-c(80.7,169.8,123.2,139.5,169.1,107.2,179.8,160.4,147.5,116.8,102.8,91.8,119.6,114.8,131.1,136.1,116.6,98.5,88.8,79.8,144.9,134.7,98.9,118.6,130.6,96.1,127.1,97.7,88.5,121.4,156.8,114)
#x1: deprviation
x1<-c(0.87,-0.96,-0.84,0.13,-1.19,0.35,-0.84,-0.18,-0.39,0.74,1.93,0.24,0.59,-1.15,-0.8,-0.59,-0.12,1.43,-0.04,-1.24,1,0.53,-0.75,1.36,-0.93,-1.24,1.68,-1.04,2.38,0.03,-0.2,0.14)
#x2: social fragmentation
x2<-c(-1.02,-0.33,-1.43,-0.1,-0.98,1.77,-0.73,-0.2,-0.96,-0.58,0.36,1.48,0.46,-0.93,-1.62,-0.96,-0.48,0.81,2.41,-0.4,0.71,-0.05,-0.33,-0.47,-0.92,0.06,0.22,-0.73,0.1,-0.59,0.7,2.28)

names<- sort(london.gen$NAME)
data <- data.frame(NAME=names, y=y, E=E, x1=x1, x2=x2)
Nareas <- length(data[,1])

#Create the adjacency graph
temp <- poly2nb(london.gen)
nb2INLA("LDN.graph", temp)
LDN.adj <- paste(getwd(),"/LDN.graph",sep="")

#reorder the data to make sure its order is the same as the order of areas in the polygon
boroughs<-london.gen
data.boroughs<-attr(boroughs, "data")
order <- match(data.boroughs$NAME,data$NAME)
data <- data[order,]
ID<-seq(1,32)
data <- cbind(ID,data)

#start with a BYM model with no covariates
mod <- inla(y~1+f(ID, model="bym", graph=LDN.adj),family="poisson",data=data,E=E)
#equivalent to:
#data$ID2<-data$ID
#mod <- inla(y~1+f(ID, model="besag", graph=LDN.adj)+f(ID2, model="iid", graph=LDN.adj),family="poisson",data=data,E=E)

#specify different priors (by default, prior for precision is Gamma(1,0.0005))
mod2<-inla(y~1+f(ID, model="bym", graph=LDN.adj,hyper = list(prec.unstruct=list(prior="loggamma",param=c(1,0.01)),prec.spatial=list(prior="loggamma",param=c(1,0.001)))),family="poisson",data=data,E=E)

#get the "fixed" effects (intercept in this case)
mod$summary.fixed

#get the "random" effects 
mod$summary.random #the first 32 rows include information on the spatially unstructured residual upsilon (the primary interest in a disease mapping study), and the last 32 rows include information on the spatially structured residual nu only

#calculate zeta=exp(upsilon)
m <- mod$marginals.random$ID[1:Nareas]  #the posterior marginal for the spatially unstructured term, with density values y at locations x
zeta <- lapply(m,function(x) {inla.emarginal(exp,x)})  #inla.emarginal: a function that computes the expected values of a marginal

#now calculate the probability that the spatial effects zeta are above 1, identifying areas with excess risk of suicides. This is equivalent to calculate the probability that csi is above 0, which is easier to obtain
a=0
inlaprob<-lapply(mod$marginals.random$ID[1:Nareas], function(X){
  1-inla.pmarginal(a, X)  
})

#obtain the proportion of variance explained by the spatially structured component nu, taking the structured effect nu and calculating the empirical variance 
#create a matrix with rows equal to the number of areas and 1000 columns. Then for each area we extract 1000 values from the corresponding marginal distribution of nu and finally we calculate the empirical variance. We also extract the expected value of the variance for the unstructured component and build the spatial fractional variance
mat.marg<-matrix(NA, nrow=Nareas, ncol=1000)
m<-mod$marginals.random$ID
for (i in 1:Nareas){
  u<-m[[Nareas+i]]
  s<-inla.rmarginal(1000, u)  #inla.rmarginal: random generate 1000 observations from the posterior marginal
  mat.marg[i,]<-s}
var.RRspatial<-mean(apply(mat.marg, 2, sd))^2 #2 in the apply() function indicates columns
var.RRhet<-inla.emarginal(function(x) 1/x,mod$marginals.hyper$"Precision for ID (iid component)")
var.RRspatial/(var.RRspatial+var.RRhet)

#add the covariates (x1: deprivation, x2:social fragmentation) and repeat the steps
mod.cov <- inla(y ~ 1+ f(ID, model="bym", graph=LDN.adj) + x1 + x2,family="poisson",data=data,E=E)
mod.cov$summary.fixed
m <- mod.cov$marginals.random$ID[1:Nareas]
zeta.cov <- lapply(m,function(x)inla.emarginal(exp,x))
a=0
inlaprob.cov<-lapply(mod.cov$marginals.random$ID[1:Nareas], function(X){
  1-inla.pmarginal(a, X)
})
m<-mod.cov$marginals.random$ID
mat.marg<-matrix(NA, nrow=Nareas, ncol=1000)
for (i in 1:Nareas){
  u<-m[[Nareas+i]]
  s<-inla.rmarginal(1000, u)
  mat.marg[i,]<-s}
var.RRspatial<-mean(apply(mat.marg, 2, sd))^2
var.RRhet<-inla.emarginal(function(x) 1/x,mod.cov$marginals.hyper$"Precision for ID (iid component)")
var.RRspatial/(var.RRspatial+var.RRhet)

#Map
#First we create a dataset with all the relevant quantities and classes of SMR and posterior probabilities. Then transform the continuous SMR and posterior probabilities in factors, Merge the spatial polygon of London boroughs with the data and map the quantities.
Spatial.results<- data.frame(NAME=data$NAME,SMR=unlist(zeta),pp=unlist(inlaprob), SMR.cov = unlist(zeta.cov), pp.cov = unlist(inlaprob.cov))
SMR.cutoff<- c(0.6, 0.9, 1.0, 1.1,  1.8)
pp.cutoff <- c(0,0.2,0.8,1)

#Transform SMR and pp in factors
SMR.DM=cut(Spatial.results$SMR,breaks=SMR.cutoff,include.lowest=TRUE)
pp.DM=cut(Spatial.results$pp,breaks=pp.cutoff,include.lowest=TRUE)
SMR.COV=cut(Spatial.results$SMR.cov,breaks=SMR.cutoff,include.lowest=TRUE)
pp.COV=cut(Spatial.results$pp.cov,breaks=pp.cutoff,include.lowest=TRUE)
maps.SMR.factors <- data.frame(NAME=data$NAME,SMR.DM=SMR.DM,pp.DM=pp.DM,SMR.COV=SMR.COV,pp.COV=pp.COV)
attr(boroughs, "data")=merge(data.boroughs,maps.SMR.factors,by="NAME")
trellis.par.set(axis.line=list(col=NA))
spplot(obj=boroughs, zcol= "SMR.DM", col.regions=gray(3.5:0.5/4),main="")
trellis.par.set(axis.line=list(col=NA))
spplot(obj=boroughs, zcol= "pp.DM", col.regions=gray(2.5:0.5/3),main="")
trellis.par.set(axis.line=list(col=NA))
spplot(obj=boroughs, zcol= "SMR.COV", col.regions=gray(3.5:0.5/4))
trellis.par.set(axis.line=list(col=NA))
spplot(obj=boroughs, zcol= "pp.COV", col.regions=gray(2.5:0.5/3))
