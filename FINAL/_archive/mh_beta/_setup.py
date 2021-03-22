# Healthy neighborhoods Repository
## 2021 Release, version 1.1
### Setup Script - Import libraries and set variables

# Import allocativ Libraries

## Import python libraries
import os # Operating system navigation
from datetime import datetime # Date and time stamps
from datetime import date # Date stamps
import sqlite3 # SQLite database manager
import urllib.request # Url requests with file download functions
from zipfile import ZipFile # Compressed and archive manager in python

## Import data science libraries
import pandas as pd # Widely used data manipulation library with R/Excel like tables named 'data frames'
import numpy as np # Widely used matrix library for numerical processes

## Import statistics libraries
import scipy.stats as st # Statistics package best for t-test, ChiSq, correlation
import statsmodels.api as sm # Statistics package best for regression models

## Import Visualization Libraries
import matplotlib.pyplot as plt # Comprehensive graphing package in python
import geopandas as gp # Simple mapping library for csv shape files with pandas like syntax for creating plots using matplotlib 

## Import scikit-learn libraries
from sklearn.preprocessing import StandardScaler # Standard scaling for easier use of machine learning algorithms
from sklearn.impute import SimpleImputer # Univariate imputation for missing data
from sklearn.decomposition import PCA # Principal compnents analysis from sklearn
from sklearn.ensemble import RandomForestRegressor # Random Forest regression component
from sklearn.feature_selection import RFECV # Recursive Feature elimination with cross validation
from sklearn.svm import LinearSVC # Linear Support Vector Classification from sklearn
from sklearn.linear_model import LinearRegression # Used for machine learning with quantitative outcome
from sklearn.linear_model import LogisticRegression # Used for machine learning with quantitative outcome
from sklearn.model_selection import train_test_split # train test split function for validation
from sklearn.metrics import roc_curve # Reciever operator curve
from sklearn.metrics import auc # Area under the curve 

## Import PySAL Libraries
import libpysal as ps # Spatial data science modeling tools in python
from mgwr.gwr import GWR, MGWR # Geographic weighted regression modeling tools
from mgwr.sel_bw import Sel_BW # Bandwidth selection for GWR

## Import keras libraries
from keras.models import Sequential # Uses a simple method for building layers in MLPs
from keras.models import Model # Uses a more complex method for building layers in deeper networks
from keras.layers import Dense # Used for creating dense fully connected layers
from keras.layers import Input # Used for designating input layers

# Set Variables

## Descriptive Variables
title = 'PHC6194 Final Project' # Input basic title
descriptive = '- Social Detrerminants Associated with Mental Health Status' # Input descriptive title
author = 'Andrew S. Cistola, MPH' # Input author information
address = 'hhtps://github.com/andrewcistola/healthyneighborhoods' # Input GitHub repository or private network address
user = 'Andrew S. Cistola, MPH; https://github.com/andrewcistola' # Input name and GitHub profile or institutional email of user

## Timestamp Variables
day = '_' + str(date.today()) # Save date stamp for use in file names
stamp = str(datetime.now()) # Save full timestamp for output files

## Path Variables
name = 'mh_beta' # Input generic file name with subject and version
project = 'FINAL/' # Input project file name inside repository
repo = 'PHC6194/' # Input repository filename
local = '/home/drewc/GitHub/' # Input local path to repository
directory = local + repo + project # Set wd to project repository using variables
label = name + day # Save path and label variables for use in output files associated with the script

## Set Working Directory and create subdirectories
os.chdir(directory) # Set wd as local path to repository
os.mkdir('_data') # Make data directory
os.mkdir('_shape') # Make data directory
os.mkdir('_results') # Make data directory

## Create to Local Database
con_1 = sqlite3.connect('_data/' + label + '.db') # Create local database file connection object
cur_1 = con_1.cursor() # Create cursor object for modidying connected database

### Write corresponding text file for collecting results
text_file = open('_results/' + label + '.txt', 'w') # Write new corresponding text file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.write('Title: ' + title + descriptive + '\n') # Script title
text_file.write('Author(s): ' + author + '\n') # Script Author
text_file.write('Address: ' + address + '\n\n') # Script Author
text_file.write('File Name: ' + name + '\n') # Script Author
text_file.write('Relative Path: ' + repo + project + '\n') # Script Author
text_file.write('Local Path: ' + local + '\n\n') # Directory used for script run
text_file.write('Time Run: ' + stamp + '\n') # Timestamp of script run
text_file.write('\n' + '####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file