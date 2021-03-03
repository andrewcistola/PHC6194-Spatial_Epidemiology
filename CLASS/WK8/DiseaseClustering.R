library(smacpod)
library(spdep)
library(rsatscan)
library(rgdal)
library(spatstat)
library(maptools)
library(plyr)
library(ggplot2)

setwd(paste(directory, 'WK8', sep = ''))

#1. Import and clean the data

#1.1 Aggregated Data

#load the data: sudden infant deaths in NC for 1974-1978 and 1979-1984
nc.sidsshp<-readOGR(dsn="/home/drewc/R/x86_64-pc-linux-gnu-library/3.6/spData/shapes/sids.shp",encoding="ESRI Shapefile")

#Define projection
proj4string(nc.sidsshp)<-CRS("+init=epsg:4326")

#Transform projection to EPSG26917 (UTM 17 N)
nc.sidsshp<-spTransform(nc.sidsshp,CRS("+init=epsg:26917"))

#Calculate raw rates
head(nc.sidsshp@data)
nc.sids<-nc.sidsshp@data

#calculate raw SID rate across the state
r74<-sum(nc.sids$SID74)/sum(nc.sids$BIR74)
r79<-sum(nc.sids$SID79)/sum(nc.sids$BIR79)

#calculate expected number of SID cases
nc.sids$EXP74<-r74*nc.sids$BIR74
nc.sids$EXP79<-r79*nc.sids$BIR79

#calculate the standardized mortality ratios (SMR)
nc.sids$SMR74<-nc.sids$SID74/nc.sids$EXP74
nc.sids$SMR79<-nc.sids$SID79/nc.sids$EXP79

#calculate raw rates
nc.sids$RR74<-nc.sids$SID74/nc.sids$BIR74
nc.sids$RR79<-nc.sids$SID79/nc.sids$BIR79

head(nc.sids)
nc.sidsshp@data<-nc.sids

#Define neighbors (Queen)
sids_nbq<-poly2nb(nc.sidsshp)

coords<-coordinates(nc.sidsshp)
IDs<-row.names(nc.sidsshp@data)
sids_kd<-dnearneigh(coords,d1=0,d2=40000,row.names = IDs)

#Generate weight matrix
sids_nbq_w<-nb2listw(sids_nbq)
sids_kd_w<-nb2listw(sids_kd,zero.policy = T)

#1.2 Point Data
dat<-read.csv("../WK7/data/precipitation.csv",stringsAsFactors = F)

#generate a random binary outcome
set.seed(5)
dat$marks<-rbinom(n=nrow(dat),size=1,prob=0.1)
head(dat)

#convert it to a SpatialPointsDataFrame
dat_geom<-SpatialPoints(coords=dat[,c("LONG","LAT")])
dat<-SpatialPointsDataFrame(dat_geom,data=dat)
proj4string(dat)<-CRS("+init=epsg:4326")

#transform projection to Teale Albers
TA <- CRS("+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +datum=NAD83 +units=m +ellps=GRS80 +towgs84=0,0,0")
dat<-spTransform(dat,TA)

#Global Clustering

#Moran's I (aggregated data)
moran.test(nc.sidsshp$RR74,sids_nbq_w)

#Geary's C (aggregated data)
geary.test(nc.sidsshp$RR74,sids_nbq_w)

#KNN (point data)
dat2<-dat
dat2@data<-as.data.frame(dat@data$marks)
dat.ppp<-as.ppp(dat2)
qnn.test(dat.ppp,q=c(3,4,5,6),nsim=999,case=1,longlat=F)

#Local Clustering

#Local Moran's I
#create moran scatterplot
moran<-moran.plot(nc.sidsshp$RR74,sids_nbq_w)

#create a local moran output
sids_lm<-localmoran(nc.sidsshp$RR74,sids_nbq_w)
head(sids_lm) #Ii: local moran statistics, E.Ii: expectation of local moran statistics, Var.Ii: variance of local moran statistics, Z.Ii: standard deviate of local moran statistic, Pr(z>0): p value of local moran statistics

#merge the local moran output to the data
colnames(sids_lm)[5]<-"P"
nc.sidsshp<-cbind(nc.sidsshp,sids_lm)
head(nc.sidsshp@data)

#map the results
nc.sidsshp_f<-fortify(nc.sidsshp,region="CNTY_ID")
head(nc.sidsshp_f)
nc.sidsshp_data<-nc.sidsshp@data
head(nc.sidsshp_data)
nc.sidsshp_f<-merge(nc.sidsshp_f,nc.sidsshp_data[,c("CNTY_ID","Ii")],by.x="id",by.y="CNTY_ID",all.x=T)
head(nc.sidsshp_f)

