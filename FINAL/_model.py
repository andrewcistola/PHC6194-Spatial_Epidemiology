# allocativ 3001.2021.0002

## Model Step 1: Data Processing of Predictors and Outcomes
ms1 = 'Model Step 1: Raw Data Processing and Feature Engineering' # Step 1 descriptive title

### Import and Join to Create Labels Outcomes (WY)
df_W = pd.read_csv('_data/FIPS_ZCTA.csv') # Import dataset from _data folder
df_X = pd.read_csv('_data/_learn_ZCTA.csv') # Import dataset from _data folder
df_Y = pd.read_csv('_data/_spatial_ZCTA.csv') # Import dataset from _data folder
df_WX = pd.merge(df_W, df_X, on = 'ZCTA', how = 'left') # Merge data frame into data slot in SpatialDataFrame
df_WXY = pd.merge(df_WX, df_Y, on = 'ZCTA', how = 'left') # Merge data farem into data slot in SpatialDataFrame
df_WXY = df_WXY[df_WXY.ST == ST] # Drop rows by condition
df_WXY = df_WXY.set_index('ZCTA')
df_WXY = df_WXY.dropna()
df_WXY.info() # Verify
df_WXY.head() # Get class, memory, and column info: names, data types, obs.

### Join Datasets by second layer identifier and define targets
df_W2 = pd.read_csv('_data/FIPS_ZCTA.csv') # Import dataset from _data folder
df_X2 = pd.read_csv('_data/_learn_FIPS.csv') # Import third dataset saved as csv in _data folder
df_Y2 = pd.read_csv('_data/_spatial_FIPS.csv') # Import dataset from _data folder
df_WX2 = pd.merge(df_W2, df_X2, on = 'FIPS', how = 'inner') # Join datasets to create table with predictors and outcome
df_WXY2 = pd.merge(df_WX2, df_Y2, on = 'FIPS', how = 'inner') # Join datasets to create table with predictors and outcome
df_WXY2 = df_WXY2[df_WXY2.ST == ST] # Drop rows by condition
df_WXY2 = df_WXY2.drop_duplicates(subset = 'FIPS', keep = 'first') # Drop all dupliacted values
df_WXY2 = df_WXY2.set_index('ZCTA')
df_WXY2 = df_WXY2.dropna()
df_WXY2.info() # Get class, memory, and column info: names, data types, obs.
df_WXY2.head() # Get class, memory, and column info: names, data types, obs.

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ms1 + '\n\n') # Step description
text_file.write('Zip Code model for ' + State + '\n\n') # Result description and result dataframe
text_file.write('   Outcome Descriptives: ' + str(df_Y.crude.describe())  + '\n\n') # Result descriptive statistics for target
text_file.write('   N Observations, N Predictors: ' + str(df_X.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_X.columns) + '\n\n') # Result description and result dataframe
text_file.write('County model for ' + state + '\n\n') # Result description and result dataframe
text_file.write('   Outcome Descriptives: ' + str(df_Y2.crude.describe())  + '\n\n') # Result descriptive statistics for target
text_file.write('   N Observations, N Predictors: ' + str(df_X2.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_X2.columns) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Model Step 2: Create Informative Prediction Model
ms2 = 'Model Step 2: Create Informative Preidction Model' # Step 3 descriptive title
m4 = 'OLS Regression Model' # Model 4 descriptive title

### Generalized Linear Model for ZCTA
X = df_WXY[df_X.set_index('ZCTA').columns] # Subset original nonscaled data for regression
Y = df_WXY['bayes'] # Subset quantitative outcome for regression
mod = sm.OLS(Y, X.astype(float)) # Create linear regression model
res = mod.fit() # Fit model to create result
res.summary() # Print results of regression model

### Generalized Linear Model for FIPS
X = df_WXY2[df_X2.set_index('FIPS').columns] # Subset original nonscaled data for regression
Y = df_WXY2['bayes'] # Subset quantitative outcome for regression
mod = sm.OLS(Y, X.astype(float)) # Create linear regression model
res2 = mod.fit() # Fit model to create result
res2.summary() # Print results of regression model

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ms2 + '\n\n') # Step title
text_file.write('Models: ' + m4 + '\n\n') # Model description
text_file.write('Zip Code model\n\n') # Model description
text_file.write(str(res.summary())  + '\n\n') # Result summary
text_file.write('County model\n\n') # Model description
text_file.write(str(res2.summary())  + '\n\n') # Result summary
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Model Step 3: Predict Binary Outcome with Artificial Neural Networks
ms3 = 'Model Step 3: Predict Categorical targets with Artificial Neural Networks'
m7 = 'Multi-Layer Perceptron'
mf2 = 'CENSUS_ACS_2019_ZCTA' # Dataset 2 file label
mf3 = 'HRSA_AHRF_2019_FIPS' # Dataset 2 file label

### Create complete predictor table
df_W3 = pd.read_csv('_data/FIPS_ZCTA.csv') # Import dataset from _data folder
df_X3a = pd.read_sql_query('SELECT * FROM ' + mf2, con_1) # Read table from SQlite db file into pandas dataframe
df_Y3 = pd.read_csv('_data/_spatial_ZCTA.csv') # Import dataset from _data folder
df_WX3 = pd.merge(df_W3, df_X3a, on = 'ZCTA', how = 'left') # Merge data frame into data slot in SpatialDataFrame
df_WXY3 = pd.merge(df_WX3, df_Y3, on = 'ZCTA', how = 'left') # Merge data farem into data slot in SpatialDataFrame
df_X3b = pd.read_csv('_data/' + mf3 + '.csv') # Import third dataset saved as csv in _data folder
df_WXY3 = df_WXY3[df_WXY3.ST == ST] # Drop rows by condition
df_WXY3 = pd.merge(df_WXY3, df_X3b, on = 'FIPS', how = 'left')
df_WXY3 = df_WXY3.drop(columns = df_W3.set_index('ZCTA').columns) # Drop Unwanted Columns
df_WXY3 = df_WXY3.set_index('ZCTA')
df_WXY3 = df_WXY3.dropna(subset = ['binary']) # Define in which columns to look for missing values
df_X3 = df_WXY3.drop(columns = df_Y3.set_index('ZCTA').columns) # Drop Unwanted Columns
df_X3 = df_X3.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X3 = df_X3.dropna(axis = 1, thresh = 0.50*len(df_X3)) # Drop features less than 75% non-NA crude for all columns
df_X3 = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X3), columns = df_X3.columns) # Impute missing data
df_X3 = pd.DataFrame(StandardScaler().fit_transform(df_X3.values), columns = df_X3.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X3.head()

### Create selected predictor table
df_WX2Y = pd.merge(df_WXY, df_X2, on = 'FIPS', how = 'left')
df_WX2Y = df_WX2Y.drop(columns = df_W.set_index('ZCTA').columns) # Drop Unwanted Columns
df_WX2Y = df_WX2Y.dropna(subset = ['binary']) # Define in which columns to look for missing values:
df_X2 = df_WX2Y.drop(columns = df_Y.set_index('ZCTA').columns) # Drop Unwanted Columns
df_X2 = df_X2.replace([np.inf, -np.inf], np.nan) # Replace infitite values with NA
df_X2 = df_X2.dropna(axis = 1, thresh = 0.50*len(df_X2)) # Drop features less than 75% non-NA crude for all columns
df_X2 = pd.DataFrame(SimpleImputer(strategy = 'median').fit_transform(df_X2), columns = df_X2.columns) # Impute missing data
df_X2 = pd.DataFrame(StandardScaler().fit_transform(df_X2.values), columns = df_X2.columns) # Standard scale values by converting the normalized features into a tabular format with the help of DataFrame.
df_X2.head()

### Multi-Layered Perceptron with complete predictors
Y = df_WXY3.filter(['binary']) # Save binary outcome as MLP Input
X = df_X3 # Save all predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 100
network = Sequential() # Build Network with keras Sequential API
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal', input_dim = input)) # First dense layer
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal')) # Second dense layer
network.add(Dense(1, activation = 'sigmoid', kernel_initializer = 'random_normal')) # Output layer with binary activation
network.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy']) # Compile network with Adaptive moment estimation, and follow loss and accuracy
history = network.fit(X_train, Y_train, batch_size = 10, epochs = epochs) # Fitting the data to the train outcome, with batch size and number of epochs
Y_pred = network.predict(X_test) # Predict values from test data
Y_pred = (Y_pred > 0.5) # Save predicted values close to 1 as boolean
Y_test = (Y_test > 0.5) # Save test values close to 1 as boolean
fpr1, tpr1, threshold = roc_curve(Y_test, Y_pred) # Create ROC outputs, true positive rate and false positive rate
auc1 = auc(fpr1, tpr1) # Plot ROC and get AUC score
loss1 = history.history['loss']
epc1 = len(loss1) # Save epochs used for mlp
print(auc1) # Display object

### Multi-Layered Perceptron with selected predictors
Y = df_WX2Y.filter(['binary']) # Save binary outcome as MLP Input
X = df_X2 # Save selected predictors from all layers predictors as MLP input
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.50) # Random 50/50 Train/Test Split
input = X.shape[1] # Save number of columns as input dimension
nodes = round(input / 2) # Number of input dimensions divided by two for nodes in each layer
epochs = 100
network = Sequential() # Build Network with keras Sequential API
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal', input_dim = input)) # First dense layer
network.add(Dense(nodes, activation = 'relu', kernel_initializer = 'random_normal')) # Second dense layer
network.add(Dense(1, activation = 'sigmoid', kernel_initializer = 'random_normal')) # Output layer with binary activation
network.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy']) # Compile network with Adaptive moment estimation, and follow loss and accuracy
history = network.fit(X_train, Y_train, batch_size = 10, epochs = epochs) # Fitting the data to the train outcome, with batch size and number of epochs
Y_pred = network.predict(X_test) # Predict values from test data
Y_pred = (Y_pred > 0.5) # Save predicted values close to 1 as boolean
Y_test = (Y_test > 0.5) # Save test values close to 1 as boolean
fpr2, tpr2, threshold = roc_curve(Y_test, Y_pred) # Create ROC outputs, true positive rate and false positive rate
auc2 = auc(fpr2, tpr2) # Plot ROC and get AUC score
loss2 = history.history['loss']
epc2 = len(loss2) # Save epochs used for mlp
print(auc2) # Display object

