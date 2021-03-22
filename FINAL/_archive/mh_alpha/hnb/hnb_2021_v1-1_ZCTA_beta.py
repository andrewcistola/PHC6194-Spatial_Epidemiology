## Set Script variables
title = 'Healthy Neighborhoods Repository' # Input basic title
descriptive = '- 2021 Release by Zip Code and County' # Input descriptive title
author = 'Andrew S. Cistola, MPH' # Input author information
address = 'https://github.com/andrewcistola/healthyneighborhoods' # Input GitHub repository or private network address
name = 'hnb_2021_v1-1_ZCTA_beta' # Input generic file name with subject and version
project = 'FINAL/hnb/' # Input project file name inside repository
repo = 'PHC6194/' # Input repository filename
user = 'Andrew S. Cistola, MPH; https://github.com/andrewcistola' # Input name and GitHub profile or institutional email of user
local = '/home/drewc/GitHub/' # Input local path to repository
directory = local + repo + project # Set wd to project repository using variables

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

## Create Timestamps
day = '_' + str(date.today()) # Save date stamp for use in file names
stamp = str(datetime.now()) # Save full timestamp for output files

## Set Working Directory and path vairables
os.chdir(directory) # Set wd as local path to repository
path_label = local + repo + project + name + day # Save path and label variables for use in output files associated with the script

## Connect to Local Database
con_1 = sqlite3.connect(path_label + '.db') # Create local database file connection object
cur_1 = con_1.cursor() # Create cursor object for modidying connected database

### Write corresponding text file for collecting results
text_file = open(path_label + '.txt', 'w') # Write new corresponding text file
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

## Step 1: Pull 1st Dataset from API
s1 = 'Step 1: Pull and Clean First Datasource from API' # Step 1 descriptive title
d1 = 'Dataset: CDC PLACES 2020 Release by Zip Code' # Dataset 1 descriptive title
f1 = 'CDC_PLACES_2019_ZCTA' # Dataset 2 file label

### Dataset 1 API Query (CSV)
query_d1 = ("https://chronicdata.cdc.gov/resource/kee5-23sr.csv?"
    "&$$app_token=YmHGXtIwwRViIV4urwHNCAv0h"
    "&$limit=40000") # Save API as query
