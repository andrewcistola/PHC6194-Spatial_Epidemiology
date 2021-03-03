# PHC6194
## Notes Script

# General
fldeath = read.csv("data/fldeath2016.txt", sep = '\t', stringsAsFactors = F) ## import tab delimited file


# Disease Mapping 

## 1. Smoothing
nc.sidsshp = readOGR(dsn = "/home/drewc/R/x86_64-pc-linux-gnu-library/3.6/spData/shapes/sids.shp", encoding = "ESRI Shapefile") # load the data: sudden infant deaths in NC for 1974-1978 and 1979-1984
proj4string(nc.sidsshp) # check the SRID
proj4string(nc.sidsshp) = CRS("+init = epsg:4326") # Define projection
nc.sidsshp = spTransform(nc.sidsshp,CRS("+init = epsg:26917")) # Transform projection to EPSG26917 (UTM 17 N)
head(nc.sidsshp@data)
nc.sids = nc.sidsshp@data

### 1.1 Raw Rates
r74<-sum(nc.sids$SID74)/sum(nc.sids$BIR74) #calculate raw SID rate across the state
r79<-sum(nc.sids$SID79)/sum(nc.sids$BIR79) #calculate raw SID rate across the state
nc.sids$EXP74<-r74*nc.sids$BIR74 #calculate expected number of SID cases
nc.sids$EXP79<-r79*nc.sids$BIR79 #calculate expected number of SID cases
nc.sids$SMR74<-nc.sids$SID74/nc.sids$EXP74 #calculate the standardized mortality ratios (SMR)
nc.sids$SMR79<-nc.sids$SID79/nc.sids$EXP79 #calculate the standardized mortality ratios (SMR)
head(nc.sids)
nc.sidsshp@data<-nc.sids
qp = spplot(nc.sidsshp,c("SMR74","SMR79"),at=c(0,.5,.75,.9,1.1,1.25,1.5,4.8),col.regions=brewer.pal(7,"Blues"))

### 1.2 Probability Map
nc.sids$PPOIS74<-ppois(nc.sids$SID74,nc.sids$EXP74,lower.tail=T) #Calculate probablity assuming a Poisson distribution
nc.sids$PPOIS79<-ppois(nc.sids$SID79,nc.sids$EXP79,lower.tail=T) #lower.tail if T, probabilities are P[y>=Y] (observed>=expected)
nc.sidsshp@data<-nc.sids
qp = spplot(nc.sidsshp,c("PPOIS74","PPOIS79"),at=c(0,.05,.1,.25,.5,.75,.9,.95,1),col.regions=brewer.pal(8,"Blues")) #create a probability map

### 1.3 Define Neighbors

#### 1.3.1 Contiguity based neighbors
sids_nbq<-poly2nb(nc.sidsshp) # Queen's neighbors
sids_nbr<-poly2nb(nc.sidsshp,queen = F) #Rook
coords<-coordinates(nc.sidsshp)# Let's plot the neighbors
plot(nc.sidsshp)
plot(sids_nbq,coords,add=T)
plot(nc.sidsshp)
plot(sids_nbr,coords,add=T)

#### 1.3.2 Distance based neighbors: KNN
coords = coordinates(nc.sidsshp)
IDs = row.names(nc.sidsshp@data)
sids_kn1 = knn2nb(knearneigh(coords,k=1),row.names=IDs)
sids_kn2 = knn2nb(knearneigh(coords,k=2),row.names=IDs)
sids_kn4 = knn2nb(knearneigh(coords,k=4),row.names=IDs)
plot(nc.sidsshp)
plot(sids_kn1,coords,add=T)
plot(nc.sidsshp)
plot(sids_kn2,coords,add=T)
plot(nc.sidsshp)
plot(sids_kn4,coords,add=T)

