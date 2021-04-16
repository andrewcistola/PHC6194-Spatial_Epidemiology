# allocativ 3001.2021

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