df_d1_API = pd.read_csv(query_d1) # Create data frame from APi query
df_d1_API.to_sql((f1 + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d1_API.head() # Print first 5 observations
df_d1_API.info() # Get class, memory, and column info: names, data types, obs.

### Keep Values of Interest
df_d1 = df_d1_API.set_index('zcta5') # Set column as index
df_d1 = df_d1.loc[:, df_d1.columns.str.contains('prev')] # Select columns by string value
df_d1 = df_d1.reset_index() # Reset Index
df_d1.head() # Print first 5 observations
df_d1.info() # Get class, memory, and column info: names, data types, obs.

### Create Standardized labels
df_l1 = pd.DataFrame(df_d1.columns) # Save as Pandas dataframe
df_l1 = df_l1.reset_index() # Reset Index
df_l1 = df_l1.reset_index() # Reset Index
df_l1 = df_l1.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l1 = df_l1.astype('str') # Change data type of column in data frame
df_l1['Feature'] = 'D1_' + df_l1['Feature'] # Append string to all rows in column
df_l1['Description'] = f1 + '_' + df_l1['Label'] # Append string to all rows in column
df_l1 = df_l1.set_index('Feature') # Set column as index
df_l1.to_sql((f1 + '_labels'), con_1, if_exists = 'replace', index = 'Feature') # Export dataframe to SQL database
df_l1 = pd.read_sql_query('SELECT * FROM ' + f1 + '_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_l1.head() # Print first 5 observations
df_l1.info() # Get class, memory, and column info: names, data types, obs.

### Create Standard Column Names
df_d1['zcta5'] = df_d1['zcta5'].astype('str') # Change data type of column in data frame
df_d1['zcta5'] = df_d1['zcta5'].str.rjust(5, "0") # add leading zeros of character column using rjust() function
df_d1 = df_d1.transpose() # Transpose Rows and Columns
df_d1 = df_d1.reset_index() # Set observatyion label column as index
df_d1 =  df_d1.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_l1 = df_l1.reset_index() # Set observatyion label column as index
df_d1 = pd.merge(df_l1, df_d1, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_l1 = df_l1.set_index('Feature') # Set column as index
df_d1 = df_d1.drop(columns = ['Label', 'Description']) # Drop Unwanted Columns
df_d1 = df_d1.set_index('Feature') # Set column as index
df_d1 = df_d1.transpose() # Transpose Rows and Columns
df_d1 = df_d1.rename(columns = {'D1_0': 'ZCTA'}) # Rename multiple columns in place
df_d1['ZCTA'] = 'ZCTA' + df_d1['ZCTA'] 
df_d1 = df_d1.set_index('ZCTA') # Set column as index
df_d1 = df_d1.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d1.columns.name = None
df_d1.to_sql((f1 + '_stage'), con_1, if_exists = 'replace', index = 'ZCTA') # Export dataframe to SQL database
df_d1 = pd.read_sql_query('SELECT * FROM ' + f1 + '_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d1.head() # Print first 5 observations
df_d1.info() # Get class, memory, and column info: names, data types, obs.

### Append step 1 results to corresponding text file
text_file = open(path_label + '.txt', 'a') # Open corresponding text file
text_file.write(s1 + '\n\n') # Step description
text_file.write(d1 + '\n\n') # Dataset description
text_file.write('Feature labels located in `' + f1 + '_staged` table\n') # Result description and result dataframe
text_file.write('Raw data located in `' + f1 + '_raw` table\n') # Result description and result dataframe
text_file.write('Staged data located in `' + f1 + '_labels` table\n\n') # Result description and result dataframe
text_file.write('Observations and variables: ' + str(df_d1.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_d1.head()) + '\n\n') # Result description and result dataframe
text_file.write(str(df_l1.head()) + '\n\n') # Print all rows in Labels dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Step 2: Pull 2nd Dataset from API
s2 = 'Step 2: Pull and Clean Second Datasource from API' # Step 2 descriptive title
d2 = 'Dataset: CENSUS ACS 2020 Release by Zip Code' # Dataset 2 descriptive title
f2 = 'CENSUS_ACS_2019_ZCTA' # Dataset 2 file label

### Dataset 2, Table 1
d2_1 = 'Detailed Profile 2 (DP02) - Selected Social Characteristics'
table = '_DP02'
feature = 'D2-1_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP02)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e") # Save API query

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((f2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Description'] = f2 + '_' + df_l2['Label'] # Append string to all rows in column
df_l2.to_sql((f2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Description']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((f2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Dataset 2, Table 2
d2_2 = 'Detailed Profile 3 (DP03) - Selected Economic Characteristics'
table = '_DP03'
feature = 'D2-2_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP03)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e")

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((f2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Description'] = f2 + '_' + df_l2['Label'] # Append string to all rows in column
df_l2.to_sql((f2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Description']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((f2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Dataset 2, Table 3
d2_3 = 'Detailed Profile 4 (DP04) - Selected Housing Characteristics'
table = '_DP04'
feature = 'D2-3_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP04)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e")

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((f2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Description'] = f2 + '_' + df_l2['Label'] # Append string to all rows in column
df_l2.to_sql((f2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Description']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((f2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Dataset 2, Table 4
d2_4 = 'Detailed Profile 5 (DP05) - Selected Economic Characteristics'
table = '_DP05'
feature = 'D2-4_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP05)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e")

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((f2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Description'] = f2 + '_' + df_l2['Label'] # Append string to all rows in column
df_l2.to_sql((f2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Description']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((f2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Merge SQLite tables
df_d2_1 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP02_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2_2 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP03_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2_3 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP04_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2_4 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP05_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2 = pd.merge(df_d2_1, df_d2_2, on = 'ZCTA', how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = pd.merge(df_d2, df_d2_3, on = 'ZCTA', how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = pd.merge(df_d2, df_d2_4, on = 'ZCTA', how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2.to_sql((f2 + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2 = pd.read_sql_query('SELECT * FROM ' + f2 + '_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Merge SQLite label tables
df_l2_1 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP02_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2_2 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP03_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2_3 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP04_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2_4 = pd.read_sql_query('SELECT * FROM ' + f2 + '_DP05_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2 = pd.concat([df_l2_1, df_l2_2]) # Combine rows with same columns
df_l2 = pd.concat([df_l2, df_l2_3]) # Combine rows with same columns
df_l2 = pd.concat([df_l2, df_l2_4]) # Combine rows with same columns
df_l2.to_sql((f2 + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2 = pd.read_sql_query('SELECT * FROM ' + f2 + '_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

### Clean SQLite database and memory
cur_1.execute('DROP TABLE ' + f2 + '_DP02_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP03_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP04_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP05_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP02_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP03_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP04_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + f2 + '_DP05_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
df_d2_1 = 0 # Delete variable from memory
df_d2_2 = 0 # Delete variable from memory
df_d2_3 = 0 # Delete variable from memory
df_d2_4 = 0 # Delete variable from memory
df_l2_1 = 0 # Delete variable from memory
df_l2_2 = 0 # Delete variable from memory
df_l2_3 = 0 # Delete variable from memory
df_l2_4 = 0 # Delete variable from memory

### Append step 2 results to corresponding text file
text_file = open(path_label + '.txt', 'a') # Open corresponding text file
text_file.write(s2 + '\n\n') # Step description
text_file.write(d2 + '\n') # Dataset description
text_file.write('     Table 1: ' + d2_1 + '\n') # Dataset description
text_file.write('     Table 2: ' + d2_2 + '\n') # Dataset description
text_file.write('     Table 3: ' + d2_3 + '\n') # Dataset description
text_file.write('     Table 4: ' + d2_4 + '\n\n') # Dataset description
text_file.write('Raw data located in `' + f2 + '_DP0#_staged` tables\n') # Result description and result dataframe
text_file.write('Staged data located in `' + f2 + '_staged` table\n') # Result description and result dataframe
text_file.write('Feature labels located in `' + f2 + '_staged` table\n\n') # Result description and result dataframe
text_file.write('Observations and variables: ' + str(df_d2.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_d2.head()) + '\n\n') # Result description and result dataframe
text_file.write(str(df_l2.head()) + '\n\n') # Print all rows in Labels dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

# 3-11-21 DC!
# ASCII HRSA Data
# Geomtery data type SQLite

## Step 3: Pull 3rd Dataset from URL
s3 = 'Step 3: Pull 3rd Dataset from URL' # Step 3 descriptive title
d3 = 'Dataset: HRSA Area health Resource File' # Step 3 dataset description
f3 = 'HRSA_AHRF_2019_FIPS' # Dataset 2 file label
url3 = 'https://data.hrsa.gov/DataDownload/AHRF/AHRF_2019-2020.ZIP' # ASCII Format

### Get Dataset as Zip file from URL address, query 1
file_name, headers = urllib.request.urlretrieve(url3, directory + f3 + day + '.zip') # Get file from url and save at location
with ZipFile(directory + f3 + day + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_data/' + f3) # Extract all the contents of zip file in current directory
os.remove(directory + f3 + day + '.zip') # Delete original Zip folder

## Step _: Import Geographic Data from Shapefile
s_ = 'Step -: Add Geographic Data' # Step _ descriptive title
d_ = 'Dataset: CENSUS TIGER 2018 Shapefiles by Zip Code' # Step _ dataset description
f_ = 'CENSUS_TIGER_2018_ZCTA' # Dataset _ file label
url_ = 'https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_zcta510_500k.zip' # URl location of data download

### Get Dataset as Zip file from URL address
file_name, headers = urllib.request.urlretrieve(url_, directory + f- + day + '.zip') # Get file from url and save at location
with ZipFile(directory + f_ + day + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_shape' + f_) # Extract all the contents of zip file in current directory
os.remove(directory + f_ + day + '.zip') # Delete original Zip folder
gdf_d_ = gp.read_file(directory + '_shape/cb_2018_us_zcta510_500k.shp') # Import dataset saved as csv in _shape folder
gdf_d_['ZCTA'] = gdf_d_['ZCTA5CE10'].astype('str') # Change data type of column in data frame
gdf_d_['ZCTA'] = gdf_d_['ZCTA'].str.rjust(5, '0') # add leading zeros of character column using rjust() function
gdf_d_['ZCTA'] = 'ZCTA' + gdf_d_['ZCTA']
gdf_d_ = gdf_d_.filter(['ZCTA', 'geometry']) # Keep only selected columns
gdf_d_.info() # Get class, memory, and column info: names, data types, obs.

### Create centroids
gdf_d_['x'] = gdf_d_['geometry'].centroid.x # Save centroid coordinates as separate column
gdf_d_['y'] = gdf_d_['geometry'].centroid.y # Save centroid coordinates as separate column
gdf_d_['coordinates'] = list(zip(gdf_d_['x'], gdf_d_['y'])) # Save individual coordinates as column of paired list
gdf_d_ = gdf_d_.drop(columns = ['x', 'y']) # Drop Unwanted Columns
gdf_d_.info() # Get class, memory, and column info: names, data types, obs.

### Append step _ results to corresponding text file
text_file = open(path_label + '.txt', 'a') # Open corresponding text file
text_file.write(s_ + '\n\n') # Step description
text_file.write(d_ + '\n\n') # Dataset description
text_file.write(f_ + '\n\n') # Filename description
text_file.write(str(gdf_d_.head()) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

# 3-11-21 DC!