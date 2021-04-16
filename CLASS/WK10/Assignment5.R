script = 'Assignment 4 Submission' # Input desacriptive script title
name = 'A04' # Input script name (subject, version, other)
user = 'Andrew S. Cistola, MPH; https://github.com/andrewcistola' # Input name and GitHub profile of user

#Assignment 5

#Q0. Load packages "GWmodel", "tigris", "sqldf", "lme4", "rgeos", "arm", "ggplot2", "plyr" and set "WK10" folder as the working directory (0 pt)
install.packages('GWmodel')
library(GWmodel) # Geographic weighted regression in R
library(tigris)  
library(sqldf)
library(lme4) # Linear mixed effect modeling in R
library(rgeos) 
library(arm) # Visualiqzations of linear mixed effect modeling using 'lme4' in R
library(ggplot2) # General use plotting library from Hadley Wickham
library(plyr) # Data manipulation from Hadley Wickham 
setwd(paste(directory, 'WK10', sep = ''))

########################################
#Part 1. Data Import and Clean (30 pts)#
########################################

#Q1. Load the built-in data "USelect" using the data() function. Print the first 6 rows of its data slot, and check its SRID. (2 pts)
data(USelect)
head(USelect2004@data) 
USelect2004@proj4string

#Q2. Assign SRID 4326 to USelect2004, and add an electid variable "electid" to the data slot of "USelect2004" with value automatically increased from 1 to 3111. (2 pts)
USelect2004@proj4string <- CRS("+init=epsg:4326") # Change SRID to 4326
USelect2004@data$electid <- rownames(USelect2004@data) # Save index as column to create row of ascending values
head(USelect2004@data) # Verify

#Q3. Download boundaries of all states using the states() function from the package "tigris", save them as an object "us", and check its SRID. (1 pt)
us = states() # Import built in dataset
us = as(us, 'Spatial') # Convert sp to sf object (spatial data frame)
us@proj4string # Verify

#Q4. Transform the SRID of "us" to 4326, and remove Alaska (02), Hawaii (15), American Samoa (60), Guam (66), Northern Mariana Islands (69), Puerto Rico (72), and Virgin Islands (78). (5 pts)
us@proj4string <- CRS("+init=epsg:4326") # Change SRID to 4326
us@proj4string # Check SRID
us@data = us@data[us@data$GEOID != c('02', '15', '60', '66', '69', '72', '78'), ] # Subset based on vector
us@data$GEOID # Verify

#Q5. Import "stateEduc.csv" from the "dat" folder as "stateEduc". Rename "GEO.id2" to "GEOID". (2 pts)
stateEduc = read.csv("dat/stateEduc.csv") # Import dataset from _data folder
names(stateEduc)[names(stateEduc) == "GEO.id2"] <- "GEOID" # Rename column in base R
head(stateEduc) # Verify

#Q6. Calculate percentage of population with education less than high school (HD01_VD02/HD01_VD01), save it as a new column "plowedu". (2 pts)
stateEduc$plowedu = stateEduc$HD01_VD02 / stateEduc$HD01_VD01
head(stateEduc)

#Q7. Merge "plowedu" to the data slot of "us" based on "GEOID". (5 pts)
stateEduc = stateEduc[c('GEOID', 'plowedu')] # Select columns of dataframe
us@data = merge(us@data, stateEduc, by = 'GEOID') # Merge by column
head(us@data) # Verify

#Q8. Get the centroids of election divisions, and save them as "centroidelect". (3 pts)
centroidelect <- gCentroid(USelect2004, byid = T, id = USelect2004$electid) # get the centroid points of polygons
head(centroidelect) # Verify

#Q9. Use the over() function to overlay the centroids and state boundaries, and merge "GEOID" and "plowedu" from "us" to "USelect2004". (5 pts)
us_over = over(centroidelect, us) # Overlay centroids of small geography (arg1) onto larger polygons (arg2). This will create a new dataframe with columns of agr2 with rows of arg1
us_over$electid <- rownames(us_over) # Save index as column to create row of ascending values
us_over = us_over[c('GEOID', 'plowedu', 'electid')] # Select columns of dataframe
USelect2004 = merge(USelect2004, us_over, by = 'electid')
head(USelect2004)

#Q10. Create a new column in "USelect2004" named "bush", which equals to 1 if winner="Bush", and 0 otherwise. (3 pts)
USelect2004@data$Bush[USelect2004@data$winner == 'Bush'] <- 1 # Create new column based on conditions
USelect2004@data$Bush[USelect2004@data$winner != 'Bush'] <- 0 # Create new column based on conditions
head(USelect2004) # Verify