map1<-ggplot()+geom_polygon(data=nc.sidsshp_f,aes(long,lat,group=group,fill=Ii,alpha=0.3))+geom_path(color="white")+coord_equal()+theme(panel.background=element_blank(),axis.title=element_blank(),axis.text=element_blank(),axis.ticks = element_blank())+scale_fill_gradientn("Local Moran Statistics",colours=c("#DFEBF7","#11539A"))
map1

#create a new variable identifying the moran plot quadrant (dismissing the non-siginificant ones)
nc.sidsshp$quad_sig<-NA

q<-vector(mode = "numeric",length=nrow(sids_lm))

#center the variables around its mean
m.RR74<-nc.sidsshp$RR74-mean(nc.sidsshp$RR74)
m.Ii<-sids_lm[,1]-mean(sids_lm[,1])

#significance threshold
sig<-0.05

nc.sidsshp$quad_sig[m.RR74<0 & m.Ii<0] <- 1 #low-low
nc.sidsshp$quad_sig[m.RR74<0 & m.Ii>0] <- 2 #low-high
nc.sidsshp$quad_sig[m.RR74>0 & m.Ii<0] <- 3 #high-low
nc.sidsshp$quad_sig[m.RR74>0 & m.Ii>0] <- 4 #high-high
nc.sidsshp$quad_sig[sids_lm[,5]>sig] <- 0 #non-significant

#map
brks<-c(0,1,2,3,4)
colors<-c("white","blue",rgb(0,0,1,alpha = 0.3),rgb(1,0,0,alpha=0.3),"red")
plot(nc.sidsshp,border="lightgray",col=colors[findInterval(nc.sidsshp$quad_sig,brks,all.inside=F)])
box()
legend("bottomleft",legend=c("insignificant","low-low","low-high","high-low","high-high"),fill=colors,bty="n")

#Local Getis-Ord G Statistics
sids_g<-localG(nc.sidsshp$RR74,sids_kd_w)
head(sids_g)

#merge the g statistics to the data
nc.sidsshp<-cbind(nc.sidsshp,as.matrix(sids_g))
head(nc.sidsshp@data)
names(nc.sidsshp)[ncol(nc.sidsshp)]<-"gstat"
head(nc.sidsshp@data)

#map
nc.sidsshp_f<-fortify(nc.sidsshp,region="CNTY_ID")
head(nc.sidsshp_f)
nc.sidsshp_data<-nc.sidsshp@data
head(nc.sidsshp_data)
nc.sidsshp_f<-merge(nc.sidsshp_f,nc.sidsshp_data[,c("CNTY_ID","gstat")],by.x="id",by.y="CNTY_ID",all.x=T)

map2<-ggplot()+geom_polygon(data=nc.sidsshp_f,aes(long,lat,group=group,fill=gstat,alpha=0.3))+geom_path(color="white")+coord_equal()+theme(panel.background=element_blank(),axis.title=element_blank(),axis.text=element_blank(),axis.ticks = element_blank())+scale_fill_gradientn("gstat",colours=c("#DFEBF7","#11539A"))
map2

#Spatial Scan Statistics

#Bernoulli Model, Purely Spatial on Point Data
#data
head(dat@data)
datcas<-data.frame(dat@data[dat$marks==1,c("ID")])
datcas$n<-1
datctl<-data.frame(dat@data[dat$marks==0,c("ID")])
datctl$n<-1
datcrd<-dat@data[,c("ID","LAT","LONG")]

#output data
td = tempdir()
write.cas(datcas, td, "datcas")
write.ctl(datctl, td, "datctl")
write.geo(datcrd, td, "datgeo")

#parameters
invisible(ss.options(reset=T))
ss.options(list(CaseFile="datcas.cas",ControlFile="datctl.ctl"))
ss.options(list(PrecisionCaseTimes=0,StartDate="2019/01/01",EndDate="2019/02/01"))
#coordinate type (0=Cartesian, 1=latitude/longitude)
#analysis type (1=Purely Spatial, 2=Purely Temporal, 3=Retrospective Space-Time, 4=Prospective Space-Time, 5=Spatial Variation in Temporal Trends, 6=Prospective Purely Temporal
#model type (0=Discrete Poisson, 1=Bernoulli, 2=Space-Time Permutation, 3=Ordinal, 4=Exponential, 5=Normal, 6=Continuous Poisson, 7=Multinomial
ss.options(list(CoordinatesFile="datgeo.geo",CoordinatesType=1,AnalysisType=1,ModelType=1))
#time aggregation units (0=None, 1=Year, 2=Month, 3=Day, 4=Generic)
ss.options(list(TimeAggregationUnits=0))
ss.options(list(ReportGiniClusters="n",LogRunToHistoryFile="n"))

