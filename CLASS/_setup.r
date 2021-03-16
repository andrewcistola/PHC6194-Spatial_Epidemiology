# PHC6194
## Setup Script

# Variables
title = 'UF PHC6194 SPR2021' # Input basic title
descriptive = '- Lab and Assignment Setup Script' # Input descriptive title
author = 'Andrew S. Cistola, MPH' # Input author information
GH = 'https://github.com/andrewcistola/PHC6194' # Input GitHub repository
project = 'CLASS/' # Input project file name inside repository
repo = 'PHC6194/' # Input repository filename
local = '/home/drewc/GitHub/' # Input local path to repository
directory = paste(local, repo, project, sep = "") # Set wd to project repository using variables
day = Sys.Date() # Save dimple date as string
stamp = date() # Save Date and timestamp

# Libraries
library(ggplot2) # General use plotting library from Hadley Wickham
library(reshape2) # Library for long/wide conversions from Hadley Wickham
library(RPostgreSQL) # Library for using postgre SQL databases in R
library(ggmap) # General use mapping library with ggplot API
library(rpostgis) 
library(sp) 
library(rgdal)
library(ggplot2) # General use plotting library from Hadley Wickham
library(rgeos) 
library(maptools) 
library(ggsn)
library(plyr) # dplyr provides a grammar of data manipulation, providing a consistent set of verbs that solve the most common data manipulation challenges.
library(spdep)  
library(RColorBrewer)  
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

# Directories
setwd(directory) # Set working directory

# Quick Plots
png('quick_plot.png') # Open file
plot(qp) # Plot quick plot object
dev.off() # Close file


