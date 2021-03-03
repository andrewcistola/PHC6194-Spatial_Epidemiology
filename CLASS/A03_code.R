# Metadata and Variables
title = 'UF PHC6194 SPR2021' # Input basic title
descriptive = '- Assignment 2 and 3' # Input descriptive title
author = 'Andrew S. Cistola, MPH' # Input author information
GH = 'https://github.com/andrewcistola/PHC6194' # Input GitHub repository
name = 'PHC6194_CLASS_A02_v1-1' # Input generic file name with repo, project, subject, and version
project = 'CLASS/' # Input project file name inside repository
repo = 'PHC6194/' # Input repository filename
user = 'Andrew S. Cistola, MPH; https://github.com/andrewcistola' # Input name and GitHub profile of user
local = '/home/drewc/GitHub/' # Input local path to repository
directory = paste(local, repo, project, sep = "") # Set wd to project repository using variables
day = Sys.Date() # Save dimple date as string
stamp = date() # Save Date and timestamp

####################################################

# Assignment 2

##############################
# Part 1. Data Import (10 pts)
##############################

## Q1. Load the packages "RPostgreSQL" and "ggmap" (1 pt)
library(RPostgreSQL) # General use mapping library with ggplot API
library(ggmap) # General use mapping library with ggplot API

## Q2. Set the working directory to the "WK5" folder and import the data "gnvadd.csv" from the "data" folder as a dataframe named "dat". DO NOT import strings as factors. (2 pts)
setwd(paste(directory, 'WK5/', sep = "")) # Set wd to project repository
dat = read.csv('data/gnvadd.csv', stringsAsFactors = FALSE) # Import dataset from _data folder

## Q3. Print out the first 6 rows of "dat", and display the structure of "dat". (2 pts)
head(dat) # Print mini table with first 6 observations 
str(dat) # Show structure of dataframe

#Q4. Create a connection to the "phc6194db" database in postgresql, and export "dat" to the database as a table called "wk5.dat". DO NOT export row names. (4 pts)
con_1 = dbConnect(dbDriver("PostgreSQL"), dbname = "phc6194db", host = "localhost", user = "phc6194", password = "vmuser") # create a connection to the postgres database
sql = 'DROP SCHEMA IF EXISTS wk5 CASCADE; CREATE SCHEMA wk5;'
dbSendQuery(con_1, sql)
dbWriteTable(con_1, c('wk5','dat'), dat, row.names = FALSE, append = FALSE) # Export R dataframe to SQL database

#Q5. Print out the first 6 rows of "wk5.dat" using a SQL query. (1 pt)
dbReadTable(con_1, c('wk5','dat')) # Dispaly PostgreSQL table
dbGetQuery(con_1, 'SELECT * FROM wk5.dat LIMIT 6;') # Select first 6 lines from table with PostgreSQL query

#################################################
#Part 2. Geocoding Using TIGER Geocoder (15 pts)#
#################################################

#Q6. Add three new columns to "wk5.dat": "rating_tiger" (type: integer), "norm_address_tiger" (type:text), and "pt_tiger" (type:geometry), which will be used to store the rating of the geocoding (use -1 to replace missing values), the normalized address, and the geometry of the geocoded location. Print out the first 6 rows of "wk5.dat" to check. (5 pts)
sql = '
ALTER TABLE wk5.dat ADD COLUMN rating_tiger integer;
ALTER TABLE wk5.dat ADD COLUMN norm_address_tiger text; 
ALTER TABLE wk5.dat ADD COLUMN pt_tiger geometry;'
dbSendQuery(con_1, sql)
dbGetQuery(con_1, 'SELECT * FROM wk5.dat LIMIT 6')

#Q7. Batch geocoding "address" in "wk5.dat" using TIGER geocoder. Add three additional columns to the table: Please use a batch size=50. (8 pts)
sql = '
UPDATE wk5.dat
SET (rating_tiger,norm_address_tiger,pt_tiger) = (COALESCE((g).rating,-1),pprint_addy((g).addy), (g).geomout)
FROM
  (SELECT * FROM wk5.dat WHERE rating_tiger IS NULL LIMIT 50) AS a
  LEFT JOIN
  (SELECT id, geocode(address,1) AS g FROM wk5.dat AS ag WHERE rating_tiger IS NULL) AS g1
  ON a.id = g1.id
