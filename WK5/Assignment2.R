# title: Assignment 1: PHC 6194 - Spring 21
## author: Andrew S. Cistola MPH
## date: 2021-01-14 17:17:11 EST

# Part 1. Data Import (10 pts)

## Q1. Load the packages "RPostgreSQL" and "ggmap" (1 pt)
library(ggmap) # General use mapping library with ggplot API
citation("ggmap") # Citation for Hadley-Wickham libraries
library(RPostgreSQL) # General use mapping library with ggplot API

## Q2. Set the working directory to the "WK5" folder and import the data "gnvadd.csv" from the "data" folder as a dataframe named "dat". DO NOT import strings as factors. (2 pts)
setwd('/home/drewc/GitHub/_colab/PHC6194/_student/WK5') # Set wd to project repository
dat = read.csv("data/gnvadd.csv", stringsAsFactors = FALSE) # Import dataset from _data folder

## Q3. Print out the first 6 rows of "dat", and display the structure of "dat". (2 pts)
head(dat) # Print mini table with first 6 observations 
str(dat) # Show structure of dataframe

#Q4. Create a connection to the "phc6194db" database in postgresql, and export "dat" to the database as a table called "wk5.dat". DO NOT export row names. (4 pts)
dat = subset(dat, select = -c(id))
pw = "vmuser" # save the password
drv = dbDriver("PostgreSQL") # load the postgresql driver
con = dbConnect(drv, dbname = "phc6194db", host = "localhost", user = "phc6194", password = pw) # create a connection to the postgres database
dbWriteTable(con, 'wk5', dat, row.names = FALSE, append = TRUE) # Export R dataframe to SQL database

#Q5. Print out the first 6 rows of "wk5.dat" using a SQL query. (1 pt)
dbReadTable(con, 'wk5')
dbGetQuery(con, 'SELECT * FROM wk5 LIMIT 6')

#################################################
#Part 2. Geocoding Using TIGER Geocoder (15 pts)#
#################################################

#Q6. Add three new columns to "wk5.dat": "rating_tiger" (type: integer), "norm_address_tiger" (type:text), and "pt_tiger" (type:geometry), which will be used to store the rating of the geocoding (use -1 to replace missing values), the normalized address, and the geometry of the geocoded location. Print out the first 6 rows of "wk5.dat" to check. (5 pts)
q = 
'ALTER TABLE wk5 
ADD COLUMN rating_tiger INT, 
ADD COLUMN norm_address_tiger VARCHAR(20), 
ADD COLUMN pt_tiger POLYGON;'
dbSendQuery(con,q)
dbGetQuery(con, 'SELECT * FROM wk5 LIMIT 6')

#Q7. Batch geocoding "address" in "wk5.dat" using TIGER geocoder. Add three additional columns to the table: Please use a batch size=50. (8 pts)

q<-"
UPDATE wk5
SET (rating_tiger, norm_address_tiger, pt_tiger) = (COALESCE((g).rating,-1),pprint_addy((g).addy), (g).geomout)
FROM
  (SELECT * FROM wk5 WHERE rating_tiger IS NULL LIMIT 50) AS a
  LEFT JOIN
  (SELECT address, geocode(address,1) AS g FROM wk5 AS ag WHERE rating IS NULL) AS g1
  ON a.addid = g1.addid
WHERE a.address=wk5.address;
"
dbSendQuery(con,q)

#Q8. Print out the first 6 rows with all the columns as well as lon (name it as "lon_tiger") and lat (name it as "lat_tiger") of "pt_tiger". (2 pts)
dbGetQuery(con, 'SELECT * FROM wk5 LIMIT 6')

###########################################################
#Part 3. Geocoding Using Google Map Geocoding API (15 pts)#
###########################################################

#Q9. Now let's perform the geocoding using google map geocoding api through ggmap. Set the api key first. (2 pts)
register_google(key = '')


#Q10. Define the getGeoDetails() function. (1 pt)
geocode(wk5$address)

#Q11. Perform geocoding with a batch size=10. All temporary results should be saved in the "data" folder: e.g. "_temp_geocoded_dat_1.rds" for the first batch. (7 pts)

#Q12. Merge the temporary results and save it as a dataframe "geo". Print out the first 6 rows of geo. (5 pts)

############################################
#Part 4. Data Cleaning and Linkage (30 pts)#
############################################

#Q13. Export "geo" to postgresql database "phc6194db" and save it as a table "wk5.geo". DO NOT export row names. Print out the first 6 rows using a SQL query. (5 pts)

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


# References
## D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R Journal, 5(1), 144-161. URL http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf