# FractureProof
## Version 3
### Model Script - Mr. FractureProof

## Model Step 1: Data Processing of Predictors and Outcomes
ms1 = 'Model Step 1: Raw Data Processing and Feature Engineering' # Step 1 descriptive title
ID = 'ZCTA'
DV = 'D1_23'

### Import staged data tables, apply standard labels, define target
df_d1 = pd.read_sql_query('SELECT * FROM ' + f1 + '_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2 = pd.read_sql_query('SELECT * FROM ' + f2 + '_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_XY = df_d1.filter([DV, ID]) # Create Outcome table
df_XY = pd.merge(df_XY, df_d2, on = ID, how = 'inner') # Join datasets to create table with predictors and outcome
df_XY = df_XY.rename(columns = {ID: 'ID', DV: 'quant'}) # Apply standard name to identifier used for joining datasets and quantitative target 
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
df_l1 = pd.read_sql_query('SELECT * FROM ' + f1 + '_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2 = pd.read_sql_query('SELECT * FROM ' + f2 + '_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_label = pd.concat([df_l1, df_l2]) # Combine rows with same columns
df_label.to_csv(path_or_buf = path_label + '.csv', index = False) # Clean in excel and select variable
df_label = df_label.set_index('Feature') # Set column as index
df_label = df_label.transpose() # Switch rows and columns
df_label.info # Get class, memory, and column info: names, data types, obs.

### Append step 4 results to corresponding text file
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(ms1 + '\n\n') # Step description
text_file.write('Target labels: quant = Mental health not good for ≥14 days among adults aged ≥18 years' + '\n') # Dataset methods description
text_file.write('Target processing: nonNA' + '\n\n') # Dataset methods description
text_file.write(str(df_Y.describe())  + '\n\n') # Result descriptive statistics for target
text_file.write('Features labels: ACS Percent Estimates' + '\n') # Result description
text_file.write('Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled' + '\n\n') # Dataset methods description
text_file.write('Rows, Columns: ' + str(df_X.shape) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Model Step 2: Identify Predictors
ms2 = "Model Step 2: Identify Predictors with Open Models" # Step 2 descriptive title
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
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(ms2 + '\n\n') # Step description
text_file.write('Models: ' + m1 + ', ' + m2 + ', ' + m3 + '\n\n') # Model description
text_file.write('Values: Eigenvectors, Gini Impurity, Boolean' + '\n') # Model methods description
text_file.write('Thresholds: Mean, Mean, Cross Validation' + '\n\n') # Model methods description
text_file.write(str(df_fp)  + '\n\n') # Result dataframe
text_file.write("Final list of selected features" + "\n") # Result description
text_file.write(str(l_lfp)  + '\n\n') # Result list
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Model Step 3: Create Informative Prediction Model
ms3 = 'Model Step 3: Create Informative Preidction Model' # Step 3 descriptive title
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
df_lmrfp = df_lmrfp.transpose() # Switch rows and columns
df_lmrfp = df_lmrfp.reset_index() # Reset index
l_lmrfp = list(zip(df_lmrfp['Feature'], df_lmrfp['Label'])) # Create list of variables alongside RFE value 
df_lmrfp.info() # Get class, memory, and column info: names, data types, obs.

### Append step 3 results to corresponding text file
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(ms3 + '\n\n') # Step title
text_file.write('Models: ' + m4 + '\n\n') # Model description
text_file.write(str(res.summary())  + '\n\n') # Result summary
text_file.write(str(l_lmrfp)  + '\n\n') # Result list
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Model Step 4: Predict Binary Outcome with Artificial Neural Networks
ms4 = 'Model Step 4: Predict Categorical targets with Artificial Neural Networks'
m7 = 'Multi-Layer Perceptron'

### Create outcome table and define targets
df_Y = df_XY.filter(['quant', 'ID']) # Create Outcome table
df_Y['binary'] = np.where(df_Y['quant'] > df_Y['quant'].quantile(0.75), 1, 0) # Create binary outcome based on conditions
df_Y.info() # Get class, memory, and column info: names, data types, obs.

### Multi-Layered Perceptron with all predictors from all layers
Y = df_Y.filter(['binary']) # Save binary outcome as MLP Input
X = df_X # Save all predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 100
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
Y = df_Y.filter(['binary']) # Save binary outcome as MLP Input
X = df_X[mrfractureproof] # Save selected predictors from all layers predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 100
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

### Append step 4 results to corresponding text file
text_file = open('_results/' + label + '.txt', 'a') # Write new corresponding text file
text_file.write(ms4 + '\n\n') # Step description
text_file.write('Target labels: binary = ' + '\n') # Target labels
text_file.write('Target processing: train, test random 50-50 split' + '\n\n') # Model methods description
text_file.write(m7 + '\n') # Model description
text_file.write('Layers: Dense, Dense, Activation' + '\n') # Model methods description
text_file.write('Functions: ReLU, ReLU, Sigmoid' + '\n') # Model methods description
text_file.write('All features: AUC = ' + str(auc_a) + ', Epochs = ' + str(e_a) + '\n') # Result description and result dataframe
text_file.write('Mr. Fractureproof Features: AUC = ' + str(auc_mrfp) + ', Epochs = ' + str(e_mrfp) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n')
text_file.close() # Close file