### Loss epoch plot
plt.figure(figsize = (8, 4))
plt.plot(range(1, epc1 + 1), loss1, color = 'r')
plt.plot(range(1, epc2 + 1), loss2, color = 'b')
plt.grid()
plt.xticks(fontsize = 8)
plt.yticks(fontsize = 8)
plt.xlabel('Epochs', fontsize = 12)
plt.ylabel('Loss', fontsize = 12)
plt.legend(['Complete', 'Selected'], fontsize = 12)
plt.title('Training Loss for Multi-layered Perceptrons using Complete and Selected Predcitor Sets', fontsize = 12)
plt.savefig('_fig/' + ST + '_binary_loss_' + 'plot.jpeg', bbox_inches = 'tight')

### ROC Plot
plt.figure(figsize = (8, 8))
plt.plot(fpr1, tpr1, 'r', label = 'Complete, AUC = ' + str(auc1.round(2)))
plt.plot(fpr2, tpr2, 'b', label = 'Selected, AUC = ' + str(auc2.round(2)))
plt.plot([0, 1], [0, 1],'g--')
plt.xlim([0, 1])
plt.ylim([0, 1])
plt.grid()
plt.xticks(fontsize = 8)
plt.yticks(fontsize = 8)
plt.ylabel('True Positive Rate', fontsize = 12)
plt.xlabel('False Positive Rate', fontsize = 12)
plt.legend(loc = 'lower right', fontsize = 12)
plt.title('ROC Curve using Complete and Selected Predcitor Sets', fontsize = 12)
plt.savefig('_fig/' + ST + '_binary_roc_' + 'plot.jpeg', bbox_inches = 'tight')

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write(ms3 + '\n\n') # Step description
text_file.write('Target labels: Top quartile of ' + outcome + '\n') # Target labels
text_file.write('Target processing: train, test random 50-50 split' + '\n\n') # Model methods description
text_file.write(m7 + '\n') # Model description
text_file.write('Layers: Dense, Dense, Activation' + '\n') # Model methods description
text_file.write('Functions: ReLU, ReLU, Sigmoid' + '\n') # Model methods description
text_file.write('All features: AUC = ' + str(auc1) + ', Epochs = ' + str(epc1) + '\n') # Result description and result dataframe
text_file.write('Selected Zip Code Features: AUC = ' + str(auc2) + ', Epochs = ' + str(epc2) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n')
text_file.close() # Close file

