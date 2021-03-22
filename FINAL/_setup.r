# allocativ v3.0.21

## Local
local = '/home/drewc/GitHub/PHC6194/' # Input local path to directory where allocativ folder was placed
title = 'Finding Equity' # Input basic title
descriptive = '- Social Determinants Associated with ' # Input descriptive title
outcome = 'Estimated Mental Health Status' # Description of dependent variable
author = 'Andrew S. Cistola, MPH' # Input full legal name of author
subject = 'FINAL/' # Input an informative short directory label for the subject of the analysis
DV = 'mhlth_crudeprev' # Column name for dependent variable in public data file
key_census = 'c82350b0bbe6c8a46ce163365ee3f2abcd16253e'
reference = 'PLACES Project. Centers for Disease Control and Prevention. https://www.cdc.gov/places'

## Libraries
library(RSQLite) # SQLite databases in R
library(RPostgreSQL) # Postgre SQL databases in R
library(rpostgis) # PostGIS with Postgres in R
library(sp) # S4 classes for spatial data in R
library(lme4) # Linear mixed effect modeling in R
library(arm) # Visualizations of linear mixed effect modeling using 'lme4' in R
library(reshape2) # Long/wide conversions from Hadley Wickham
library(plyr) # Data manipulation from Hadley Wickham 
library(ggplot2) # General use plotting library from Hadley Wickham
library(ggmap) # General use mapping library with ggplot API
library(RColorBrewer) # Creates nice looking color palettes especially for thematic maps in R
library(rgdal)
library(rgeos) 
library(maptools) 
library(ggsn)
library(spdep)  
library(DCluster)  
library(gstat) 
library(tigris)  
library(raster)  
library(dismo)  
library(rgeos)
library(sqldf)
library(smacpod)
library(rsatscan)
library(spatstat)


## Variables
day = Sys.Date() # Save dimple date as string
stamp = date() # Save Date and timestamp
directory = paste(local, subject, day, sep = "") # Set wd to project repository using variables

## Directories
setwd(directory) # Set working directory

## Database
con_1 = dbConnect(RSQLite::SQLite(), '_data/public.db') # create a connection to the postgres database
