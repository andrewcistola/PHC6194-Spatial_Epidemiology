# allocativ 3001.2021.0002

## Learn Step 1: Data Processing of Predictors and Outcomes
ls1 = 'Model Step 1: Raw Data Processing and Feature Engineering' # Step 1 descriptive title
lf1 = 'CENSUS_ACS_2019_ZCTA' # Dataset 2 file label

### Import and Join to Create Labels Outcomes (WY)
df_W = pd.read_csv('_data/FIPS_ZCTA.csv') # Import dataset from _data folder
df_X = pd.read_sql_query('SELECT * FROM ' + lf1, con_1) # Read table from SQlite db file into pandas dataframe
df_Y = pd.read_csv('_data/_spatial_ZCTA.csv') # Import dataset from _data folder
df_WX = pd.merge(df_W, df_X, on = 'ZCTA', how = 'left') # Merge data frame into data slot in SpatialDataFrame
df_WXY = pd.merge(df_WX, df_Y, on = 'ZCTA', how = 'left') # Merge data farem into data slot in SpatialDataFrame
df_WXY = df_WXY[df_WXY.ST == ST] # Drop rows by condition
df_WXY.info() # Verify

### Create Outcome Predictor Table (XY)
X = df_X.columns.tolist() # Save column names as list
X.append('crude') # Append item to end of list
df_XY = df_WXY.filter(X) # Subset data frame by list of columns
df_XY = df_XY.set_index('ZCTA') # Reset Index
df_WXY = df_WXY.set_index('ZCTA') # Reset Index
df_XY = df_XY.dropna(subset = ['crude']) # Define in which columns to look for missing values:
df_XY.info() # Get class, memory, and column info: names, data types, obs.

### Create Outcome table (Y)
df_Y = df_XY.filter(['crude']) # Create Outcome table
df_Y.info() # Get class, memory, and column info: names, data types, obs.

