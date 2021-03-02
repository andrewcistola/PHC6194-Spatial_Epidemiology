library(spdep)
library(rgdal)
library(maptools)
library(RColorBrewer)
library(DCluster)
library(sp)
library(gstat)
library(tigris)
library(dismo)

setwd("/home/vmuser/Desktop/PHC6194SPR2021/WK7")

#1. Smoothing

#load the data: sudden infant deaths in NC for 1974-1978 and 1979-1984
nc.sidsshp<-readOGR(dsn="/home/vmuser/R/x86_64-pc-linux-gnu-library/3.6/spData/shapes/sids.shp",encoding="ESRI Shapefile")

#check the SRID
proj4string(nc.sidsshp)

#Define projection
proj4string(nc.sidsshp)<-CRS("+init=epsg:4326")

#Transform projection to EPSG26917 (UTM 17 N)
nc.sidsshp<-spTransform(nc.sidsshp,CRS("+init=epsg:26917"))

head(nc.sidsshp@data)
nc.sids<-nc.sidsshp@data

#1.1 Raw Rates

#calculate raw SID rate across the state
r74<-sum(nc.sids$SID74)/sum(nc.sids$BIR74)
r79<-sum(nc.sids$SID79)/sum(nc.sids$BIR79)

#calculate expected number of SID cases
nc.sids$EXP74<-r74*nc.sids$BIR74
nc.sids$EXP79<-r79*nc.sids$BIR79

#calculate the standardized mortality ratios (SMR)
nc.sids$SMR74<-nc.sids$SID74/nc.sids$EXP74
nc.sids$SMR79<-nc.sids$SID79/nc.sids$EXP79

head(nc.sids)
nc.sidsshp@data<-nc.sids

#create a map of SMR
spplot(nc.sidsshp,c("SMR74","SMR79"),at=c(0,.5,.75,.9,1.1,1.25,1.5,4.8),col.regions=brewer.pal(7,"Blues"))

#1.2 Probability Map

#Calculate probablity assuming a Poisson distribution
nc.sids$PPOIS74<-ppois(nc.sids$SID74,nc.sids$EXP74,lower.tail=T) #lower.tail if T, probabilities are P[y>=Y] (observed>=expected)
nc.sids$PPOIS79<-ppois(nc.sids$SID79,nc.sids$EXP79,lower.tail=T) 
nc.sidsshp@data<-nc.sids

#create a probability map
spplot(nc.sidsshp,c("PPOIS74","PPOIS79"),at=c(0,.05,.1,.25,.5,.75,.9,.95,1),col.regions=brewer.pal(8,"Blues"))

#1.3 Define Neighbors
#1.3.1 Contiguity based neighbors
#Queen
sids_nbq<-poly2nb(nc.sidsshp)
#Rook
sids_nbr<-poly2nb(nc.sidsshp,queen = F)

#Let's plot the neighbors
coords<-coordinates(nc.sidsshp)
plot(nc.sidsshp)
plot(sids_nbq,coords,add=T)

plot(nc.sidsshp)
plot(sids_nbr,coords,add=T)

#1.3.2 Distance based neighbors: KNN
coords<-coordinates(nc.sidsshp)
IDs<-row.names(nc.sidsshp@data)

sids_kn1<-knn2nb(knearneigh(coords,k=1),row.names=IDs)
sids_kn2<-knn2nb(knearneigh(coords,k=2),row.names=IDs)
sids_kn4<-knn2nb(knearneigh(coords,k=4),row.names=IDs)

plot(nc.sidsshp)
plot(sids_kn1,coords,add=T)

plot(nc.sidsshp)
plot(sids_kn2,coords,add=T)

plot(nc.sidsshp)
plot(sids_kn4,coords,add=T)

#1.3.3 Distance based neighbors: specified distance
sids_kd1<-dnearneigh(coords,d1=0,d2=30000,row.names = IDs)
sids_kd2<-dnearneigh(coords,d1=0,d2=40000,row.names = IDs)
sids_kd3<-dnearneigh(coords,d1=0,d2=50000,row.names = IDs)

plot(nc.sidsshp)
plot(sids_kd1,coords,add=T)

plot(nc.sidsshp)
plot(sids_kd2,coords,add=T)

plot(nc.sidsshp)
plot(sids_kd3,coords,add=T)

#1.4 Generate Weight Matrix
#1.4.1 Binary weights
sids_kn4_wb<-nb2listw(sids_kn4,style = "B")

#1.4.2 Row-standardized weights
sids_kd2_w<-nb2listw(sids_kd2,zero.policy = T)

#1.5 Empirical Bayes smoothing
#1.5.1 Global Empirical Bayes Smoothing

#method of moments (implemented in spdep)
eb1<-EBest(nc.sids$SID74,nc.sids$BIR74)
nc.sids$EB_mm74<-eb1$estmm
eb1<-EBest(nc.sids$SID79,nc.sids$BIR79)
nc.sids$EB_mm79<-eb1$estmm

#maximum likelihood approach (implemented in DCluster)
eb2<-empbaysmooth(nc.sids$SID74,nc.sids$BIR74)
nc.sids$EB_ml74<-eb2$smthrr
eb2<-empbaysmooth(nc.sids$SID79,nc.sids$BIR79)
nc.sids$EB_ml79<-eb2$smthrr

#raw rates
nc.sids$RR74<-nc.sids$SID74/nc.sids$BIR74
nc.sids$RR79<-nc.sids$SID79/nc.sids$BIR79

