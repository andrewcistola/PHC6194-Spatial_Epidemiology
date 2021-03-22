## Set Script variables
title = 'PHC6194 Final Project' # Input basic title
descriptive = '- Ecological Factors Associated with Mental Health Outcomes' # Input descriptive title
author = 'Andrew S. Cistola, MPH; Alyssa Berger, MPH' # Input author information
address = 'hhtps://github.com/andrewcistola/PHC6194' # Input GitHub repository or private network address
name = 'mh_gamma' # Input generic file name with subject and version
project = 'FINAL/mh/' # Input project file name inside repository
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

## Create Timestamps
day = '_' + str(date.today()) # Save date stamp for use in file names
stamp = str(datetime.now()) # Save full timestamp for output files

## Set Working Directory and path vairables
os.chdir(directory) # Set wd as local path to repository
path_label = local + repo + project + name + day # Save path and label variables for use in output files associated with the script

## Connect to Local Database
con_1 = sqlite3.connect(local + repo + 'FINAL/hnb/' + 'hnb_2021_v1-1_ZCTA_beta_2021-03-11.db') # Create local database file connection object
cur_1 = con_1.cursor() # Create cursor object for modidying connected database
cur_1.execute('SELECT name FROM sqlite_master WHERE type = "table";').fetchall() # Confirm data with list of table names

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

## Step 4: Data Processing of Predictors and Outcomes
s4 = 'Step 4: Raw Data Processing and Feature Engineering' # Step 1 descriptive title