### Create standard scaled Predictor table (X)
df_X = df_XY.drop(columns = ['crude']) # Drop Unwanted Columns
df_X = df_X.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X = df_X.dropna(axis = 1, thresh = 0.75*len(df_X)) # Drop features less than 75% non-NA crude for all columns
df_X = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X), columns = df_X.columns) # Impute missing data
df_X = pd.DataFrame(StandardScaler().fit_transform(df_X.values), columns = df_X.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X.index = df_XY.index # Save ZCTA as column in predictor table
df_X.info() # Get class, memory, and column info: names, data types, obs.

### Add feature labels
df_l1 = pd.read_csv('_label/' + lf1 + '.csv') # Import dataset from _data folder
df_l2 = pd.read_csv('_label/' + lf2 + '.csv') # Import dataset from _data folder
df_L = pd.concat([df_l1, df_l2]) # Combine rows with same columns
df_L = df_L.set_index('Feature') # Set column as index
df_L = df_L.transpose() # Switch rows and columns
df_L.info # Get class, memory, and column info: names, data types, obs.

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ls1 + '\n\n') # Step description
text_file.write('Target labels: ' + outcome + '\n') # Dataset methods description
text_file.write('Target processing: nonNA' + '\n\n') # Dataset methods description
text_file.write(str(df_Y.describe())  + '\n\n') # Result descriptive statistics for target
text_file.write('Features labels: ACS Percent Estimates' + '\n') # Result description
text_file.write('Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled' + '\n\n') # Dataset methods description
text_file.write('Rows, Columns: ' + str(df_X.shape) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Learn Step 2: Identify Predictors
ls2 = "Learn Step 2: Identify Predictors with Open Models" # Step 2 descriptive title
m1 = "Principal Component Analysis" # Model 1 descriptive title
m2 = "Random Forests" # Model 2 descriptive title
m3 = "Recursive feature Elimination" # Model 3 descriptive title

### Principal Component Analysis
pca = PCA(n_components = 'mle') # Pass the number of components to make PCA model based on degrees of freedom
pca.fit(df_X) # Fit initial PCA model
df_comp = pd.DataFrame(pca.explained_variance_) # Print explained variance of components
df_comp = df_comp[(df_comp[0] > 1)] # Save eigenvalues above 1 to identify components
components = len(df_comp.index) - 1 # Save crude of components for Variable reduction
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
forest.fit(df_X, df_Y['crude']) # Fit Forest model, This will take time
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
recursive.fit(df_X[fracture], df_Y['crude']) # This will take time
rfe = recursive.ranking_ # Save Boolean values as numpy array
l_rfe = list(zip(df_X[fracture], rfe)) # Create list of variables alongside RFE value 
df_rfe = pd.DataFrame(l_rfe, columns = ['Feature', 'RFE']) # Create data frame of importances with variables and gini column names
df_rfe = df_rfe.sort_values(by = ['RFE'], ascending = True) # Sort Columns by Value
df_rfe = df_rfe[df_rfe['RFE'] == 1] # Select Variables that were True
df_rfe.info() # Get class, memory, and column info: names, data types, obs.

### FractureProof: Join RFE with Fracture
df_fp = pd.merge(df_fr, df_rfe, on = 'Feature', how = 'inner') # Join by column while keeping only items that exist in both, select outer or left for other options
fractureproof = df_fp['Feature'].tolist() # Save chosen featres as list
df_fp.info() # Get class, memory, and column info: names, data types, obs.

### Get FractureProof feature labels
df_lfp = df_L[fractureproof] # Save chosen featres as list
df_lfp = df_lfp.transpose() # Switch rows and columns
df_lfp = df_lfp.reset_index() # Reset index
l_lfp = list(zip(df_lfp['Feature'], df_lfp['Label'])) # Create list of variables alongside RFE value 
df_lfp.info() # Get class, memory, and column info: names, data types, obs.

### Add confounders to multiple regression model
df_select = df_X[fractureproof]
df_select.to_csv(path_or_buf = '_data/_learn_ZCTA.csv', index = True) # Clean in excel and select variable
df_select.info() # Get class, memory, and column info: names, data types, obs.

### Append step 4 results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ls2 + '\n\n') # Step description
text_file.write('Models: ' + m1 + ', ' + m2 + ', ' + m3 + '\n\n') # Model description
text_file.write('Values: Eigenvectors, Gini Impurity, Boolean' + '\n') # Model methods description
text_file.write('Thresholds: Mean, Mean, Cross Validation' + '\n\n') # Model methods description
text_file.write(str(df_fp)  + '\n\n') # Result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Layer Step 1: Data Processing of 2nd Geographic Layer
ys1 = 'Layer Step 1: Raw Data Processing and Feature Engineering (2nd Geographic Layer)' # Step 5 descriptive title
yf1 = 'HRSA_AHRF_2019_FIPS' # Dataset 2 file label

### Join Datasets by second layer identifier and define targets
df_W2 = pd.read_csv('_data/FIPS_ZCTA.csv') # Import dataset from _data folder
df_X2 = pd.read_csv('_data/' + yf1 + '.csv') # Import third dataset saved as csv in _data folder
df_Y2 = pd.read_csv('_data/_spatial_FIPS.csv') # Import dataset from _data folder
df_WX2 = pd.merge(df_W2, df_X2, on = 'FIPS', how = 'inner') # Join datasets to create table with predictors and outcome
df_WXY2 = pd.merge(df_WX2, df_Y2, on = 'FIPS', how = 'inner') # Join datasets to create table with predictors and outcome
df_WXY2 = df_WXY2[df_WXY2.ST == ST] # Drop rows by condition
df_WXY2 = df_WXY2.drop_duplicates(subset = 'FIPS', keep = 'first') # Drop all dupliacted values
df_WXY2.info() # Get class, memory, and column info: names, data types, obs.
df_WXY2.head() # Get class, memory, and column info: names, data types, obs.

### Create second layer standard scaled predictor table
df_X2 = df_WXY2[df_X2.columns]
df_X2 = df_X2.set_index('FIPS') # Set identifier as index
df_X2 = df_X2.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X2 = df_X2.dropna(axis = 1, thresh = 0.75*len(df_X2)) # Drop features less than 75% non-NA count for all columns
df_X2 = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X2), columns = df_X2.columns) # Impute missing data
df_X2 = pd.DataFrame(StandardScaler().fit_transform(df_X2.values), columns = df_X2.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X2['FIPS'] = df_WXY2['FIPS'] # Save ID as column in predictor table
df_X2 = df_X2.set_index('FIPS') # Set identifier as index
df_X2.info() # Get class, memory, and column info: names, data types, obs.

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ys1 + '\n\n') # Step description
text_file.write('Target labels: ' + outcome + '\n') # Dataset methods description
text_file.write('Target processing: nonNA' + '\n\n') # Dataset methods description
text_file.write(str(df_Y2.describe())  + '\n\n') # Result descriptive statistics for target
text_file.write('Features labels: AHRF Population Rates' + '\n') # Result description
text_file.write('Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled' + '\n\n') # Dataset methods description
text_file.write('Rows, Columns: ' + str(df_X2.shape) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Layer Step 2: Identify 2nd Layer Predictors
ys2 = 'Layer Step 2: Identify 2nd Layer Predictors' # Step 6 descriptive title
m1 = 'Support Vector Machines' # Model 6 descriptive title
yf2 = 'HRSA_AHRF_2019_FIPS'

### Support Vector Machines - Crude Rate
vector = LinearSVR() # Support vector machines with a linear kernel for multi-level categorical outrcomes
vector.fit(df_X2, df_Y2['crude']) # fit model
svm = vector.coef_ # Save coefficients for each category by feature
df_svm = pd.DataFrame(svm, index = df_X2.columns) # Create data frame of coefficients by 2nd layer features and 1st layer features
vector.fit(df_X2, df_Y2['SMR']) # fit model
df_svm['SMR'] = vector.coef_ # Save coefficients for each category by feature
vector.fit(df_X2, df_Y2['bayes']) # fit model
df_svm['bayes'] = vector.coef_ # Save coefficients for each category by feature
vector.fit(df_X2, df_Y2['LISA']) # fit model
df_svm['LISA'] = vector.coef_ # Save coefficients for each category by feature
vector.fit(df_X2, df_Y2['GWR']) # fit model
df_svm['GWR'] = vector.coef_ # Save coefficients for each category by feature
vector.fit(df_X2, df_Y2['gini']) # fit model
df_svm['gini'] = vector.coef_ # Save coefficients for each category by feature
df_svm = df_svm.abs() # Get absolute value of all coefficients
df_svm = df_svm.reset_index() # Reset index
df_svm = df_svm.rename(columns = {0: 'crude', 'index': 'Feature'}) # Rename multiple columns in place
df_svm['rank'] = df_svm['crude'] + df_svm['SMR'] + df_svm['bayes'] + df_svm['LISA'] + df_svm['GWR'] + df_svm['gini']
df_svm = df_svm.sort_values(by = ["rank"], ascending = False) # Sort Columns by Value
df_svm.head()
df_svm.describe(percentiles = [0.5, 0.75, 0.9, 0.95, 0.975])

### Svae features in 99th percentile
df_svm = df_svm[df_svm['rank'] > 0]
crude = df_svm[df_svm.crude >= df_svm.crude.quantile(0.999)].Feature.to_list()
SMR = df_svm[df_svm.SMR >= df_svm.SMR.quantile(0.999)].Feature.to_list()
bayes = df_svm[df_svm.bayes >= df_svm.bayes.quantile(0.999)].Feature.to_list()
LISA = df_svm[df_svm.LISA >= df_svm.LISA.quantile(0.999)].Feature.to_list()
GWR = df_svm[df_svm.GWR >= df_svm.GWR.quantile(0.999)].Feature.to_list()
gini = df_svm[df_svm.gini >= df_svm.gini.quantile(0.999)].Feature.to_list()
rank = df_svm[df_svm['rank'] >= df_svm['rank'].quantile(0.999)].Feature.to_list()
s_svm = pd.Series(crude + SMR + bayes + LISA + GWR + gini + rank).drop_duplicates()
s_svm.head() # Verify

### Export Selected Features to CSV
df_X2 = pd.read_csv('_data/' + yf2 + '.csv') # Import third dataset saved as csv in _data folder
df_X2 = df_X2.set_index('FIPS')
df_select = df_X2[s_svm.to_list()] # Subset original nonscaled data wth selected feature list
df_select.to_csv(path_or_buf = '_data/_learn_FIPS.csv', index = True) # Clean in excel and select variable
df_select.info() # Get class, memory, and column info: names, data types, obs.

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ys2 + '\n\n') # Step description
text_file.write('Models: ' + m1 + '\n\n') # Model description
text_file.write('Values: Coefficients' + '\n\n') # Model methods description
text_file.write(str(df_svm.describe(percentiles = [0.5, 0.75, 0.9, 0.95, 0.975]))  + '\n\n') # Result dataframe
text_file.write('County Features' + '\n\n') # Model methods description
text_file.write(str(s_svm)  + '\n\n') # Result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file


