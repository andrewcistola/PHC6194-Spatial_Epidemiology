# FractureProof
## Version 3
### Model Script - Mr. FractureProof's Woodcarvings

## Layer Step 1: Geographic Weighted Regression
ls1 = 'Step 4: Geographic Weighted Regression' # Step 4 descriptive title
m5 = 'Multi-scale Geographic Weighted Regression' # Model 5 descriptive title

### Geojoin predictor and outcome table with polygons, Get centroid from coordinates
gdf_XY = gp.read_file(directory + '_shape/' + f4 + '/cb_2018_us_zcta510_500k.shp') # Import dataset saved as csv in _shape folder
gdf_XY['ID'] = gdf_XY['ZCTA5CE10'].astype('str') # Change data type of column in data frame
gdf_XY['ID'] = gdf_XY['ID'].str.rjust(5, '0') # add leading zeros of character column using rjust() function
gdf_XY['ID'] = 'ZCTA' + gdf_XY['ID'] # Combine string with column
gdf_XY = gdf_XY.filter(['ID', 'geometry']) # Keep only selected columns
gdf_XY = pd.merge(gdf_XY, df_XY, on = 'ID', how = 'inner') # Geojoins can use pandas merge as long as geo data is first passed in function
gdf_XY['x'] = gdf_XY['geometry'].centroid.x # Save centroid coordinates as separate column
gdf_XY['y'] = gdf_XY['geometry'].centroid.y # Save centroid coordinates as separate column
gdf_XY['coordinates'] = list(zip(gdf_XY['x'], gdf_XY['y'])) # Save individual coordinates as column of paired list
gdf_XY = gdf_XY.drop(columns = ['x', 'y', 'geometry']) # Drop Unwanted Columns
gdf_XY.info() # Get class, memory, and column info: names, data types, obs.

### Setup GWR table
gdf_gwr = gdf_XY.set_index('ID') # Set ID column as index
wood = gdf_gwr[mrfractureproof].columns.to_list() # Save fractureproof variables as list for GWR
wood.append('quant') # Add outcome to list of gwr variables
wood.append('coordinates') # Add coordinates to list of gwr variables
wood.remove('D2-4_72') # Remove non-significant variables manually
wood.remove('D2-4_34') # Remove non-significant variables
gdf_gwr = gdf_gwr[wood] # Subset dataframe by sleetced variables
gdf_gwr = gdf_gwr.dropna() # Drop all rows with NA values
c = list(gdf_gwr["coordinates"]) # save coordinates column as list
x = gdf_gwr.drop(columns = ['quant', 'coordinates']).values # save selected features as numpy array
y = gdf_gwr['quant'].values # save target as numpy array
y = np.transpose([y]) # Transpose numpy array to fit GWR input
gdf_gwr.info() # Get class, memory, and column info: names, data types, obs.

### Create GWR model
mgwr_selector = Sel_BW(c, y, x, multi = True) # create model to calibrate selector
mgwr_bw = mgwr_selector.search(multi_bw_min = [2]) # search for selectors with minimum of 2 bandwidths, this may take a while
mgwr_results = MGWR(c, y, x, mgwr_selector).fit() # fit MGWR model, this may take a while
mgwr_results.summary() # Show MGWR summary

### Export GWR results to new table
wood.remove('quant') # Remove outcome to list of gwr variables
wood.remove('coordinates') # Remove coordinates to list of gwr variables
wood = ['Intercept'] + wood # Insert intercept label at front of gwr variable list
df_gwr = pd.DataFrame(mgwr_results.params, columns = [wood]) # Create data frame of importances with variables and gini column names
gdf_ID = gdf_gwr.reset_index() # Reset index on GWR inputs
df_gwr['ID'] = gdf_ID['ID'] # Ad ID column from GWR inputs table
df_gwr.info()  # Get class, memory, and column info: names, data types, obs.

