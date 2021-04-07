library(GWmodel)
library(ggplot2)
library(rgeos)
library(maptools)
library(boot)
library(plyr)

#Part 1. Traditional regression model
#Load London house price data (from a sampe of houses sold in 2001)
data(LondonHP)

#Check variables
head(londonhp@data) #PURCHASE: purchase price, FLOORSZ: floor area

#Calculate price per square meter of floor area
londonhp$PPSQM<-londonhp$PURCHASE/londonhp$FLOORSZ

#Check the distribution of it
hist(londonhp$PPSQM)
mean(londonhp$PPSQM)
sd(londonhp$PPSQM)

#Start with a taditional model to assess the associations between price per square meter and professional employment proportion
linmod<-lm(PPSQM~PROF,data=londonhp)

#Check the model fit
summary(linmod)
plot(PPSQM~PROF,data=londonhp)
abline(linmod)

#Check whether the association is the same everywhere in the London area
londonhp$x<-londonhp@coords[,1]
londonhp$y<-londonhp@coords[,2]

panel.lm<-function(x,y,...) {
  points(x,y,pch=16)
  abline(lm(y~x))
}
coplot(PPSQM~PROF|x*y,data=londonhp@data,panel=panel.lm,overlap=0.8)

#Alternatively, we can also check if there is any obvious spatial patterning in the residuals
resids<-residuals(linmod)
colours<-c("dark blue","blue","red","dark red")
map.resids<-SpatialPointsDataFrame(data=data.frame(resids),coords=londonhp@coords)
spplot(map.resids,cuts=quantile(resids),col.regions=colours,cex=1,add=T)


#Part 2. GWR
#2.1 fit GWR to point locations
#Now let's fit a GWR model
data(LondonBorough)
plot(londonborough)
plot(londonhp,pch=16,col="dark red",add=T)

#let's first define the distance measure
DM1<-gw.dist(dp.locat = coordinates(londonhp))

#we can now search for the optimal bandwidth using CV
gwrbw<-bw.gwr(PPSQM~PROF,data=londonhp,approach = "CV", kernel="gaussian",adaptive = F,longlat=F,dMat = DM1)

#now fit the model using the optimal bw
gwr.model1<-gwr.basic(PPSQM~PROF,data=londonhp,bw=gwrbw,dMat=DM1,kernel='gaussian')

#check model fit and results
gwr.model1
head(gwr.model1$SDF@data)

#visualize the results
londonhp$coefPROF<-gwr.model1$SDF$PROF
boroughoutline<-fortify(londonborough,region="NAME")
ggplot(londonhp@data,aes(x=x,y=y))+geom_point(aes(colour=londonhp$coefPROF))+scale_color_gradient2(low="red",mid="white",high="blue",midpoint=0,space="rgb",na.value="gray50",guide="colorbar",guide_legend(title="Coef"))+geom_path(data=boroughoutline,aes(long,lat,group=id),color="gray")+coord_equal()

#2.2 fit GWR to a grid
#We can also calibrate the GWR odel over a regular grid of observations (1000*1000)
bb<-londonborough@bbox
cs<-c(1000,1000)
cc<-bb[,1]+(cs/2)
cd<-ceiling(diff(t(bb))/cs)
grd<-SpatialGrid(GridTopology(cellcentre.offset = cc,cellsize = cs,cells.dim=cd))

plot(grd)
plot(londonborough,add=T,col=adjustcolor('blue',alpha.f = 0.3))
plot(londonhp,pch=16,col="dark red",add=T)

#We can now compute the distances between the points on the grid
DM2<-gw.dist(dp.locat = coordinates(londonhp),rp.locat = coordinates(grd))

#now we can run the GWR
gwr.model2<-gwr.basic(PPSQM~PROF,data=londonhp,regression.points=grd,bw=gwrbw,dMat=DM2,kernel='gaussian')
gwr.model2

#use bootstrap to get the standard errors
set.seed(4676)
gwrcoef<-function(hpdf,i){
  gwr.basic(PPSQM~PROF,data=hpdf[i,],regression.points=grd,bw=gwrbw,dMat=DM2[i,],kernel='gaussian')$SDF$PROF
}
bootres<-boot(londonhp,gwrcoef,100)
gwr.model2$SDF$sePROF<-apply(bootres$t,2,sd)
head(gwr.model2$SDF@data)

#get the estimated coefficients of PROF
image(gwr.model2$SDF,'PROF')
plot(londonborough,add=T)
plot(londonhp,add=T,pch=16,col='gray')

plot(londonborough,border='lightgray')
contour(gwr.model2$SDF,'PROF',lwd=3,add=T)
plot(londonhp,add=T,pch=16,col=adjustcolor('red',alpha.f = 0.3))

#2.3 fit GWR to polygons
#get the centroid points of polygons
centroidborough<-gCentroid(londonborough,byid = T,id=londonborough$NAME)

#We can now compute the distances between the centroid points of polygons
DM3<-gw.dist(dp.locat = coordinates(londonhp),rp.locat = coordinates(centroidborough))

#now we can run the GWR
gwr.model3<-gwr.basic(PPSQM~PROF,data=londonhp,regression.points=centroidborough,bw=gwrbw,dMat=DM3,kernel='gaussian')
gwr.model3

#get the estimated coefficients of PROF
londonborough$coefPROF<-gwr.model3$SDF$PROF

#Map
londonborough_f<-fortify(londonborough,region="NAME")
londonborough_data<-londonborough@data

londonborough_data$id<-londonborough$NAME
londonborough_f<-join(londonborough_f,londonborough_data,by="id")
londonborough_f$x<-londonborough_f$long
londonborough_f$y<-londonborough_f$lat

#now let's create a map using ggplot2
ggplot()+geom_polygon(data=londonborough_f,aes(long,lat,group=group,fill=coefPROF))+geom_path(color="white")+coord_equal()+theme(panel.background=element_blank(),axis.title=element_blank(),axis.text=element_blank(),axis.ticks = element_blank())+scale_fill_gradient2(low="red",mid="white",high="blue",midpoint=0,space="rgb",na.value="gray50",guide="colorbar",guide_legend(title="Coef"))

#Part 3. Generalized GWR

#create binary variables
londonhp$HIGHP<-as.numeric(londonhp$PPSQM>median(londonhp$PPSQM))
londonhp$HIGHPROF<-as.numeric(londonhp$PROF>median(londonhp$PROF))
head(londonhp@data)

#fit a logistic GWR
#let's first define the distance measure
DM4<-gw.dist(dp.locat = coordinates(londonhp))

#we can now search for the optimal N using CV
gwrn<-bw.ggwr(HIGHP~HIGHPROF,data=londonhp,family="binomial",approach = "CV", kernel="gaussian",adaptive = T,longlat=F,dMat = DM1)

#now fit the model using the optimal n
gwr.model4<-ggwr.basic(HIGHP~HIGHPROF,data=londonhp,family="binomial",bw=gwrn,dMat=DM4,kernel='gaussian',adaptive = T)

#check model fit and results
gwr.model4
head(gwr.model4$SDF@data)

#visualize the results
londonhp$orHIGHPROF<-exp(gwr.model4$SDF$HIGHPROF)
boroughoutline<-fortify(londonborough,region="NAME")
ggplot(londonhp@data,aes(x=x,y=y))+geom_point(aes(colour=londonhp$orHIGHPROF))+scale_color_gradient2(low="red",mid="white",high="blue",midpoint=1,space="rgb",na.value="gray50",guide="colorbar",guide_legend(title="OR"))+geom_path(data=boroughoutline,aes(long,lat,group=id),color="gray")+coord_equal()

