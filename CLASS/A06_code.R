#Assignment 6
#Andrew Cistola

#Q0. Load packages "maptools", "spdep", "rgdal", "plyr", "INLA", and "ggplot2", and set "WK12" folder as the working directory (0 pt)
library(maptools) # Geographic weighted regression in R
library(rgdal)
library(spdep)  
install.packages('INLA')
library(INLA)
library(ggplot2) # General use plotting library from Hadley Wickham
library(plyr) # Data manipulation from Hadley Wickham 
setwd(paste(directory, 'WK12', sep = ''))

#Q1. Load the cleaned 2004 US election data "elect.Rda" in "data" folder using the load() function. (5 pts)
load('data/elect.Rda')

#Q2. Keep only the election divisions in Florida (GEOID=12), and save it as "FLelect2004". (10 pts)
FLelect2004 = USelect2004[(USelect2004$GEOID == 12), ]

#Q3 create a new ID variable "ID" for "FLelect2004" ranges from 1 to 67. (5 pts)
FLelect2004$ID <- 1:nrow(FLelect2004)

#Q4. Create an Queen adjacency graph, export the graph as "flelect.graph" in the "data" folder, and save the path to the graph file in "uselect.adj". (15 pts)
temp <- poly2nb(FLelect2004)
nb2INLA('flelect.graph', temp)
flelect.adj <- paste(getwd(), '/flelect.graph', sep = '')
data = flelect@data

#Q5. Start with a "BYM" model with "bush" as the outcome, an intercept term, a spatially structured and a spatially unstrctured terms, and no covariates. Save the results of the model as "mod1". (Hint: family="binomial"). (15 pts)
mod1 <- inla(bush ~ 1 + f(ID, model = "bym", graph = flelect.adj), family = "binomial", data = data,E=E)

#Q6. Obtain the marginal of spatially unstructured residual nu, save it as "m1", then calculate OR=exp(nu), unlist it and save it as "or1". (10 pts)
Nareas = nrows(flelect)
mat.marg<-matrix(NA, nrow=Nareas ncol=1000)
m<-mod1$marginals.random$ID
for (i in 1:Nareas){
  u<-m[[Nareas+i]]
  s<-inla.rmarginal(1000, u)  #inla.rmarginal: random generate 1000 observations from the posterior marginal
  mat.marg[i,]<-s}
var.RRspatial<-mean(apply(mat.marg, 2, sd))^2 #2 in the apply() function indicates columns
var.RRhet<-inla.emarginal(function(x) 1/x,mod1$marginals.hyper$"Precision for ID (iid component)")
or1 = exp(var.RRspatial/(var.RRspatial+var.RRhet))

#Q7. Calculate the probability that the spatial effects OR are above 1. This is equivalent to calculate the probability that nu is above 0, which is easier to obtain. Unlist the probability and save it as "inlaprob1". (10 pts)
a=0 #now calculate the probability that the spatial effects zeta are above 1, identifying areas with excess risk of suicides. This is equivalent to calculate the probability that csi is above 0, which is easier to obtain
inlaprob<-lapply(mod1$marginals.random$ID[1:Nareas], function(X){
  1-inla.pmarginal(a, X)  
})
inlaprob1 = unlist(inlaprob)

#Q8. Map the probability calculated in Q7. (10 pts)
trellis.par.set(axis.line=list(col=NA))
spplot(obj=flelect, zcol= inlaprob1, col.regions=gray(3.5:0.5/4),main="")

#Q9. Add the covariates "unemploy","pctcoled","PEROVER65","pcturban", and "WHITE" to the model, and save the model as "mod2". (10 pts)
mod2 <- inla(bush ~ 1+ f(ID, model="bym", graph=flelect.adj) + unemploy + pctcoled + PEROVER65 + pcturban + WHITE,family="binomial",data=data,E=E)

#Q10. Obtain the OR for each 10% increase in "WHITE" and its 95% CI. (10 pts)
exp(fixef(mod2)[7] + c(-1.96,1,1.96) * se.fixef(mod2)[7]) # 95% CIs