### Join first and second geographic layer lables
df_layer = pd.read_csv('_data/FIPS_ZCTA_key.csv') # Import layer key dataset saved as csv in _data folder
df_layer = df_layer.filter(['FIPS', 'ZCTA']) # Keep only selected columns
df_layer = df_layer.rename(columns = {ID: 'ID', 'FIPS': 'ID_2'}) # Rename geographic identifiers as standard features
gdf_ID_2 = gdf_gwr.reset_index() # Reset Index as second geographic layer ID adn save as gdf for later
df_gwr = pd.merge(gdf_gwr, df_layer, on = 'ID', how = 'left') # Join zip code geo weighted coefficients to county labels
df_gwr = df_gwr.dropna() # Drop all rows with NA values
df_gwr = df_gwr.set_index('ID') # Set first layer ID column as index
df_gwr = df_gwr.drop(columns = ['coordinates', 'quant']) # Drop Unwanted Columns
df_gwr = df_gwr.groupby(['ID_2'], as_index = False).mean() # Group 1st layer GWR coefficents by 2nd layer identifiers and calculate average
df_gwr.info() # Get class, memory, and column info: names, data types, obs.

### Create Multi-level categories based bandwidths
df_bw = df_gwr.drop(columns = ['ID_2']) # Drop Unwanted Columns
df_bw = df_bw.apply(st.zscore).abs() # Calculate absolute value of z-score for mean GWR coefficients in second layer
df_bw['ID_2'] = df_gwr['ID_2'] # Save second layer identifiers from GWR dataset
df_bw = df_bw.set_index('ID_2') # Set second layer identifiers as index
bw = df_bw.idxmax(axis = 1) # Get second layer identifiers that have highest absolute value of z score
l_bw = list(zip(df_bw.index, bw)) # Create list of variables alongside RFE value 
df_bw = pd.DataFrame(l_bw, columns = ['ID_2', 'multi']) # Create data frame of 1st layer features and 2nd layer identifiers
df_bw['multi'] = df_bw['multi'].astype('category') # Save features as multi-level categoriacl variable with standard name
df_bw['multi'] = df_bw['multi'].cat.codes # Convert string lable into numeric codes
df_bw.info() # Get class, memory, and column info: names, data types, obs.

### Append step 4 results to corresponding text file
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(s4 + '\n\n') # Step title
text_file.write('Models: ' + m5 + '\n\n') # Model title
text_file.write('Bandwidths: ' + str(mgwr_bw) + '\n\n') # Result description, result list
text_file.write('Mean Coefficients by County: ' + '\n\n') # Result description
text_file.write(str(df_gwr.describe()) + '\n\n') # Result descriptive statistics
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file 

## Step 5: Data Processing of 2nd Geographic Layer
ls5 = 'Step 5: Raw Data Processing and Feature Engineering (2nd Geographic Layer)' # Step 5 descriptive title
d3 = 'Health Resources and Servcies Administration Area Heath Resource File Populaton Rates by County 2014-2018 5-year Average' # Dataset 3 descriptive title

### Preprocess Third Dataset
df_d3 = pd.read_csv('_data/' + f3 + '_stage.csv') # Import third dataset saved as csv in _data folder
df_d3 = df_d3.rename(columns = {'FIPS': 'ID_2'}) # Apply standard name to identifier used for joining 2nd layer datasets
df_d3.info() # Get class, memory, and column info: names, data types, obs

### Join Datasets by second layer identifier and define targets
df_XY_2 = pd.merge(df_d3, df_bw, on = 'ID_2', how = 'inner') # Join datasets to create table with predictors and outcome
df_XY_2.info() # Get class, memory, and column info: names, data types, obs.

### Create second layer outcome table
df_Y_2 = df_XY_2.filter(['multi', 'ID_2']) # Create Outcome table for second layer
df_Y_2 = df_Y_2.set_index('ID_2') # Set second layer identifier as index
df_Y_2.info() # Get class, memory, and column info: names, data types, obs.

