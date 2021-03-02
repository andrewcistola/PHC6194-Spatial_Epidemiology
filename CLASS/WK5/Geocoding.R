library(rpostgis)
library(RPostgreSQL)
library(sp) 

setwd("/home/vmuser/Desktop/PHC6194SPR2021/WK5/data")

#Part 1

#create a connection
#save the password
pw <- "vmuser"

#load the postgresql driver
drv<-dbDriver("PostgreSQL")

#create a connection to the postgres database
con<-dbConnect(drv,dbname="phc6194db",host="localhost",user="phc6194",password=pw)

#create a schema to house the data for this week
q<-"
DROP SCHEMA IF EXISTS wk5 CASCADE;
CREATE SCHEMA wk5;
"
dbSendQuery(con,q)

#create a table
q<-"
CREATE TABLE wk5.gnvadd (
  addid serial NOT NULL PRIMARY KEY,
  rating integer,
  address text,
  norm_address text,
  pt geometry
);
INSERT INTO wk5.gnvadd(address) VALUES
  ('ONE SW Archer Road, GAINESVILLE, FL 32608'),
  ('1600 SW Archer Road, Gainesville, FL 32608')
;"
dbSendQuery(con,q)

q<-"
SELECT * FROM wk5.gnvadd;
"
dbGetQuery(con,q)

#normalize addresses using normalize_address function (this generates a norm_addy obejct)
q<-"
SELECT normalize_address(address) AS addy
FROM wk5.gnvadd;
"
dbGetQuery(con,q)

#normalize using the PAGC address normalizer (this also generates a norm_addy obejct)
q<-"
WITH A AS (
  SELECT pagc_normalize_address(address) AS addy
  FROM wk5.gnvadd
)
SELECT 
  (addy).address AS num,
  (addy).predirabbrev AS pre,
  (addy).streetname || ' ' || (addy).streettypeabbrev AS street,
  (addy).location AS city,
  (addy).stateabbrev AS st
FROM A;
"
dbGetQuery(con,q)

#normalize using standardize_address (this is faster than pagc_normalize_address, but it generates a stdaddr object, which needs to be further converted to norm_addy object to be used by the PostGIS geocoder)
#more detail: https://postgis.net/docs/stdaddr.html
q<-"
SELECT (s).house_num, (s).name, (s).predir,(s).suftype,(s).sufdir, (s).city, (s).state, (s).postcode
FROM (
  SELECT standardize_address(
    'pagc_lex','pagc_gaz','pagc_rules',address
  ) AS s
  FROM wk5.gnvadd
) AS X;
"
dbGetQuery(con,q)

#Geocoding
#by default, if passing an address string to postgis, it will use the normalize_address function before geocoding
#we can also switch the default function to pagc_normalize_address by running the following code in terminal:
#sudo -u postgres psql -c "SELECT set_geocode_setting('use_pagc_address_parser','true');" phc6194db

#we can also switch back to the normalize_address
#sudo -u postgres psql -c "SELECT set_geocode_setting('use_pagc_address_parser','false');" phc6194db

#geocoding using address text
#the higher the rating, the worse the match
q<-"
SELECT
  g.rating AS r,
  ST_X(geomout) AS lon,
  ST_Y(geomout) AS lat,
  pprint_addy(addy) AS paddress
FROM
  geocode(
    '1600 SW Archer Road, Gainesville, FL 32608'
  ) AS g;
"
dbGetQuery(con,q)

#geocoding using normalized addresses, this lets you swap in a different normalizer
q<-"
SELECT g.rating AS r, ST_X(geomout) AS lon, ST_Y(geomout) AS lat
FROM geocode(
  pagc_normalize_address(
    '1600 SW Archer Road, Gainesville, FL 32608'
  )
) AS g;
"
dbGetQuery(con,q)

#batch geocoding
#make sure to switch the default function to pagc_normalize_address in terminal:
#sudo -u postgres psql -c "SELECT set_geocode_setting('use_pagc_address_parser','true');" phc6194db

#COALESCE() function replaces NULL with the value specified
#LIMIT 100 sets the batch size to 100

q<-"
UPDATE wk5.gnvadd
SET (rating,norm_address,pt) = (COALESCE((g).rating,-1),pprint_addy((g).addy), (g).geomout)
FROM
  (SELECT * FROM wk5.gnvadd WHERE rating IS NULL LIMIT 100) AS a
  LEFT JOIN
  (SELECT addid, geocode(address,1) AS g FROM wk5.gnvadd AS ag WHERE rating IS NULL) AS g1
  ON a.addid = g1.addid
WHERE a.addid=wk5.gnvadd.addid;
"
dbSendQuery(con,q)

q<-"SELECT *, ST_X(pt),ST_Y(pt) FROM wk5.gnvadd;"
dbGetQuery(con,q)

# Part 2
library(ggmap)
register_google(key = '')

#get the data from postgis
q<-"SELECT addid, address, ST_X(pt) AS tigerlon, ST_Y(pt) as tigerlat FROM wk5.gnvadd;"
dat<-dbGetQuery(con,q)
dat

#use the geocode function
geocode(dat$address)

#a more complex function that will process google server response and retrieve more detailed information
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

batchsize<-1

# a loop to geocoding
for (j in seq(1,2)){
  
  #initialise a dataframe to hold the results
  geocoded <- data.frame()
  
  #temp file location
  tempfilename <- paste0("_temp_geocoded_",j,".rds")
  
  # find out where to start in the address list (if the script was interrupted before):
  startindex <- (j-1)*batchsize + 1
  endindex <- startindex + batchsize - 1
  if (endindex>length(dat$addid)) {
    endindex <- length(dat$addid)
  }
  
  # Start the geocoding process - address by address. geocode() function takes care of query speed limit.
  for (ii in dat$addid[startindex:endindex]){
    print(paste("Working on batch requests No.",j,", id", ii, ", last id to geocode:", dat$addid[endindex]))
    #query the google geocoder - this will pause here if we are over the limit.
    result = getGeoDetails(dat[dat$addid==ii,"address"]) 
    if (is.null(result$formatted_address)){
      result$formatted_address<-""
    }
    print(result$status)     
    result$addid <- ii
    #append the answer to the results file.
    geocoded <- rbind(geocoded, result)
    #save temporary results as we are going along
    saveRDS(geocoded, tempfilename)
  }
}

#merge geocoded data
geo<-readRDS("_temp_geocoded_1.rds")

for (j in 2:2){
  print(paste("Working on index", j))
  infile<-paste0("_temp_geocoded_",j,".rds")
  datatemp <- readRDS(infile)
  geo <- rbind(geo,datatemp)
}

geo