WHERE a.id = wk5.dat.id
;'
dbSendQuery(con_1, sql)

#Q8. Print out the first 6 rows with all the columns as well as lon (name it as "lon_tiger") and lat (name it as "lat_tiger") of "pt_tiger". (2 pts)
sql = "SELECT *, ST_X(pt_tiger) as lon_tiger, ST_Y(pt_tiger) as lat_tiger FROM wk5.dat LIMIT 6;"
dbGetQuery(con_1 ,sql)


###########################################################
#Part 3. Geocoding Using Google Map Geocoding API (15 pts)#
###########################################################

#Q9. Now let's perform the geocoding using google map geocoding api through ggmap. Set the api key first. (2 pts)
register_google(key = 'AIzaSyA9EoExZadzR60Oy6xnL_nDJ8wgNksxKNI')

#Q10. Define the getGeoDetails() function. (1 pt)
getGeoDetails <- function(address){   
  #use the gecode function to query google servers
  geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
  #now extract the bits that we need from the returned list
  answer <- data.frame(lat=NA, long=NA, accuracy=NA, formatted_address=NA, address_type=NA, status=NA)
  answer$status <- geo_reply$status
  
  #if we are over the query limit - want to pause for an hour
  while(geo_reply$status == "OVER_QUERY_LIMIT"){
    print("OVER QUERY LIMIT - Pausing for 1 hour at:") 
    time <- Sys.time()
    print(as.character(time))
    Sys.sleep(60*60)
    geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
    answer$status <- geo_reply$status
  }
  
  #return Na's if we didn't get a match:
  if (geo_reply$status != "OK"){
    return(answer)
  }   
  #else, extract what we need from the Google server reply into a dataframe:
  answer$lat <- geo_reply$results[[1]]$geometry$location$lat
  answer$long <- geo_reply$results[[1]]$geometry$location$lng   
  if (length(geo_reply$results[[1]]$types) > 0){
    answer$accuracy <- geo_reply$results[[1]]$types[[1]]
  }
  answer$address_type <- paste(geo_reply$results[[1]]$types, collapse=',')
  answer$formatted_address <- geo_reply$results[[1]]$formatted_address
  
  return(answer)
}

#Q11. Perform geocoding with a batch size=10. All temporary results should be saved in the "data" folder: e.g. "_temp_geocoded_dat_1.rds" for the first batch. (7 pts)
batchsize<-10

for (j in seq(1,2)){
  
  #initialise a dataframe to hold the results
  geocoded <- data.frame()
  
  #temp file location
  tempfilename <- paste0("data/_temp_geocoded_dat_",j,".rds")
  
  # find out where to start in the address list (if the script was interrupted before):
  startindex <- (j-1)*batchsize + 1
  endindex <- startindex + batchsize - 1
  if (endindex>length(dat$id)) {
    endindex <- length(dat$id)
  }
  
  # Start the geocoding process - address by address. geocode() function takes care of query speed limit.
  for (ii in dat$id[startindex:endindex]){
    print(paste("Working on batch requests No.",j,", id", ii, ", last id to geocode:", dat$id[endindex]))
    #query the google geocoder - this will pause here if we are over the limit.
    result = getGeoDetails(dat[dat$id==ii,"address"]) 
    if (is.null(result$formatted_address)){
      result$formatted_address<-""
    }
    print(result$status)     
    result$id <- ii
    #append the answer to the results file.
    geocoded <- rbind(geocoded, result)
    #save temporary results as we are going along
    saveRDS(geocoded, tempfilename)
  }
}

#Q12. Merge the temporary results and save it as a dataframe "geo". Print out the first 6 rows of geo. (5 pts)
geo<-readRDS("data/_temp_geocoded_dat_1.rds")