### Create second layer standard scaled predictor table
df_X_2 = df_XY_2.drop(columns = ['multi', 'ID_2']) # Drop Unwanted Columns
df_X_2 = df_X_2.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X_2 = df_X_2.dropna(axis = 1, thresh = 0.75*len(df_X_2)) # Drop features less than 75% non-NA count for all columns
df_X_2 = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X_2), columns = df_X_2.columns) # Impute missing data
df_X_2 = pd.DataFrame(StandardScaler().fit_transform(df_X_2.values), columns = df_X_2.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X_2['ID_2'] = df_XY_2['ID_2'] # Save ID as column in predictor table
df_X_2 = df_X_2.set_index('ID_2') # Set identifier as index
df_X_2.info() # Get class, memory, and column info: names, data types, obs.

### Append step 5 results to corresponding text file
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(s5 + '\n\n') # Step descriptive title
text_file.write(d3 + '\n') # Dataset descriptive title
text_file.write('Target labels: multi = selected varibles from step 2 with highest average absolute value of z-score by identifier' + '\n') # Dataset methods description
text_file.write('Target processing: None' + '\n\n') # Dataset methods description
text_file.write(str(df_Y_2.describe())  + '\n\n') # Result summary
text_file.write('Feature labels: AHRF Population Rates' + '\n') # Dataset methods description
text_file.write('Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled' + '\n\n') # Dataset methods description
text_file.write('Rows, Columns: ' + str(df_X_2.shape) + '\n\n') # Result description and result list
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Step 6: Identify 2nd Layer Predictors
s5 = 'Step 6: Identify 2nd Layer Predictors' # Step 6 descriptive title
m6 = 'Support Vector Machines' # Model 6 descriptive title

### Support Vector Machines
vector = LinearSVC() # Support vector machines with a linear kernel for multi-level categorical outrcomes
vector.fit(df_X_2, df_Y_2['multi']) # fit model
svm = vector.coef_ # Save coefficients for each category by feature
df_svm = pd.DataFrame(svm, columns = df_X_2.columns, index = [fractureproof]) # Create data frame of coefficients by 2nd layer features and 1st layer features
df_svm = df_svm.abs() # Get absolute value of all coefficients
svm_max = df_svm.idxmax(axis = 1) # Get 2nd layer features that have highest values for each 1st layer feature
l_svm_max = list(zip(df_svm.index, svm_max)) # Create list of 2nd layer features along 1st layer features
df_svm_max = pd.DataFrame(l_svm_max, columns = ['GWR', 'Feature']) # Create data frame of 2nd layer features along 1st layer features
carving = df_svm_max['Feature'].unique() # Print unique values in column to remove duplicate 2nd layer features and save as list
df_svm_max.info() # Get class, memory, and column info: names, data types, obs.

### Principal Component Analysis
degree = len(df_X_2[carving].columns) - 1  # Save number of features -1 to get degrees of freedom
pca = PCA(n_components = degree) # Pass the number of components to make PCA model based on degrees of freedom
pca.fit(df_X_2[carving]) # Fit initial PCA model

### Variance ratios and component Loadings
cvr = pca.explained_variance_ratio_.cumsum() # Save cumulative variance ratio
comps = np.count_nonzero(cvr) - np.count_nonzero(cvr > 0.95) + 1 # Save number of components above threshold value
load = pca.components_.T * np.sqrt(pca.explained_variance_) # Export component loadings
df_load = pd.DataFrame(load, index = df_X_2[carving].columns) # Create data frame of component loading
df_load = df_load.iloc[:, 0:comps] # Save columns by components above threshold
df_load = df_load.abs() # get absolute value for column or data frame
df_load = df_load[df_load > 0.5] # Subset by character
df_load = df_load.dropna(thresh = 1) # Drop all rows without 1 non-NA value
df_load = df_load.dropna(axis = 'columns', thresh = 1) # Drop all rows without 1 non-NA value
woodcarving = df_load.index.to_list() # Save final set of 2nd layer features to list
df_load.info() # Get class, memory, and column info: names, data types, obs.

### Add 2nd layer feature labels
df_l3 = pd.read_csv('_data/' + f3 + '_labels.csv') # Import dataset saved as csv in _data folder
df_l_3 = df_l3.filter(['Feature', 'Label']) # Keep only selected columns
df_l_3 = df_l_3.set_index('Feature') # Set column as index
df_l_3 = df_l_3.transpose() # Switch rows and columns
df_lwc = df_l_3[woodcarving] # Subset by 2nd layer selected featres
df_lwc = df_lwc.transpose() # Switch rows and columns
df_lwc = df_lwc.reset_index() # Reset index
l_lwc = list(zip(df_lwc['Feature'], df_lwc['Label'])) # Create list of variables alongside RFE value 
df_lwc.info() # Get class, memory, and column info: names, data types, obs.

### Append step 6 results to corresponding text file
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(s6 + '\n\n') # Step description
text_file.write('Models: ' + m5 + '\n\n') # Model description
text_file.write('Values: Coefficients' + '\n') # Model methods description
text_file.write('Thresholds: Max Absolute Value' + '\n\n') # Model methods description
text_file.write(str(df_svm_max)  + '\n\n') # Result dataframe
text_file.write('Models: ' + m1 + '\n\n') # Model description
text_file.write('Cumulative Variance: Threshold = 95%' + '\n') # Model methods description
text_file.write(str(cvr) + "\n\n") # Result object
text_file.write('Component Loadings' + '\n') # Result description
text_file.write(str(df_load)  + '\n\n') # Result dataframe
text_file.write('Final List of selected 2nd layer features' + '\n') # Result description
text_file.write(str(l_lwc)  + '\n\n') # Result list
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Step 7: Create Informative Prediction Model with both geographic layers
s7 = 'Step 7: Create Informative Preidction Model with both geographic layers' # Step 1 descriptive title

### Join Datasets by ID and define targets
df_XY_f = pd.merge(df_XY_2, df_layer, on = 'ID_2', how = 'left') # Join datasets to create table with predictors and outcome
df_XY_f = pd.merge(df_XY, df_XY_f, on = 'ID', how = 'inner') # Join datasets to create table with predictors and outcome
df_XY_f = df_XY_f.drop(columns = ['ID_2', 'multi']) # Drop Unwanted Columns
df_XY_f = df_XY_f.dropna(subset = ['quant']) # Drop all outcome rows with NA values
df_XY_f.info() # Get class, memory, and column info: names, data types, obs.

### Create Multiple Regression Model
mrfractureproofswoodcarvings = mrfractureproof + woodcarving # Combine 2nd layer slected features with first layer regression model features
mrfractureproofswoodcarvings.append('quant') # Remove outcome from 1st and 2nd layer regression feature list
df_mrfpwc = df_XY_f[mrfractureproofswoodcarvings] # Subset full dataframe with 1st and 2nd layer regression model features
df_mrfpwc = df_mrfpwc.dropna() # Drop all NA values from subset dataframe
X = df_mrfpwc.drop(columns = ['quant']) # Create dataframe of predictors
Y = df_mrfpwc['quant'] # Create dataframe of outcomes
mod_f = sm.OLS(Y, X) # Create linear model
res_f = mod_f.fit() # Fit model to create result
res_f.summary() # Print results of regression model

### Add feature labels
df_lf = pd.concat([df_l1, df_l2, df_l3]) # Combine rows with same columns
df_lf = df_lf.filter(['Feature', 'Label']) # Keep only selected columns
df_lf = df_lf.set_index('Feature') # Set column as index
df_lf = df_lf.transpose() # Switch rows and columns
mrfractureproofswoodcarvings.remove('quant') # Remove outcome from 1st and 2nd layer regression feature list
df_lmfpwc = df_lf[mrfractureproofswoodcarvings] # Save chosen featres as list
df_lmfpwc = df_lmfpwc.transpose() # Switch rows and columns
df_lmfpwc = df_lmfpwc.reset_index() # Reset index
l_lmfpwc = list(zip(df_lmfpwc['Feature'], df_lmfpwc['Label'])) # Create list of variables alongside RFE value 
df_lmfpwc.info() # Get class, memory, and column info: names, data types, obs.

### Append step 7 results to corresponding text file
text_file = open(path + name + "_" + day + ".txt", "a") # Open corresponding text file
text_file.write(s7 + "\n\n") # Step description
text_file.write(d1 + '\n') # Dataset description
text_file.write(d2 + '\n') # Dataset description
text_file.write(d3 + '\n\n') # Dataset description
text_file.write('Target labels: quant = Diabetes Related (K00-K99) Raw Mortality Rate per 1000k' + '\n') # Target labels
text_file.write('Target processing: None' + '\n\n') # Result description
text_file.write(str(df_XY_f['quant'].describe())  + '\n\n') # Result summary
text_file.write('Features labels: ACS Percent Estimates' + '\n') # Dataset methods description
text_file.write('Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled' + '\n\n') # Dataset methods description
text_file.write('Rows, Columns: ' + str(df_XY_f.shape) + '\n\n') # Result description and result dataframe
text_file.write("Models: " + m4 + "\n\n") # Model description
text_file.write(str(res_f.summary())  + "\n\n") # Result summary
text_file.write('Final List of selected 1st and 2nd layer features' + '\n') # Result description
text_file.write(str(l_lmfpwc)  + "\n\n") # Result list
text_file.write("####################" + "\n\n") # Add section break for end of step
text_file.close() # Close file

## Step 8: Predict Binary Outcome with Artificial Neural Networks
s8 = 'Step 8: Predict Categorical targets with Artificial Neural Networks'
m7 = 'Multi-Layer Perceptron'

### Create outcome table and define targets
df_Y_f = df_XY_f.filter(['quant', 'ID']) # Create Outcome table
df_Y_f['binary'] = np.where(df_Y_f['quant'] > df_Y_f['quant'].quantile(0.5), 1, 0) # Create binary outcome based on conditions
df_Y_f = df_Y_f.set_index('ID') # Set identifier as index
df_Y_f.info() # Get class, memory, and column info: names, data types, obs.

### Create standard scaled predictor table
df_X_f = df_XY_f.drop(columns = ['quant', 'ID']) # Drop Unwanted Columns
df_X_f = df_X_f.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X_f = df_X_f.dropna(axis = 1, thresh = 0.75*len(df_X_f)) # Drop features less than 75% non-NA count for all columns
df_X_f = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X_f), columns = df_X_f.columns) # Impute missing data
df_X_f = pd.DataFrame(StandardScaler().fit_transform(df_X_f.values), columns = df_X_f.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X_f['ID'] = df_XY_f['ID'] # Save ID as column in predictor table
df_X_f = df_X_f.set_index('ID') # Set identifier as index
df_X_f.info() # Get class, memory, and column info: names, data types, obs.

### Save FractureProof and Woodcarving feature list
mrfractureproofscontemplativewoodcarvings = mrfractureproof + woodcarving # Combine 2nd layer slected features with first layer regression model features

### Multi-Layered Perceptron with all predictors from all layers
Y = df_Y_f.filter(['binary']) # Save binary outcome as MLP Input
X = df_X_f # Save all predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 50
network = Sequential() # Build Network with keras Sequential API
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal', input_dim = input)) # First dense layer
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal')) # Second dense layer
network.add(Dense(1, activation = 'sigmoid', kernel_initializer = 'random_normal')) # Output layer with binary activation
network.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy']) # Compile network with Adaptive moment estimation, and follow loss and accuracy
final = network.fit(X_train, Y_train, batch_size = 10, epochs = epochs) # Fitting the data to the train outcome, with batch size and number of epochs
Y_pred = network.predict(X_test) # Predict values from test data
Y_pred = (Y_pred > 0.5) # Save predicted values close to 1 as boolean
Y_test = (Y_test > 0.5) # Save test values close to 1 as boolean
fpr, tpr, threshold = roc_curve(Y_test, Y_pred) # Create ROC outputs, true positive rate and false positive rate
auc_a = auc(fpr, tpr) # Plot ROC and get AUC score
e_a = epochs # Save epochs used for mlp
print(auc_a) # Display object

### Multi-Layered Perceptron with Mr. Fracture Proof predictors
Y = df_Y_f.filter(['binary']) # Save binary outcome as MLP Input
X = df_X_f[mrfractureproof] # Save selected predictors from all layers predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 500
network = Sequential() # Build Network with keras Sequential API
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal', input_dim = input)) # First dense layer
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal')) # Second dense layer
network.add(Dense(1, activation = 'sigmoid', kernel_initializer = 'random_normal')) # Output layer with binary activation
network.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy']) # Compile network with Adaptive moment estimation, and follow loss and accuracy
final = network.fit(X_train, Y_train, batch_size = 10, epochs = epochs) # Fitting the data to the train outcome, with batch size and number of epochs
Y_pred = network.predict(X_test) # Predict values from test data
Y_pred = (Y_pred > 0.5) # Save predicted values close to 1 as boolean
Y_test = (Y_test > 0.5) # Save test values close to 1 as boolean
fpr, tpr, threshold = roc_curve(Y_test, Y_pred) # Create ROC outputs, true positive rate and false positive rate
auc_mrfp = auc(fpr, tpr) # Plot ROC and get AUC score
e_mrfp = epochs # Save epochs used for mlp
print(auc_mrfp) # Display object

### Multi-Layered Perceptron with Woodcarving predictors
Y = df_Y_f.filter(['binary']) # Save binary outcome as MLP Input
X = df_X_f[woodcarving] # Save selected predictors from all layers predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 500
network = Sequential() # Build Network with keras Sequential API
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal', input_dim = input)) # First dense layer
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal')) # Second dense layer
network.add(Dense(1, activation = 'sigmoid', kernel_initializer = 'random_normal')) # Output layer with binary activation
network.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy']) # Compile network with Adaptive moment estimation, and follow loss and accuracy
final = network.fit(X_train, Y_train, batch_size = 10, epochs = epochs) # Fitting the data to the train outcome, with batch size and number of epochs
Y_pred = network.predict(X_test) # Predict values from test data
Y_pred = (Y_pred > 0.5) # Save predicted values close to 1 as boolean
Y_test = (Y_test > 0.5) # Save test values close to 1 as boolean
fpr, tpr, threshold = roc_curve(Y_test, Y_pred) # Create ROC outputs, true positive rate and false positive rate
auc_wc = auc(fpr, tpr) # Plot ROC and get AUC score
e_wc = epochs # Save epochs used for mlp
print(auc_wc) # Display object

### Multi-Layered Perceptron with Mr. Fracture Proof's Contemplative Woodcarving predictors
Y = df_Y_f.filter(['binary']) # Save binary outcome as MLP Input
X = df_X_f[mrfractureproofscontemplativewoodcarvings] # Save selected predictors from all layers predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 500
network = Sequential() # Build Network with keras Sequential API
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal', input_dim = input)) # First dense layer
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal')) # Second dense layer
network.add(Dense(1, activation = 'sigmoid', kernel_initializer = 'random_normal')) # Output layer with binary activation
network.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy']) # Compile network with Adaptive moment estimation, and follow loss and accuracy
final = network.fit(X_train, Y_train, batch_size = 10, epochs = epochs) # Fitting the data to the train outcome, with batch size and number of epochs
Y_pred = network.predict(X_test) # Predict values from test data
Y_pred = (Y_pred > 0.5) # Save predicted values close to 1 as boolean
Y_test = (Y_test > 0.5) # Save test values close to 1 as boolean
fpr, tpr, threshold = roc_curve(Y_test, Y_pred) # Create ROC outputs, true positive rate and false positive rate
auc_mrfpctwc = auc(fpr, tpr) # Plot ROC and get AUC score
e_mrfpctwc = epochs # Save epochs used for mlp
print(auc_mrfpctwc) # Display object

### Append step 8 results to corresponding text file
text_file = open(path + name + '_' + day + '.txt', 'a') # Open corresponding text file
text_file.write(s8 + '\n\n') # Step description
text_file.write(d1 + '\n') # Dataset description
text_file.write(d2 + '\n') # Dataset description
text_file.write(d3 + '\n\n') # Dataset description
text_file.write('Target labels: binary = Diabetes Related (K00-K99) Raw Mortality Rate per 1000k above 50% percentile' + '\n') # Target labels
text_file.write('Target processing: train, test random 50-50 split' + '\n\n') # Model methods description
text_file.write(m7 + '\n') # Model description
text_file.write('Layers: Dense, Dense, Activation' + '\n') # Model methods description
text_file.write('Functions: ReLU, ReLU, Sigmoid' + '\n') # Model methods description
text_file.write('All features, all layers: AUC = ' + str(auc_a) + ', Epochs = ' + str(e_a) + '\n') # Result description and result dataframe
text_file.write('Fractureproof Features: AUC = ' + str(auc_mrfp) + ', Epochs = ' + str(e_mrfp) + '\n') # Result description and result dataframe
text_file.write('Woodcarving Features: AUC = ' + str(auc_wc) + ', Epochs = ' + str(e_wc) + '\n') # Result description and result dataframe
text_file.write('Mr. Fracture Proofs Woodcarving Features: AUC = ' + str(auc_mrfpctwc) + ', Epochs = ' + str(e_mrfpctwc) + '\n\n') # Result description and result dataframe
text_file.write('Mr. Fracture Proofs Woodcarving Features, Final list:' + '\n\n') # Result description
text_file.write('Mr. Fracture Proof (1st layer): ' + str(l_lmrfp)  + '\n\n') # Result list
text_file.write('Woodcarving (2nd layer): ' + str(l_lwc)  + '\n\n') # Result list
text_file.write('####################' + '\n\n')
text_file.close() # Close file