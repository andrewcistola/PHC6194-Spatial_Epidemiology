script = 'Assignment 4 Submission' # Input desacriptive script title
name = 'A04' # Input script name (subject, version, other)
user = 'Andrew S. Cistola, MPH; https://github.com/andrewcistola' # Input name and GitHub profile of user

#Assignment 4

#Q0. Load packages "spdep", "tigris", "sqldf", "RColorBrewer", "rsatscan", "ggplot2", "plyr", and set "WK8" folder as the WD. (0 pt)
library(spdep)
library(tigris)
library(sqldf)
library(RColorBrewer)
library(rsatscan)
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
head(fl)

#Q3. Rename the varaibles "Crude.Rate" as "mort", and "County.Code" as "fips". (2 pts)
names(fldeath)[names(fldeath) == "Crude.Rate"] <- "mort" #rename just the "Crude.Rate" column
names(fldeath)[names(fldeath) == "County.Code"] <- "fips" #rename just the "Crude.Rate" column
head(fldeath) # Print first 6 obs.

#Q4. Merge the variables "Deaths", "Population", "mort" from "fldeath" to the data slot in "fl" based on fips code. Hint: you can use the package "sqldf" to run sql query in R without passing it to a sql database. (5 pts)
fldeath = fldeath[c('Deaths', 'Population', 'mort', 'fips')] 
names(fldeath)[names(fldeath) == 'fips'] <- 'GEOID' 
head(fldeath) 

library(sp)
fl = merge(fl, fldeath, by = 'GEOID')
head(fl)

#Q5. Calculate the expected number of deaths for each county and save it as a new variable "expdeaths" in "fl". Print out the first 6 rows of the data slot in "fl". (5 pts)
rate = sum(fl$Deaths)/sum(fl$Population) #calculate raw SID rate across the state
fl$expdeaths<-rate*fl$Population # calculate expected number of deaths for each county
head(fl) # Print first 6 obs.

##################################
#Part 2. Disease Mapping (20 pts)#
##################################

#Q6. Assuming a Poisson distribution, please calculate the probability P[y<=Y] (observed<=expected). You can save the probability as a new variable "prob" in "fl". (5 pts)
fl$prob<-ppois(fl$Deaths, fl$expdeaths, lower.tail=T) #Calculate probablity assuming a Poisson distribution

#Q7. Show the probability "prob" on a map. Use the following cutoff to categorize the probability: 0,.05,.1,.25,.5,.75,.9,.95,1. (5 pts)
qp = spplot(fl, 'prob', at = c(0,.05,.1,.25,.5,.75,.9,.95,1), col.regions = brewer.pal(8, "Blues")) # create a probability map
png('A04_Q07.png') # Open file
plot(qp) # Plot quick plot object
dev.off() # Close file

#Q8. Generate a local Empirical Bayes Smoothed mortality rate based on Queen neighbors, and save it as "mortlebs" in "fl". Print out the first 6 rows of the data slot in "fl". (5 pts)
fl_nbq <- poly2nb(fl) # Queen's neighbors
eb3 = EBlocal(fl$Deaths, fl$Population, fl_nbq) # need the neighbor definition
fl$mortlebs = eb3$est 
head(fl@data)

#Q9. Plot the local Empirical Bayes Smoothed mortality rates. Use the following cutoff to categorize the probability: 0,.002,.004,.006,.008,.010,.012,.014,.016,.018. (5 pts)
qp = spplot(fl, 'mortlebs', at = c(0,.002,.004,.006,.008,.010,.012,.014,.016,.018), col.regions = brewer.pal(8, "Blues")) # create a probability map
png('A04_Q09.png') # Open file
plot(qp) # Plot quick plot object
dev.off() # Close file


################################################
#Part 3. Disease Clustering: Moran's I (25 pts)#
################################################

#Q10. Calculate Global Moran's I based on the local Empirical Bayes Smoothed mortality rates and Queen neighbor weight matrix. (5 pts)
fl_nbq = poly2nb(fl) # Queen's neighbors
coords = coordinates(fl) # Save polygons as object
fl_nbq_w = nb2listw(fl_nbq) ### Generate weight matrix
moran.test(fl$mortlebs, fl_nbq_w) ### Moran's I (aggregated data)

#Q11. Calculate LISA using the local Empirical Bayes Smoothed mortality rates and Queen neighbor weight matrix. Save the results as "lm". Print out the first 6 rows in "lm". (5 pts)
lm = localmoran(fl$mortlebs, fl_nbq_w)
head(lm)

#Q12. Merge "lm" to the data slot in "fl". (5 pts)
library(sp)
fl = merge(fl, lm, by = 'GEOID')
head(fl)