for (j in 2:2){
  print(paste("Working on index", j))
  infile<-paste0("data/_temp_geocoded_dat_",j,".rds")
  datatemp <- readRDS(infile)
  geo <- rbind(geo,datatemp)
}

head(geo)

############################################
#Part 4. Data Cleaning and Linkage (30 pts)#
############################################

#Q13. Export "geo" to postgresql database "phc6194db" and save it as a table "wk5.geo". DO NOT export row names. Print out the first 6 rows using a SQL query. (5 pts)

dbWriteTable(con,c('wk5','geo'),geo,row.names=F,append=F)


q<-"SELECT * FROM wk5.geo LIMIT 6;"
dbGetQuery(con,q)

#Q14. Merge the table "wk5.dat" and "wk5.geo" using a SQL query, and keep all the columns in "wk5.dat" as well as the columns "lat" (rename it as "lat_ggmap"), "long" (rename it as "lon_ggmap"), and "accuracy" (rename it as "accuracy_ggmap"), and "formatted_address" (rename it as "norm_address_ggmap") in "wk5.geo". Save the merged table as "wk5.dat2", and print out the first 3 rows. (10 pts)

#Q15. Add a new column "pt_ggmap" (type: geometry) to the table "wk5.dat2" which stores the point geometries based on the lon/lat geocoded by ggmap. Set SRID for both pt_tiger and pt_ggmap as 4326. Print out the first 2 rows with all columns as well as the SRIDs of "pt_tiger" and "pt_ggmap". (10 pts)

#Q16. Transform "pt_tiger" and "pt_ggmap" to SRID 26917 (UTM 17N) and save the new geometries as "pt_tiger_utm" and "pt_ggmap_utm". Print out the first 2 rows with all columns as well as the SRIDs of "pt_tiger_utm" and "pt_ggmap_utm". (5 pts)

################################################
#Part 5. Distance and Closest Neighbor (17 pts)#
################################################

#Q17. Use ST_Distance() to calculate the distance between the points "pt_tiger_utm" and "pt_ggmap_utm" geocoded by TIGER geocoder and ggmap, print out the first 3 rows with all columns and the new column "dist". (5 pts)

#Q18. Subset "wk5.dat2" into two tables "wk5.publix" and "wk5.school" based on the values of the column "type". (2 pts)

#Q19. Use KNN operator to find out the closest publix to each school (use "pt_ggmap_utm"). (5 pts)

#Q20. Use KNN operator to find out the closest 3 publix to each school (use "pt_ggmap_utm"). (5 pts)

#############################
#Part 6. Geotagging (13 pts)#
#############################

#Q21. Import florida block group shp in terminal as "wk5.flbg", and print out the first two rows in "wk5.flbg" with columns "gid" and "geoid" (3 pts)

#Q22. Perform geotagging: tagging "wk5.school" to block groups (based on "pt_ggmap", and add a new column "geoid" to the table "wk5.school" from "wk5.flbg"). Print out the results. (10 pts)

####################################################

# Assignment 3

#############################
# Part 1. Data Clean (20 pts)#
#############################

#Q1. Load the packages "RPostgreSQL","ggmap","rpostgis","sp","rgdal","ggplot2","rgeos","maptools","ggsn", and "plyr". (1 pt)
library(RPostgreSQL) # Library for using postgre SQL databases in R
library(ggmap) # General use mapping library with ggplot API
library(rpostgis) # Library used in PHC6194
library(sp) # Library used in PHC6194
library(rgdal) # Library used in PHC6194
library(ggplot2) # General use plotting library from Hadley Wickham
library(rgeos) # Library used in PHC6194
library(maptools) # Library used in PHC6194
library(ggsn) # Library used in PHC6194
library(plyr) # dplyr provides a grammar of data manipulation, providing a consistent set of verbs that solve the most common data manipulation challenges.