#### 1.3.3 Distance based neighbors: specified distance
sids_kd1<-dnearneigh(coords,d1=0,d2=30000,row.names = IDs)
sids_kd2<-dnearneigh(coords,d1=0,d2=40000,row.names = IDs)
sids_kd3<-dnearneigh(coords,d1=0,d2=50000,row.names = IDs)
plot(nc.sidsshp)
plot(sids_kd1,coords,add=T)
plot(nc.sidsshp)
plot(sids_kd2,coords,add=T)
plot(nc.sidsshp)
plot(sids_kd3,coords,add=T)

### 1.4 Generate Weight Matrix
sids_kn4_wb<-nb2listw(sids_kn4,style = "B") # Binary weights
sids_kd2_w<-nb2listw(sids_kd2,zero.policy = T) #1.4.2 Row-standardized weights

### 1.5 Empirical Bayes smoothing

### 1.5.1a Global Empirical Bayes Smoothing
eb1 = EBest(nc.sids$SID74,nc.sids$BIR74) # Global Empirical Bayes Smoothing
nc.sids$EB_mm74 = eb1$estmm # method of moments (implemented in spdep)
eb1 = EBest(nc.sids$SID79,nc.sids$BIR79)
nc.sids$EB_mm79 = eb1$estmm
eb2 = empbaysmooth(nc.sids$SID74, nc.sids$BIR74) # Global Empirical Bayes Smoothing
nc.sids$EB_ml74 = eb2$smthrr # maximum likelihood approach (implemented in DCluster)
eb2 = empbaysmooth(nc.sids$SID79, nc.sids$BIR79)
nc.sids$EB_ml79 = eb2$smthrr

#### 1.5.1b Plot Smoothing alongsaide Raw Rates
nc.sids$RR74<-nc.sids$SID74/nc.sids$BIR74 #raw rates
nc.sids$RR79<-nc.sids$SID79/nc.sids$BIR79 #raw rates
nc.sidsshp@data<-nc.sids
qp = spplot(nc.sidsshp,c("EB_mm74","EB_ml74","RR74"),at=c(0,.001,.002,.003,.004,.005,.006,.007,.008,.01),col.regions=brewer.pal(9,"Blues"))

#### 1.5.2 Local Empirical Bayes Smoothing
eb3 = EBlocal(nc.sids$SID74, nc.sids$BIR74, sids_kn4) # need the neighbor definition
nc.sids$EB_mm_local74 = eb3$est
nc.sidsshp@data = nc.sids
qp = spplot(nc.sidsshp,c("EB_mm_local74","EB_mm74","EB_ml74","RR74"),at=c(0,.001,.002,.003,.004,.005,.006,.007,.008,.01),col.regions=brewer.pal(9,"Blues"))

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
ca = counties(state = '06') # download CA counties boundaries from tigris package
ca = as(ca, "Spatial") # Covert sf object to spatial df
proj4string(ca) <- CRS("+init=epsg:4326")  # Reset projection
ca = spTransform(ca, TA) # transform projection to TA
caAggregate = aggregate(ca) # aggregate all counties
qp = plot(caAggregate) # Plot aggregate

# In proj4string(xy) : CRS object has comment, which is lost in output

# W8 Disease Clustering

## 1 Global Clustering

### Define neighbors (Queen)
sids_nbq<-poly2nb(nc.sidsshp)
coords<-coordinates(nc.sidsshp)
IDs<-row.names(nc.sidsshp@data)
sids_kd<-dnearneigh(coords,d1=0,d2=40000,row.names = IDs)

### Generate weight matrix
sids_nbq_w<-nb2listw(sids_nbq)
sids_kd_w<-nb2listw(sids_kd,zero.policy = T)

### Moran's I (aggregated data)
moran.test(nc.sidsshp$RR74,sids_nbq_w)

### Geary's C (aggregated data)
geary.test(nc.sidsshp$RR74,sids_nbq_w)

#KNN (point data)
dat2<-dat
dat2@data<-as.data.frame(dat@data$marks)
dat.ppp<-as.ppp(dat2)
qnn.test(dat.ppp,q=c(3,4,5,6),nsim=999,case=1,longlat=F)