#######################################
#Part 2. Mixed Effects Models (30 pts)#
#######################################
#Q11. Build a mixed-effects model "m1" with the binary variable "bush" as the outcome, "pctcoled" and "plowedu" as the predictors. Please fit the model with fixed slopes and a random intercept by "GEOID". Use display() function to print out the summary of the results. (5 pts)
m1 <- glmer(Bush ~ pctcoled + plowedu + (1|GEOID), family = binomial(link = "logit"), data = USelect2004@data)
display(m1)

#Q12. Calculate ICC based on the output of "m1". (5 pts)
install.packages('sjstats')
library(sjstats)
icc(m1)

#Q13. Calculate the ORs and 95% CI for each 10% increase in "pctcoled" and 1% increase in "plowedu". (10 pts)
exp(fixef(m1)[1] + c(-1.96,1,1.96) * se.fixef(m1)[1]) # 95% CIs
exp(fixef(m1)[2] + c(-1.96,1,1.96) * se.fixef(m1)[2]) # 95% CIs

#Q14. Build a second model "m2" using the same outcome and predictors as "m1", but with a varying intercept, a varying slope for "pctcoled", and a fixed slope for "plowedu". Print out the summary of the results. (5 pts)
m2 <- lmer(Bush ~ pctcoled + plowedu + (1 + pctcoled|GEOID), data = USelect2004@data)
display(m2)

#Q15. Calculate the OR and 95% CI for each 10% increase in "pctcoled" in the state of Florida. (5 pts)
exp(fixef(m2)[2] + c(-1.96,1,1.96) * se.fixef(m2)[2]) # 95% CIs

######################
#Part 3. GWR (40 pts)#
######################
#Q16. Generate the centroids of all states and save them as "centroidstate". (2 pts)
centroidstate <- gCentroid(us, byid = T, id = us$GEOID) # get the centroid points of polygons

#Q17. Generate two distance matrices with "DM1" using "centroidelect" as dp.locat, and "DM2" using "centroidelect" as dp.locat and "centroidstate" as rp.locat. (5 pts)
DM1 <- gw.dist(dp.locat = coordinates(centroidelect)) # Compute the distances between the centroid points of polygons
DM2 <- gw.dist(dp.locat = coordinates(centroidelect), rp.locat = coordinates(centroidstate))

#Q18. Use cross-validation to find the optimal N for a GWR with "bush" as the outcome, "pctcoled" and "plowedu" as the predictors, and "DM1" as the distance matrix. Please use a "gaussian" kernel, with "longlat" option set to "TRUE". Save the optimal N as "gwrn". (5 pts)
gwrn <- bw.ggwr(Bush ~ pctcoled + plowedu, data = USelect2004@data, family = "binomial", approach = "CV", kernel = "gaussian", adaptive = T, longlat = T, dMat = DM1)

#Q19. Fit a GWR to the ceontroids of election divisions using the optimal N with a "Gaussian" kernel. Save the model as "gwrm1", and print out the first 6 rows of the results. (5 pts)
gwrm1 <- ggwr.basic(Bush ~ pctcoled + plowedu, data = londonhp, family = "binomial", bw = gwrn, dMat = DM1, kernel = 'gaussian', adaptive = T)

#Q20. Calculate the OR for each 10% increase in "pctcoled" and save it as a new column "ORpctcoled" in "USelect2004". Print out the first 6 ORs. (3 pts)
USelect2004@data$ORpctcoled <- exp(gwrm1$SDF$pctcoled)

#Q21. Map the ORs. (5 pts)
ggplot(USelect2004@data,aes(x=x,y=y))+geom_point(aes(colour=USelect2004$ORpctcoled))+scale_color_gradient2(low="red",mid="white",high="blue",midpoint=1,space="rgb",na.value="gray50",guide="colorbar",guide_legend(title="OR"))+coord_equal()

#Q22. Fit another GWR to the ceontroids of states using the optimal N with a "Gaussian" kernel. Save the model as "gwrm2", and print out the first 6 rows of the results. (5 pts)
gwrm2 <- ggwr.basic(Bush ~ pctcoled + plowedu, data = londonhp, family = "binomial", bw = gwrn, dMat = DM2, kernel = 'gaussian', adaptive = T)

#Q23. Calculate the OR for each 10% increase in "pctcoled" and save it as a new column "ORpctcoled" in "us". Print out the first 6 ORs. (5 pts)
us@data$ORpctcoled <- exp(gwrm2$SDF$pctcoled)

#Q24. Map the ORs. (5 pts)
gwrm2 <- ggwr.basic(Bush ~ pctcoled + plowedu, data = londonhp, family = "binomial", bw = gwrn, dMat = DM2, kernel = 'gaussian', adaptive = T) + geom_path(data = boroughoutline, aes(long, lat, group = GEOID), color = "gray")