#output paramters
write.ss.prm(td,"dat")

#run SatScan
datsatscan <- satscan(td, "dat",sslocation = "/home/drewc/SaTScan",ssbatchfilename = "SaTScanBatch64")

#results
summary(datsatscan)
summary.default(datsatscan)

#boundary of clusters
datcluster<-datsatscan$shapeclust

#map
datcluster_f<-fortify(datcluster,region="CLUSTER")
head(datcluster_f)

datcluster_data<-datcluster@data
head(datcluster_data)
datcluster_f<-merge(datcluster_f,datcluster_data,by.x="id",by.y="CLUSTER",all.x=T)

head(datcluster_f)

#map
map3<-ggplot()+geom_polygon(data=datcluster_f,aes(long,lat,group=group,fill="red",alpha=0.4))+geom_path(color="white")+coord_equal()+theme(panel.background=element_blank(),axis.title=element_blank(),axis.text=element_blank(),axis.ticks = element_blank())+geom_point(data=dat@data,aes(x=LONG,y=LAT,group=ID,col=as.factor(marks)),size=1,alpha=0.3)+labs(col="Outcome")
map3

#Poisson Model, Purely Spatial on Aggregated Data
#data
nc.sidsshp2<-spTransform(nc.sidsshp,CRS("+init=epsg:4326"))
head(nc.sidsshp2@data)
sidscas<-data.frame(nc.sidsshp2@data[,c("CNTY_ID","SID74")])
sidspop<-data.frame(nc.sidsshp2@data[,c("CNTY_ID","BIR74")])
sidspop$year<-74
sidspop<-sidspop[,c(1,3,2)]
sidcrd<-data.frame(cbind(nc.sidsshp2@data[,"CNTY_ID"],coordinates(nc.sidsshp2)[,c(2,1)]))

#output data
td = tempdir()
write.cas(sidscas, td, "sids")
write.pop(sidspop, td, "sids")
write.geo(sidcrd,  td, "sids")

#parameters
invisible(ss.options(reset=T))
ss.options(list(CaseFile="sids.cas",PopulationFile="sids.pop"))
ss.options(list(PrecisionCaseTimes=0,StartDate="1974/01/01",EndDate="1978/12/31"))
#coordinate type (0=Cartesian, 1=latitude/longitude)
#analysis type (1=Purely Spatial, 2=Purely Temporal, 3=Retrospective Space-Time, 4=Prospective Space-Time, 5=Spatial Variation in Temporal Trends, 6=Prospective Purely Temporal
#model type (0=Discrete Poisson, 1=Bernoulli, 2=Space-Time Permutation, 3=Ordinal, 4=Exponential, 5=Normal, 6=Continuous Poisson, 7=Multinomial
ss.options(list(CoordinatesFile="sids.geo",CoordinatesType=1,AnalysisType=1))
#time aggregation units (0=None, 1=Year, 2=Month, 3=Day, 4=Generic)
ss.options(list(TimeAggregationUnits=0))
ss.options(list(ReportGiniClusters="n",LogRunToHistoryFile="n"))

#output paramters
write.ss.prm(td,"sids")

#run SatScan
sidssatscan <- satscan(td, "sids",sslocation = "/home/drewc/SaTScan",ssbatchfilename = "SaTScanBatch64")

#results
summary(sidssatscan)
summary.default(sidssatscan)

#boundary of clusters
sidscluster<-sidssatscan$shapeclust

#map
sidscluster_f<-fortify(sidscluster,region="CLUSTER")
head(sidscluster_f)
sidscluster_data<-sidscluster@data
head(sidscluster_data)
sidscluster_f<-merge(sidscluster_f,sidscluster_data,by.x="id",by.y="CLUSTER",all.x=T)

head(sidscluster_f)

nc.sidsshp_f<-fortify(nc.sidsshp2,region="CNTY_ID")
head(nc.sidsshp_f)
nc.sidsshp_data<-nc.sidsshp2@data
head(nc.sidsshp_data)
nc.sidsshp_f<-merge(nc.sidsshp_f,nc.sidsshp_data[,c("CNTY_ID","RR74")],by.x="id",by.y="CNTY_ID",all.x=T)

map4<-ggplot()+geom_polygon(data=nc.sidsshp_f,aes(long,lat,group=group,fill=RR74,alpha=0.3))+geom_path(color="white")+coord_equal()+theme(panel.background=element_blank(),axis.title=element_blank(),axis.text=element_blank(),axis.ticks = element_blank())+scale_fill_gradientn("Rate",colours=c("#DFEBF7","#11539A"))+geom_map(map=sidscluster_f,data=sidscluster_f,aes(map_id=id,group=group),color="red",alpha=0.2)
map4