#Q2. Set the working directory to the "WK6" folder and create a connection to the "phc6194db" database in postgresql. (4 pts)
setwd(paste(directory, 'WK6/', sep = "")) # Set wd to project repository
con_1 = dbConnect(dbDriver("PostgreSQL"), dbname = "phc6194db", host = "localhost", user = "phc6194", password = "vmuser") # create a connection to the postgres database
sql = 'DROP SCHEMA IF EXISTS wk6 CASCADE; CREATE SCHEMA wk6;'
dbSendQuery(con_1, sql)

#Q3. Retrieve the three tables you created in Assignment 2 ("wk5.flbg", "wk5.publix", and "wk5.school") from the PostGIS and import them as Spatial*DataFrame objects in R (name them as "flbg", "publix", and "school", respectively). Hint: you can use the pgGetGeom() function. Please use the "pt_ggmap" as the geometry column for "wk5.publix" and "wk5.school" when importing them. (5 pts)
flbg = readOGR(dsn = "data/flbg.geojson", encoding = "OGRGeoJSON")
publix = readOGR(dsn = "data/publix.geojson", encoding = "OGRGeoJSON")
school = readOGR(dsn = "data/school.geojson", encoding = "OGRGeoJSON")

#Q4. Create a basic map using plot() function on "flbg", and print out the first 6 rows of the non-spatial data in "flbg". (2 pts)

head(flbg)

#Q5. Print out the SRS of "flbg". (3 pts)
flbg@proj4string

#Q6. You can see that "flbg" includes all block groups in FL. Please find a way to keep only the block groups in Alachua County, and save them as "alachuabg". Print out the first 6 rows of the nonspatial data in "alachuabg". (10 pts)
alachuabg = flbg[flbg$countyfp == "001"] # based on variable values

########################################
#Part 2. Visualization using R (25 pts)#
########################################

#Q7. Please make a map using "alachuabg", "publix", and "school" using ggmap, ggplot2, and ggsn packages in R. Please try to make it look as similar as you can to the example attached on canvas (colors do not need to be the same). (25 pts) 


map1<-ggplot()+geom_polygon(data=alachuabg,aes(long,lat,group=group,fill=aland,alpha=0.3))+geom_path(color="white")+coord_equal()+theme(panel.background=element_blank(),axis.title=element_blank(),axis.text=element_blank(),axis.ticks = element_blank())+scale_fill_gradientn("Land Area",colours=c("#DFEBF7","#11539A"))
map1

map2<-map1+geom_point(data=school@data,aes(x=lon_ggmap,y=lat_ggmap,group=id,col=type),size=2)+labs(col="Type")
map2

map3<-map2+geom_point(data=publix@data,aes(x=lon_ggmap,y=lat_ggmap,group=id,col=type),size=2)+labs(col="Type")
map3

map4<-map3+north(flbg_f,scale=0.2,symbol=3,location="topright")+scalebar(flbg_f,location="bottomleft",transform=T,dist_unit="mi",model="WGS84",dist=10,st.dist = 0.05)
map4

#export the map as a png image
ggsave("map.png",dpi=300)

###########################################
#Part 3. Visualization using QGIS (25 pts)#
###########################################

#Q8. Export "alachuabg" to PostGIS as "wk6.alachuabg". (5 pts)

pgInsert(con_1,c('wk6','alachuabg'), alachuabg, geom = 'geom_pt', overwrite = TRUE, row.names = FALSE)

#Q9. Please use QGIS to make a map using "wk6.alachuabg", "wk5.publix", and "wk5.school", and try to make it look as similar as you can to the example attached on canvas (colors do not need to be the same). Save your map as a png image, and attach it in your submission. (20 pts)

############################################
#Part 4. Visualization using Carto (30 pts)#
############################################

#Q10. Output "alachuabg", "publix", "school" as KML in the "WK6" folder. (5 pts)

proj4string(alachuabg) = CRS("+init=epsg:4326")
writeOGR(alachuabg, dsn = "data/rptdf.kml", layer = "alachuabg", driver = "KML")

#Q11. Please use Carto to make an interactive map using the KML files exported in Q10, and try to make the interactive map as similar as the example here: https://huihu.carto.com/builder/1349ea86-ba71-47e9-a1ea-939dc1561691/embed Please include the link to your map in your submission. (25 pts)