nc.sidsshp@data<-nc.sids
spplot(nc.sidsshp,c("EB_mm74","EB_ml74","RR74"),at=c(0,.001,.002,.003,.004,.005,.006,.007,.008,.01),col.regions=brewer.pal(9,"Blues"))

#1.5.2 Local Empirical Bayes Smoothing
eb3<-EBlocal(nc.sids$SID74,nc.sids$BIR74,sids_kn4) #need the neighbor definition
nc.sids$EB_mm_local74<-eb3$est

nc.sidsshp@data<-nc.sids
spplot(nc.sidsshp,c("EB_mm_local74","EB_mm74","EB_ml74","RR74"),at=c(0,.001,.002,.003,.004,.005,.006,.007,.008,.01),col.regions=brewer.pal(9,"Blues"))

#2. Interpolation

#import the data: precipitation data for California
dat<-read.csv("data/precipitation.csv",stringsAsFactors = F)
head(dat)

#convert it to a SpatialPointsDataFrame
dat_geom<-SpatialPoints(coords=dat[,c("LONG","LAT")])
dat<-SpatialPointsDataFrame(dat_geom,data=dat)
proj4string(dat)<-CRS("+init=epsg:4326")

#transform projection to Teale Albers
TA <- CRS("+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +datum=NAD83 +units=m +ellps=GRS80 +towgs84=0,0,0")
dat<-spTransform(dat,TA)

#map
bubble(dat,"JAN",col=c("#00ff0088","#00ff0088"),main="January Precipitation")

#2.1 Variograms
jan.vgm<-variogram(JAN~1,dat) #assume a constant trend for the varaible log(JAN)
jan.vgm
?variogram
plot(jan.vgm)

jan.fit.sph<-fit.variogram(jan.vgm,model=vgm("Sph")) #spherical
jan.fit.sph
plot(jan.vgm,jan.fit.sph)

jan.fit.exp<-fit.variogram(jan.vgm,model=vgm("Exp")) #exponential
jan.fit.exp
plot(jan.vgm,jan.fit.exp)

#2.2 Proximity Interpolation
#download CA counties boundaries, and transform projection to TA
ca<-counties(state='06')
proj4string(ca)
ca<-spTransform(ca,TA)

#aggregate all counties
caAggregate<-aggregate(ca)
plot(caAggregate)

#create Thiessen polygons
v<-voronoi(dat)
plot(v)
vca<-intersect(v,ca)

#map
spplot(vca,'JAN',col.regions=rev(get_col_regions()))

#convert to raster
caRaster<-raster(ca,res=10000)
vcaRaster<-rasterize(vca,caRaster,'JAN')
plot(vcaRaster)

#evaluate performance with 5-fold cross validations
RMSE<-function(observed,predicted){
  sqrt(mean((predicted-observed)^2,na.rm=TRUE))
}

set.seed(1)
kf <- kfold(nrow(dat),k = 5)

rmse <- rep(NA, 5)
for (k in 1:5) {
  test <- dat[kf == k, ]
  train <- dat[kf != k, ]
  v <- voronoi(train)
  p <- extract(v, test)
  rmse[k] <- RMSE(test$JAN, p$JAN)
}

rmse
mean(rmse) #38.15054

#2.3 Nearest Neighbor Interpolation (with 5 neighbors)

gs<-gstat(formula=JAN~1,locations=dat,nmax=5,set=list(idp=0)) #idp: inverse distance power, when set to 0, all neighbors are equally weighted
nn<-interpolate(caRaster,gs)
nnmsk<-mask(nn,vcaRaster)
plot(nnmsk)

rmsenn <- rep(NA, 5)
for (k in 1:5) {
  test <- dat[kf == k, ]
  train <- dat[kf != k, ]
  gscv <- gstat(formula=JAN~1, locations=train, nmax=5, set=list(idp = 0))
  p <- predict(gscv, test)$var1.pred
  rmsenn[k] <- RMSE(test$JAN, p)
}
rmsenn
mean(rmsenn) #38.0081


#2.4 Inverse Distance Interpolation
gs<-gstat(formula=JAN~1,locations=dat)  #default value of nmax is Inf (all the other points will be used as neighbors)
idw<-interpolate(caRaster,gs)
idwr<-mask(idw,vcaRaster)
plot(idwr)

rmseidw <- rep(NA, 5)
for (k in 1:5) {
  test <- dat[kf == k, ]
  train <- dat[kf != k, ]
  gs <- gstat(formula=JAN~1, locations=train)
  p <- predict(gs, test)
  rmseidw[k] <- RMSE(test$JAN, p$var1.pred)
}
rmseidw
mean(rmseidw) #40.64746

#2.4 Ordinary Kriging Interpolation
caGrid<-as(caRaster,'SpatialGrid')

k<-gstat(formula=JAN~1,locations=dat,model=jan.fit.exp)
kp<-predict(k,caGrid)
spplot(kp)

ok<-brick(kp)
ok<-mask(ok,vcaRaster)
names(ok)<-c('prediction','variance')
plot(ok)

rmseok <- rep(NA, 5)
for (k in 1:5) {
  test <- dat[kf == k, ]
  train <- dat[kf != k, ]
  gs <- gstat(formula=JAN~1, locations=train,model=jan.fit.exp)
  p <- predict(gs, test)
  rmseok[k] <- RMSE(test$JAN, p$var1.pred)
}
rmseok
mean(rmseok) #29.28388