### Import staged data tables
df_d1 = pd.read_sql_query('SELECT * FROM CDC_PLACES_2019_ZCTA_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2 = pd.read_sql_query('SELECT * FROM CENSUS_ACS_2019_ZCTA_stage', con_1) # Read table from SQlite db file into pandas dataframe

### Import label tables and export to CSV

### Join Datasets, apply standard labels, define target
df_XY = df_d1.filter(['D1_23', 'ZCTA']) # Create Outcome table
df_XY = pd.merge(df_XY, df_d2, on = 'ZCTA', how = 'inner') # Join datasets to create table with predictors and outcome
df_XY = df_XY.rename(columns = {'ZCTA': 'ID', 'D1_23': 'quant'}) # Apply standard name to identifier used for joining datasets and quantitative target 
df_XY = df_XY.dropna(subset = ['quant']) # Drop all outcome rows with NA values
df_XY = df_XY.set_index('ID') # Reset Index
df_XY.info() # Get class, memory, and column info: names, data types, obs.

### Create outcome table
df_Y = df_XY.filter(['quant']) # Create Outcome table
df_Y.info() # Get class, memory, and column info: names, data types, obs.

### Create standard scaled predictor table
df_X = df_XY.drop(columns = ['quant']) # Drop Unwanted Columns
df_X = df_X.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X = df_X.dropna(axis = 1, thresh = 0.75*len(df_X)) # Drop features less than 75% non-NA count for all columns
df_X = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X), columns = df_X.columns) # Impute missing data
df_X = pd.DataFrame(StandardScaler().fit_transform(df_X.values), columns = df_X.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X['ID'] = df_XY.index # Save ID as column in predictor table
df_X = df_X.set_index('ID') # Set identifier as index
df_X.info() # Get class, memory, and column info: names, data types, obs.

### Add feature labels
df_l1 = pd.read_sql_query('SELECT * FROM CDC_PLACES_2019_ZCTA_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2 = pd.read_sql_query('SELECT * FROM CENSUS_ACS_2019_ZCTA_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_label = pd.concat([df_l1, df_l2]) # Combine rows with same columns
df_label.to_csv(path_or_buf = path_label + '.csv', index = False) # Clean in excel and select variable
df_label = df_label.filter(['Feature', 'Label']) # Keep only selected columns
df_label = df_label.set_index('Feature') # Set column as index
df_label = df_label.transpose() # Switch rows and columns
df_label.info # Get class, memory, and column info: names, data types, obs.

### Append step 4 results to corresponding text file
text_file = open(path_label + '.txt', 'a') # Write new corresponding text file
text_file.write(s4 + '\n\n') # Step description
text_file.write('Target labels: quant = Mental health not good for ≥14 days among adults aged ≥18 years' + '\n') # Dataset methods description
text_file.write('Target processing: nonNA' + '\n\n') # Dataset methods description
text_file.write(str(df_Y.describe())  + '\n\n') # Result descriptive statistics for target
text_file.write('Features labels: ACS Percent Estimates' + '\n') # Result description
text_file.write('Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled' + '\n\n') # Dataset methods description
text_file.write('Rows, Columns: ' + str(df_X.shape) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Step 5: Identify Predictors
s5 = "Step 5: Identify Predictors with Open Models" # Step 2 descriptive title
m1 = "Principal Component Analysis" # Model 1 descriptive title
m2 = "Random Forests" # Model 2 descriptive title
m3 = "Recursive feature Elimination" # Model 3 descriptive title

### Principal Component Analysis
pca = PCA(n_components = 'mle') # Pass the number of components to make PCA model based on degrees of freedom
pca.fit(df_X) # Fit initial PCA model
df_comp = pd.DataFrame(pca.explained_variance_) # Print explained variance of components
df_comp = df_comp[(df_comp[0] > 1)] # Save eigenvalues above 1 to identify components
components = len(df_comp.index) - 1 # Save count of components for Variable reduction
pca = PCA(n_components = components) # you will pass the number of components to make PCA model
pca.fit_transform(df_X) # finally call fit_transform on the aggregate data to create PCA results object
df_pc = pd.DataFrame(pca.components_, columns = df_X.columns) # Export eigenvectors to data frame with column names from original data
df_pc["Variance"] = pca.explained_variance_ratio_ # Save eigenvalues as their own column
df_pc = df_pc[df_pc["Variance"] > df_pc["Variance"].mean()] # Susbet by eigenvalues with above average exlained variance ratio
df_pc = df_pc.abs() # Get absolute value of eigenvalues
df_pc = df_pc.drop(columns = ["Variance"]) # Drop outcomes and targets
df_p = pd.DataFrame(df_pc.max(), columns = ["MaxEV"]) # select maximum eigenvector for each feature
df_p = df_p[df_p.MaxEV > df_p.MaxEV.mean()] # Susbet by above average max eigenvalues 
df_p = df_p.reset_index() # Add a new index of ascending values, existing index consisting of feature labels becomes column named "index"
df_pca = df_p.rename(columns = {"index": "Feature"}) # Rename former index as features
df_pca = df_pca.sort_values(by = ["MaxEV"], ascending = False) # Sort Columns by Value
df_pca.info() # Get class, memory, and column info: names, data types, obs.

### Random Forest Regressor
forest = RandomForestRegressor(n_estimators = 1000, max_depth = 10) #Use default values except for number of trees. For a further explanation see readme included in repository. 
forest.fit(df_X, df_Y['quant']) # Fit Forest model, This will take time
rf = forest.feature_importances_ # Output importances of features
l_rf = list(zip(df_X, rf)) # Create list of variables alongside importance scores 
df_rf = pd.DataFrame(l_rf, columns = ['Feature', 'Gini']) # Create data frame of importances with variables and gini column names
df_rf = df_rf[(df_rf['Gini'] > df_rf['Gini'].mean())] # Subset by Gini values higher than mean
df_rf = df_rf.sort_values(by = ['Gini'], ascending = False) # Sort Columns by Value
df_rf.info() # Get class, memory, and column info: names, data types, obs.

### Fracture: Join RF and PCA 
df_fr = pd.merge(df_pca, df_rf, on = 'Feature', how = 'inner') # Join by column while keeping only items that exist in both, select outer or left for other options
fracture = df_fr['Feature'].tolist() # Save features from data frame
df_fr.info() # Get class, memory, and column info: names, data types, obs.

### Recursive Feature Elimination
recursive = RFECV(estimator = LinearRegression(), min_features_to_select = 5) # define selection parameters, in this case all features are selected. See Readme for more ifo
recursive.fit(df_X[fracture], df_Y['quant']) # This will take time
rfe = recursive.support_ # Save Boolean values as numpy array
l_rfe = list(zip(df_X[fracture], rfe)) # Create list of variables alongside RFE value 
df_rfe = pd.DataFrame(l_rfe, columns = ['Feature', 'RFE']) # Create data frame of importances with variables and gini column names
df_rfe = df_rfe.sort_values(by = ['RFE'], ascending = True) # Sort Columns by Value
df_rfe = df_rfe[df_rfe['RFE'] == True] # Select Variables that were True
df_rfe.info() # Get class, memory, and column info: names, data types, obs.

### FractureProof: Join RFE with Fracture
df_fp = pd.merge(df_fr, df_rfe, on = 'Feature', how = 'inner') # Join by column while keeping only items that exist in both, select outer or left for other options
fractureproof = df_fp['Feature'].tolist() # Save chosen featres as list
df_fp.info() # Get class, memory, and column info: names, data types, obs.

### Get FractureProof feature labels
df_lfp = df_label[fractureproof] # Save chosen featres as list
df_lfp = df_lfp.transpose() # Switch rows and columns
df_lfp = df_lfp.reset_index() # Reset index
l_lfp = list(zip(df_lfp['Feature'], df_lfp['Label'])) # Create list of variables alongside RFE value 
df_lfp.info() # Get class, memory, and column info: names, data types, obs.

### Append step 4 results to corresponding text file
text_file = open(path_label + '.txt', 'a') # Write new corresponding text file
text_file.write(s5 + '\n\n') # Step description
text_file.write('Models: ' + m1 + ', ' + m2 + ', ' + m3 + '\n\n') # Model description
text_file.write('Values: Eigenvectors, Gini Impurity, Boolean' + '\n') # Model methods description
text_file.write('Thresholds: Mean, Mean, Cross Validation' + '\n\n') # Model methods description
text_file.write(str(df_fp)  + '\n\n') # Result dataframe
text_file.write("Final list of selected features" + "\n") # Result description
text_file.write(str(l_lfp)  + '\n\n') # Result list
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Step 6: Create Informative Prediction Model
s6 = 'Step 6: Create Informative Preidction Model' # Step 3 descriptive title
m4 = 'Multiple Linear Regression Model' # Model 4 descriptive title

### Add confounders to multiple regression model
mrfractureproof = df_X[fractureproof].columns.to_list() # Save list of selected variables for multiple regression model

### Create Multiple Regression Model
df_mrfp_X = df_XY[mrfractureproof] # Subset original nonscaled data for regression
df_mrfp_X = df_mrfp_X.reset_index() # Reset index
df_mrfp_Y = df_Y.reset_index() # Reset index
df_mrfp_Y = df_mrfp_Y.filter(['quant', 'ID']) # Subset quantitative outcome for regression
df_mrfp = pd.merge(df_mrfp_X, df_mrfp_Y, on = 'ID', how = 'inner') # Join by column while keeping only items that exist in both, select outer or left for other options
df_mrfp = df_mrfp.dropna() # Drop all rows with NA values
X = df_mrfp.drop(columns = ['quant', 'ID']) # Susbet predictors for regression
Y = df_mrfp['quant'] # Subset quantitative outcome for regression
mod = sm.OLS(Y, X.astype(float)) # Create linear regression model
res = mod.fit() # Fit model to create result
res.summary() # Print results of regression model

### Add feature labels
mrfractureproof.remove('quant') # Remove outcome to list of features used for collecting lables
df_lmrfp = df_label[mrfractureproof] # Save selected features as list for collecting labels
mrfractureproof.append('quant') # Add outcome to to list of selected variables for multiple regression model
df_lmrfp = df_lmrfp.transpose() # Switch rows and columns
df_lmrfp = df_lmrfp.reset_index() # Reset index
l_lmrfp = list(zip(df_lmrfp['Feature'], df_lmrfp['Label'])) # Create list of variables alongside RFE value 
df_lmrfp.info() # Get class, memory, and column info: names, data types, obs.

### Append step 3 results to corresponding text file
text_file = open(path_label + '.txt', 'a') # Write new corresponding text file
text_file.write(s6 + '\n\n') # Step title
text_file.write('Models: ' + m4 + '\n\n') # Model description
text_file.write(str(res.summary())  + '\n\n') # Result summary
text_file.write(str(l_lmrfp)  + '\n\n') # Result list
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file