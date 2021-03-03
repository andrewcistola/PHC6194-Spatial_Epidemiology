script = 'Assignment 4 Submission' # Input desacriptive script title
name = 'A04' # Input script name (subject, version, other)
user = 'Andrew S. Cistola, MPH; https://github.com/andrewcistola' # Input name and GitHub profile of user

#Assignment 4

#Q0. Load packages "spdep", "tigris", "sqldf", "RColorBrewer", "rsatscan", "ggplot2", "plyr", and set "WK8" folder as the WD. (0 pt)
library(spdep)
library(tigris)

library(RColorBrewer)

library(ggplot2) # General use plotting library from Hadley Wickham
library(plyr) # dplyr provides a grammar of data manipulation, providing a consistent set of verbs that solve the most common data manipulation challenges.
setwd(paste(directory, 'WK8', sep = ''))

########################################
#Part 1. Data Import and Clean (20 pts)#
########################################

#Q1. Import the Florida 2016 county-level mortality data "fldeath2016.txt" as a dataframe "fldeath". Please DO NOT import strings as factors. Print the first 6 rows of "fldeath". (3 pts)
fldeath = read.csv("data/fldeath2016.txt", sep = '\t', stringsAsFactors = F) ## import tab delimited file
head(fldeath) # Print first 6 obs.

#Q2. Import the Florida county boundaries data from TigerLine. You can use the counties() function in the package "tigris". Save it as a SpatialPolygonDataFrame "fl". Check the projection of it. (5 pts)
fl = counties(state = '12') # download FL counties boundaries from tigris package
fl = as(fl, "Spatial")  # Covert sf object to spatial df
fl@proj4string # we can also check the SRS (it's called CRS or coordinate reference system in R)

#Q3. Rename the varaibles "Crude.Rate" as "mort", and "County.Code" as "fips". (2 pts)
names(fldeath)[names(fldeath) == "Crude.Rate"] <- "mort" #rename just the "Crude.Rate" column
names(fldeath)[names(fldeath) == "County.Code"] <- "fips" #rename just the "Crude.Rate" column
head(fldeath) # Print first 6 obs.

# 3-12-2021 DC!

#Q4. Merge the variables "Deaths", "Population", "mort" from "fldeath" to the data slot in "fl" based on fips code. Hint: you can use the package "sqldf" to run sql query in R without passing it to a sql database. (5 pts)


#Q5. Calculate the expected number of deaths for each county and save it as a new variable "expdeaths" in "fl". Print out the first 6 rows of the data slot in "fl". (5 pts)
rate<-sum(nc.sids$SID74)/sum(nc.sids$BIR74) #calculate raw SID rate across the state
fl$expdeaths<-rate*fl$Population # calculate expected number of deaths for each county
head(fl) # Print first 6 obs.

##################################
#Part 2. Disease Mapping (20 pts)#
##################################

#Q6. Assuming a Poisson distribution, please calculate the probability P[y<=Y] (observed<=expected). You can save the probability as a new variable "prob" in "fl". (5 pts)
nc.sids$PPOIS74<-ppois(nc.sids$SID74,nc.sids$EXP74,lower.tail=T) #Calculate probablity assuming a Poisson distribution
nc.sids$PPOIS79<-ppois(nc.sids$SID79,nc.sids$EXP79,lower.tail=T) #lower.tail if T, probabilities are P[y>=Y] (observed>=expected)
nc.sidsshp@data<-nc.sids

#Q7. Show the probability "prob" on a map. Use the following cutoff to categorize the probability: 0,.05,.1,.25,.5,.75,.9,.95,1. (5 pts)
png('A04_Q07.png') # Open file
qp = spplot(nc.sidsshp,c("PPOIS74","PPOIS79"),at=c(0,.05,.1,.25,.5,.75,.9,.95,1),col.regions=brewer.pal(8,"Blues")) #create a probability map

#Q8. Generate a local Empirical Bayes Smoothed mortality rate based on Queen neighbors, and save it as "mortlebs" in "fl". Print out the first 6 rows of the data slot in "fl". (5 pts)
sids_nbq<-poly2nb(nc.sidsshp) # Queen's neighbors
eb3 = EBlocal(nc.sids$SID74, nc.sids$BIR74, sids_kn4) # need the neighbor definition
nc.sids$EB_mm_local74 = eb3$est 
nc.sidsshp@data = nc.sids

