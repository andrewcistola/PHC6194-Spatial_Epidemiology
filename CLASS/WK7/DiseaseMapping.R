library(spdep)
library(rgdal)
library(maptools)
library(RColorBrewer)
library(DCluster)
library(sp)
library(gstat)
library(tigris)
library(dismo)

setwd(paste(directory, 'WK7', sep = ''))



# 2. Interpolation

## Create CA Precipitation Bubble Map
dat = read.csv("data/precipitation.csv", stringsAsFactors = F) ## import the data: precipitation data for California
dat_geom = SpatialPoints(coords = dat[,c("LONG", "LAT")]) ## convert it to a SpatialPointsDataFrame
dat = SpatialPointsDataFrame(dat_geom, data = dat)
proj4string(dat) = CRS("+init=epsg:4326")
TA = CRS("+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +datum=NAD83 +units=m +ellps=GRS80 +towgs84=0,0,0")
dat = spTransform(dat, TA) #transform projection to Teale Albers
qp = bubble(dat, "JAN",col = c("#00ff0088", "#00ff0088"), main = "January Precipitation")# bubble map

## 2.1 Variograms
jan.vgm = variogram(JAN~1, dat) # assume a constant trend for the varaible log(JAN)
qp = plot(vgm) # plot constant
jan.fit.sph = fit.variogram(jan.vgm, model = vgm('Sph')) # spherical
qp = plot(jan.vgm,jan.fit.sph) # plot constant v spherical
jan.fit.exp = fit.variogram(jan.vgm, model = vgm('Exp')) #exponential
qp = plot(jan.vgm, jan.fit.exp) # plot constant v exponential

# 3-12-2021 DC! https://github.com/earthlab/cft/issues/127

#2.2 Proximity Interpolation
ca = counties(state = '06') # download CA counties boundaries 
ca = as(ca, "Spatial") # Covert sf object to spatial df
proj4string(ca) <- CRS("+init=epsg:4326")  # Reset projection
ca = spTransform(ca, TA) # transform projection to TA
caAggregate = aggregate(ca) # aggregate all counties
qp = plot(caAggregate) # Plot aggregate

# In proj4string(xy) : CRS object has comment, which is lost in output

# create Thiessen polygons
v<-voronoi(dat)
qp = plot(v)
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