#Q13. Create a new variable "quad_sig" in "fl" to save the moran plot quadrant (1=low-low, 2=low-high, 3=high-low, 4=high-high, 5=non-significant (use 0.1 as sig level)). (5 pts)
fl$quad_sig <- NA # create a new variable identifying the moran plot quadrant (dismissing the non-siginificant ones)
q = vector(mode = "numeric", length = nrow(lm))
m.mort = fl$mort-mean(fl$mort) # center the variables around its mean
m.Ii = lm[,1]-mean(lm[,1])
sig <- 0.05 # significance threshold
nc.sidsshp$quad_sig[m.mort < 0 & m.Ii < 0] <- 1 # low-low
nc.sidsshp$quad_sig[m.mort < 0 & m.Ii > 0] <- 2 # low-high
nc.sidsshp$quad_sig[m.mort > 0 & m.Ii < 0] <- 3 # high-low
nc.sidsshp$quad_sig[m.mort > 0 & m.Ii > 0] <- 4 # high-high
nc.sidsshp$quad_sig[lm[, 5] > sig] <- 0 # non-significant

#Q14. Plot "quad_sig" on a map. (5 pts)
png('A04_Q14.png') # Open file
brks <- c(0, 1, 2, 3, 4)
colors <- c("white", "blue", rgb(0, 0, 1, alpha = 0.3), rgb(1, 0, 0, alpha = 0.3), 'red')
plot(fl, border = 'lightgray', col = colors[findInterval(fl$quad_sig, brks, all.inside = F)])
box()
legend('bottomleft', legend = c('insignificant', 'low-low', 'low-high', 'high-low', 'high-high'), fill = colors, bty = 'n')
dev.off() # Close file

##############################################
#Part 4. Disease Clustering: SatScan (35 pts)#
##############################################

#Q15. Generate the case, population, and geo data for Satscan. Name them "flcas", "flpop", and "flcrd". (5 pts)
flshp = spTransform(fl, CRS('+init=epsg:4326'))
flcas = data.frame(flshp@data[, c('GEOID','Deaths')])
flpop = data.frame(flshp@data[, c('GEOID', 'Population')])
flcrd = data.frame(cbind(flshp@data[, 'GEOID'], coordinates(flshp)[, c(2,1) ]))
colnames(flcrd) <- c('GEOID', 'lat', 'long')

#Q16. Output these data to temporary directory as "fl.cas", "fl.pop", and "fl.geo". (5 pts)
td = tempdir()
write.cas(flcas, td, 'fl')
write.pop(flpop, td, 'fl')
write.geo(flcrd, td, 'fl')

#Q17. Set and output parameters as "fl" to the temporary directory: using a Discrete Poisson moel with purely spatial analyses. (5 pts)
invisible(ss.options(reset = T))
ss.options(list(CaseFile = 'fl.cas', PopulationFile = 'fl.pop'))
ss.options(list(CoordinatesFile = 'fl.geo')
ss.options(list(CoordinatesType = 1) # coordinate type (0=Cartesian, 1=latitude/longitude)
ss.options(list(AnalysisType = 1) # analysis type (1=Purely Spatial, 2=Purely Temporal, 3=Retrospective Space-Time, 4=Prospective Space-Time, 5=Spatial Variation in Temporal Trends, 6=Prospective Purely Temporal
ss.options(list(ModelType = 0)) # model type (0=Discrete Poisson, 1=Bernoulli, 2=Space-Time Permutation, 3=Ordinal, 4=Exponential, 5=Normal, 6=Continuous Poisson, 7=Multinomial
ss.options(list(TimeAggregationUnits = 0)) # time aggregation units (0=None, 1=Year, 2=Month, 3=Day, 4=Generic)
ss.options(list(ReportGiniClusters = 'n', LogRunToHistoryFile = 'n'))
write.ss.prm(td, 'fl') #output paramters

#Q18. Run SatScan, save the results as "flss" and print the summary of the results. (5 pts)
flss <- satscan(td, 'fl', sslocation = "/home/drewc/SaTScan", ssbatchfilename = "SaTScanBatch64")

#Q19. Save the boundaries of clusters as "flcluster". (5 pts)
flcluster = flss$shapeclust

#Q20. Map the boundaries of clusters overlaid with the local EBS mortality rates. (10 pts)
flcluster_fort = fortify(flcluster, region = 'CLUSTER')
flcluster_data = flcluster@data
flcluster_fort = merge(flcluster_fort, flcluster_data, by.x = 'id', by.y = 'CLUSTER', all.x = T)
map = ggplot() + geom_polygon(data = flcluster_fort, aes(long, lat, group = group, fill = mortlebs, alpha = 0.3)) 
                + geom_path(color = 'white') 
                + coord_equal()
                + theme(panel.background = element_blank(), axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())
                + scale_fill_gradientn('Empirical Bayes Smoothed Mortality Rate', colours = c('#DFEBF7', '#11539A'))
                + geom_map(map = flcluster_fort, data = flcluster_fort, aes(map_id = id, group = group), color = 'red', alpha = 0.2)
png('A04_Q20.png') # Open file
plot(map) # Plot quick plot object
dev.off() # Close file

