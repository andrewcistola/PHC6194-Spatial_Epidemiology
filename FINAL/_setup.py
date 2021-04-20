# allocativ 3001.2021

## Libraries
import os # Operating system navigation
from datetime import datetime # Date and time stamps
from datetime import date # Date stamps
import sqlite3 # SQLite database manager
import urllib.request # Url requests with file download functions
from zipfile import ZipFile # Compressed and archive manager in python
import pandas as pd # Widely used data manipulation library with R/Excel like tables named 'data frames'
import numpy as np # Widely used matrix library for numerical processes
import scipy.stats as st # Statistics package best for t-test, ChiSq, correlation
import statsmodels.api as sm # Statistics package best for regression models
import matplotlib.pyplot as plt # Comprehensive graphing package in python
import geopandas as gp # Simple mapping library for csv shape files with pandas like syntax for creating plots using matplotlib 
from sklearn.preprocessing import StandardScaler # Standard scaling for easier use of machine learning algorithms
from sklearn.impute import SimpleImputer # Univariate imputation for missing data
from sklearn.decomposition import PCA # Principal compnents analysis from sklearn
from sklearn.ensemble import RandomForestRegressor # Random Forest regression component
from sklearn.feature_selection import RFECV # Recursive Feature elimination with cross validation
from sklearn.svm import LinearSVC # Linear Support Vector Classification from sklearn
from sklearn.svm import LinearSVR # Linear Support Vector Regression from sklearn
from sklearn.linear_model import LinearRegression # Used for machine learning with quantitative outcome
from sklearn.linear_model import LogisticRegression # Used for machine learning with quantitative outcome
from sklearn.model_selection import train_test_split # train test split function for validation
from sklearn.metrics import roc_curve # Reciever operator curve
from sklearn.metrics import auc # Area under the curve 
import libpysal as ps # Spatial data science modeling tools in python
from mgwr.gwr import GWR, MGWR # Geographic weighted regression modeling tools
from mgwr.sel_bw import Sel_BW # Bandwidth selection for GWR
from keras.models import Sequential # Uses a simple method for building layers in MLPs
from keras.models import Model # Uses a more complex method for building layers in deeper networks
from keras.layers import Dense # Used for creating dense fully connected layers
from keras.layers import Input # Used for designating input layers

# https://pypi.org/project/censusviz/

## Variables
day = str(date.today()) + '/' # Save date stamp for use in file names
stamp = str(datetime.now()) # Save full timestamp for output files
directory = local + subject + day # Set wd to project repository using variables

## Directories
os.chdir(local) # Set wd
os.mkdir(subject) # Make dir
os.chdir(local + subject) # Set wd a
os.mkdir(day) # Make dir
os.chdir(directory) # Set wd as full directory variable
os.mkdir('_data') # Make data directory
os.mkdir('_shape') # Make shapefile directory
os.mkdir('_label') # Make label directory
os.mkdir('_fig') # Make figure directory

## Databases
con_1 = sqlite3.connect('_data/' + 'public' + '.db') # Create local database file connection object
cur_1 = con_1.cursor() # Create cursor object for modidying connected database

## Summary
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.write('Title: ' + title + descriptive + outcome + '\n') # Script title
text_file.write('Author(s): ' + author + '\n\n') # Project Author(s)
text_file.write('Local Path: ' + directory + '\n') # Directory used for script run
text_file.write('Time Run: ' + stamp + '\n') # Timestamp of script run
text_file.write('\n' + '####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file