#Q9. Plot the local Empirical Bayes Smoothed mortality rates. Use the following cutoff to categorize the probability: 0,.002,.004,.006,.008,.010,.012,.014,.016,.018. (5 pts)
png('A04_Q09.png') # Open file
spplot(nc.sidsshp,c("EB_mm_local74","EB_mm74","EB_ml74","RR74"),at=c(0,.001,.002,.003,.004,.005,.006,.007,.008,.01),col.regions=brewer.pal(9,"Blues"))
dev.off() # Close file

################################################
#Part 3. Disease Clustering: Moran's I (25 pts)#
################################################

#Q10. Calculate Global Moran's I based on the local Empirical Bayes Smoothed mortality rates and Queen neighbor weight matrix. (5 pts)
sids_nbq<-poly2nb(nc.sidsshp) ### Define neighbors (Queen)
coords<-coordinates(nc.sidsshp)
IDs<-row.names(nc.sidsshp@data)

### Generate weight matrix
sids_nbq_w<-nb2listw(sids_nbq)

### Moran's I (aggregated data)
moran.test(nc.sidsshp$RR74,sids_nbq_w)

#Q11. Calculate LISA using the local Empirical Bayes Smoothed mortality rates and Queen neighbor weight matrix. Save the results as "lm". Print out the first 6 rows in "lm". (5 pts)

#Q12. Merge "lm" to the data slot in "fl". (5 pts)

#Q13. Create a new variable "quad_sig" in "fl" to save the moran plot quadrant (1=low-low, 2=low-high, 3=high-low, 4=high-high, 5=non-significant (use 0.1 as sig level)). (5 pts)
nc.sidsshp$quad_sig<-NA #create a new variable identifying the moran plot quadrant (dismissing the non-siginificant ones)
q<-vector(mode = "numeric",length=nrow(sids_lm))
m.RR74<-nc.sidsshp$RR74-mean(nc.sidsshp$RR74) #center the variables around its mean
m.Ii<-sids_lm[,1]-mean(sids_lm[,1])
sig<-0.05 #significance threshold
nc.sidsshp$quad_sig[m.RR74<0 & m.Ii<0] <- 1 #low-low
nc.sidsshp$quad_sig[m.RR74<0 & m.Ii>0] <- 2 #low-high
nc.sidsshp$quad_sig[m.RR74>0 & m.Ii<0] <- 3 #high-low
nc.sidsshp$quad_sig[m.RR74>0 & m.Ii>0] <- 4 #high-high
nc.sidsshp$quad_sig[sids_lm[,5]>sig] <- 0 #non-significant

#Q14. Plot "quad_sig" on a map. (5 pts)
png('A04_Q14.png') # Open file
brks<-c(0,1,2,3,4)
colors<-c("white","blue",rgb(0,0,1,alpha = 0.3),rgb(1,0,0,alpha=0.3),"red")
plot(nc.sidsshp,border="lightgray",col=colors[findInterval(nc.sidsshp$quad_sig,brks,all.inside=F)])
box()
legend("bottomleft",legend=c("insignificant","low-low","low-high","high-low","high-high"),fill=colors,bty="n")
dev.off() # Close file

##############################################
#Part 4. Disease Clustering: SatScan (35 pts)#
##############################################

#Q15. Generate the case, population, and geo data for Satscan. Name them "flcas", "flpop", and "flcrd". (5 pts)

#data
nc.sidsshp2<-spTransform(nc.sidsshp,CRS("+init=epsg:4326"))
head(nc.sidsshp2@data)
sidscas<-data.frame(nc.sidsshp2@data[,c("CNTY_ID","SID74")])
sidspop<-data.frame(nc.sidsshp2@data[,c("CNTY_ID","BIR74")])
sidspop$year<-74
sidspop<-sidspop[,c(1,3,2)]
sidcrd<-data.frame(cbind(nc.sidsshp2@data[,"CNTY_ID"],coordinates(nc.sidsshp2)[,c(2,1)]))


#Q16. Output these data to temporary directory as "fl.cas", "fl.pop", and "fl.geo". (5 pts)

#output data
td = tempdir()
write.cas(sidscas, td, "sids")
write.pop(sidspop, td, "sids")
write.geo(sidcrd,  td, "sids")

#Q17. Set and output parameters as "fl" to the temporary directory: using a Discrete Poisson moel with purely spatial analyses. (5 pts)

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

#Q18. Run SatScan, save the results as "flss" and print the summary of the results. (5 pts)

#run SatScan
sidssatscan <- satscan(td, "sids",sslocation = "/home/drewc/SaTScan",ssbatchfilename = "SaTScanBatch64")

#Q19. Save the boundaries of clusters as "flcluster". (5 pts)

#boundary of clusters
sidscluster<-sidssatscan$shapeclust

#Q20. Map the boundaries of clusters overlaid with the local EBS mortality rates. (10 pts)

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