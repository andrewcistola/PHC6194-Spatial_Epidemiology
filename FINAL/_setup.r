# allocativ 3001.2021

## Libraries
### Hadley Wickham
library(tidyverse) # All of the libraries above in one line of code
library(ggplot2) # ggplot2 is a system for declaratively creating graphics, based on The Grammar of Graphics. You provide the data, tell ggplot2 how to map variables to aesthetics, what graphical primitives to use, and it takes care of the details.
library(dplyr) # dplyr provides a grammar of data manipulation, providing a consistent set of verbs that solve the most common data manipulation challenges.
library(tidyr) # tidyr provides a set of functions that help you get to tidy data. Tidy data is data with a consistent form: in brief, every variable goes in a column, and every column is a variable.
library(readr) # readr provides a fast and friendly way to read rectangular data (like csv, tsv, and fwf). It is designed to flexibly parse many types of data found in the wild, while still cleanly failing when data unexpectedly changes.
library(purrr) # purrr enhances R’s functional programming (FP) toolkit by providing a complete and consistent set of tools for working with functions and vectors. Once you master the basic concepts, purrr allows you to replace many for loops with code that is easier to write and more expressive.
library(tibble) # tibble is a modern re-imagining of the data frame, keeping what time has proven to be effective, and throwing out what it has not. Tibbles are data.frames that are lazy and surly: they do less and complain more forcing you to confront problems earlier, typically leading to cleaner, more expressive code.
library(stringr) # stringr provides a cohesive set of functions designed to make working with strings as easy as possible. It is built on top of stringi, which uses the ICU C library to provide fast, correct implementations of common string manipulations.
library(forcats) # forcats provides a suite of useful tools that solve common problems with factors. R uses factors to handle categorical variables, variables that have a fixed and known set of possible values.
library(reshape2) # Long/wide conversions from Hadley Wickham
### DBMS
library(RSQLite) # SQLite databases in R
library(sqldf) # Use SQL commands on R dataframes
library(RPostgreSQL) # Postgre SQL databases in R
### Statistics
library(lme4) # Linear mixed effect modeling in R
library(arm) # Visualizations of linear mixed effect modeling using 'lme4' in R
library(lmtest) # Linear model tests including Breusch Pagan
library(lmerTest) # Linear mixed effect model tests allowing for Saittherwaier DOF and signficiance tests
library(DescTools) # Descriptive statistics including Jarque-Bera, Andrerson-Darling, Durbin-Watson, Cronbach's Alpha
library(ineq) # Gini coefficient and Lorenz curve
library(MASS) # Stepwise inclusion model with linear and logistic options and Box-Cox transformations
library(bestNormalize) # nromalization autmation including boxcox
library(performance) # Inter class correlation coefficient foir HLM
### Machine Learning
library(randomForest) # Popular random forest package for R
library(randomForestExplainer) # Complimentary to randfomForest package with tools for analysis
### Spatial
library(rpostgis) # PostGIS with Postgres in R
library(sp) # S4 classes for spatial data in R
library(ggmap) # General use mapping library with ggplot API
library(GWmodel) # Geographic weighted regression in R
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
library(smacpod)
library(rsatscan)
library(spatstat)
### Visualization
library(RColorBrewer) # Creates nice looking color palettes especially for thematic maps in R

## Variables
day = Sys.Date() # Save dimple date as string
stamp = date() # Save Date and timestamp
directory = paste(local, subject, day, sep = "") # Set wd to project repository using variables

## Directories
setwd(directory) # Set working directory

## Database
con_1 = dbConnect(RSQLite::SQLite(), '_data/public.db') # create a connection to the postgres database
